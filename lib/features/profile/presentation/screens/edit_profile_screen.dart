import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../providers/profile_notifier.dart';
import '../../../auth/presentation/providers/auth_providers.dart';

/// Edit Profile at `/profile/edit`.
/// Wireframe: avatar · display name · read-only email · Danger Zone → Delete.
class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  late TextEditingController _displayNameController;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final profile = ref.read(profileNotifierProvider).value?.profile;
    _displayNameController =
        TextEditingController(text: profile?.displayName ?? '');
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    setState(() => _isSaving = true);
    await ref.read(profileNotifierProvider.notifier).updateProfile(
          displayName: _displayNameController.text.trim(),
        );
    setState(() => _isSaving = false);
    if (mounted) {
      if (ref.read(profileNotifierProvider).value?.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  ref.read(profileNotifierProvider).value!.errorMessage!)),
        );
      } else {
        context.pop();
      }
    }
  }

  Future<void> _pickAndUploadAvatar() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1000,
      maxHeight: 1000,
      imageQuality: 85,
    );
    if (pickedFile == null) return;

    final tempDir = await getTemporaryDirectory();
    final targetPath =
        '${tempDir.path}/temp_avatar_${DateTime.now().millisecondsSinceEpoch}.jpg';

    final compressedFile = await FlutterImageCompress.compressAndGetFile(
      pickedFile.path,
      targetPath,
      minWidth: 500,
      minHeight: 500,
      quality: 80,
    );

    if (compressedFile == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to compress image')),
        );
      }
      return;
    }

    await ref
        .read(profileNotifierProvider.notifier)
        .uploadAvatar(File(compressedFile.path));
  }

  void _confirmDeleteAccount() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Account?'),
        content: const Text(
          'Are you sure you want to permanently delete your account? '
          'This action cannot be undone and all your data will be immediately wiped.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              ref.read(profileNotifierProvider.notifier).deleteAccount();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete Forever'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final email = ref.watch(currentUserProvider)?.email ?? '';

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () => context.pop()),
        title: const Text('Edit profile'),
        actions: [
          if (_isSaving)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            )
          else
            TextButton(
              onPressed: _saveProfile,
              child: Text(
                'Save →',
                style: TextStyle(
                  color: cs.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          // ── Avatar ──────────────────────────────────────────────────
          _buildAvatarPicker(context, ref, cs),
          const SizedBox(height: 32),

          // ── Display name ────────────────────────────────────────────
          Text('Display name',
              style: theme.textTheme.labelLarge?.copyWith(
                  color: cs.onSurfaceVariant, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          TextField(
            controller: _displayNameController,
            textInputAction: TextInputAction.done,
            decoration: InputDecoration(
              filled: true,
              fillColor: cs.surfaceContainerHighest,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: cs.outlineVariant),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: cs.outlineVariant),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: cs.primary, width: 2),
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
          ),

          const SizedBox(height: 24),

          // ── Email (read-only) ────────────────────────────────────────
          Text('Email',
              style: theme.textTheme.labelLarge?.copyWith(
                  color: cs.onSurfaceVariant, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          TextField(
            controller: TextEditingController(text: email),
            readOnly: true,
            style: TextStyle(color: cs.onSurfaceVariant),
            decoration: InputDecoration(
              filled: true,
              fillColor: cs.surfaceContainerHighest.withValues(alpha: 0.5),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: cs.outlineVariant),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: cs.outlineVariant),
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            "You can't change your email address.",
            style: theme.textTheme.bodySmall
                ?.copyWith(color: cs.onSurfaceVariant),
          ),

          const SizedBox(height: 40),
          const Divider(),
          const SizedBox(height: 16),

          // ── Danger Zone ─────────────────────────────────────────────
          Text(
            'DANGER ZONE',
            style: theme.textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w700,
              letterSpacing: 1.1,
              color: Colors.red,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: Colors.red.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
            ),
            child: ListTile(
              leading: const Icon(Icons.delete_outline_rounded,
                  color: Colors.red),
              title: const Text('Delete account',
                  style: TextStyle(
                      color: Colors.red, fontWeight: FontWeight.w600)),
              trailing: const Icon(Icons.chevron_right, color: Colors.red),
              onTap: _confirmDeleteAccount,
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildAvatarPicker(
      BuildContext context, WidgetRef ref, ColorScheme cs) {
    final profileState = ref.watch(profileNotifierProvider).value;
    final isUploading = profileState?.isUploading ?? false;
    final profile = profileState?.profile;

    return Center(
      child: GestureDetector(
        onTap: isUploading ? null : _pickAndUploadAvatar,
        child: Stack(
          alignment: Alignment.center,
          children: [
            CircleAvatar(
              radius: 40,
              backgroundColor: cs.surfaceContainerHighest,
              backgroundImage: profile?.avatarUrl != null
                  ? CachedNetworkImageProvider(profile!.avatarUrl!)
                  : null,
              child: profile?.avatarUrl == null
                  ? Icon(Icons.person,
                      size: 40, color: cs.onSurfaceVariant)
                  : null,
            ),
            if (isUploading)
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.5),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                ),
              )
            else ...[
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: cs.primary,
                    shape: BoxShape.circle,
                    border: Border.all(color: cs.surface, width: 2),
                  ),
                  child: Icon(Icons.camera_alt_rounded,
                      size: 16, color: cs.onPrimary),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
