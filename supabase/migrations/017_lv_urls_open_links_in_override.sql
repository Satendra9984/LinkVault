-- Per-URL override for open behavior; null inherits collection `open_links_in`.
alter table public.lv_urls
  add column if not exists open_links_in_override text null;

alter table public.lv_urls
  drop constraint if exists lv_urls_open_links_in_override_chk;

alter table public.lv_urls
  add constraint lv_urls_open_links_in_override_chk
  check (
    open_links_in_override is null
    or open_links_in_override in ('in_app', 'external_browser')
  );

comment on column public.lv_urls.open_links_in_override is
  'If set, overrides parent collection open_links_in for this URL; null = inherit.';
