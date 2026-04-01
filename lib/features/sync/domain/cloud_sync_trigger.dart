/// Why a cloud delta sync was started (telemetry + user-facing diagnostics).
enum CloudSyncTrigger {
  /// User tapped "Sync now" on Profile.
  manual,

  /// Device came back online (`isOnline` false → true).
  reconnect,

  /// App returned to foreground (`AppLifecycleState.resumed`).
  resume,

  /// Initial post-frame sync after app shell mounts.
  bootstrap,
}
