import "@supabase/functions-js/edge-runtime.d.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const jsonHeaders = { "Content-Type": "application/json" };

interface BucketDeleteResult {
  bucket: string;
  deleted: number;
  errors: string[];
}

async function deleteUserFolderInBucket(
  adminClient: ReturnType<typeof createClient>,
  bucket: string,
  userId: string,
): Promise<BucketDeleteResult> {
  const errors: string[] = [];
  let deleted = 0;

  const { data: listed, error: listErr } = await adminClient.storage
    .from(bucket)
    .list(userId, { limit: 1000 });

  if (listErr) {
    return {
      bucket,
      deleted,
      errors: [`list_failed:${listErr.message}`],
    };
  }

  const paths = (listed ?? [])
    .filter((item) => item.name && item.name !== ".emptyFolderPlaceholder")
    .map((item) => `${userId}/${item.name}`);

  if (paths.length === 0) {
    return { bucket, deleted, errors };
  }

  const { data: removed, error: removeErr } = await adminClient.storage
    .from(bucket)
    .remove(paths);

  if (removeErr) {
    errors.push(`remove_failed:${removeErr.message}`);
  } else {
    deleted = removed?.length ?? paths.length;
  }

  return { bucket, deleted, errors };
}

Deno.serve(async (req) => {
  if (req.method !== "POST") {
    return new Response(
      JSON.stringify({ error: "Method not allowed" }),
      { status: 405, headers: jsonHeaders },
    );
  }

  const supabaseUrl = Deno.env.get("SUPABASE_URL") ?? "";
  const supabaseAnonKey = Deno.env.get("SUPABASE_ANON_KEY") ?? "";
  const supabaseServiceRoleKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? "";
  if (!supabaseUrl || !supabaseAnonKey || !supabaseServiceRoleKey) {
    return new Response(
      JSON.stringify({ error: "Server configuration missing" }),
      { status: 500, headers: jsonHeaders },
    );
  }

  const authHeader = req.headers.get("authorization") ??
    req.headers.get("Authorization") ?? "";
  if (!authHeader.startsWith("Bearer ")) {
    return new Response(
      JSON.stringify({ error: "Unauthorized" }),
      { status: 401, headers: jsonHeaders },
    );
  }

  // Validate the caller JWT and resolve user identity.
  const userClient = createClient(supabaseUrl, supabaseAnonKey, {
    global: { headers: { Authorization: authHeader } },
  });
  const {
    data: { user },
    error: userErr,
  } = await userClient.auth.getUser();

  if (userErr || !user) {
    return new Response(
      JSON.stringify({ error: "Unauthorized" }),
      { status: 401, headers: jsonHeaders },
    );
  }

  const adminClient = createClient(supabaseUrl, supabaseServiceRoleKey);

  const avatarResult = await deleteUserFolderInBucket(
    adminClient,
    "avatars",
    user.id,
  );
  const itemImageResult = await deleteUserFolderInBucket(
    adminClient,
    "item-images",
    user.id,
  );

  const errors = [...avatarResult.errors, ...itemImageResult.errors];

  return new Response(
    JSON.stringify({
      ok: true,
      userId: user.id,
      avatarsDeleted: avatarResult.deleted,
      itemImagesDeleted: itemImageResult.deleted,
      errors,
    }),
    {
      status: 200,
      headers: jsonHeaders,
    },
  );
});
