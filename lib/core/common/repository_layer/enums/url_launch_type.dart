enum UrlLaunchType {
  customTabs('customTabs'),
  webView('webView'),
  separateBrowserWindow('separateBrowserWindow'),
  readingMode('readingMode');

  // Associated field
  final String label;

  // Constructor
  const UrlLaunchType(this.label);

  // Override toString to return the label
  @override
  String toString() => label;

  // Method to get enum from string
  static UrlLaunchType fromString(String value) {
    return UrlLaunchType.values.firstWhere(
      (e) => e.label == value,
      orElse: () =>
          UrlLaunchType.customTabs, // Default to `favicons` if not found
    );
  }
}
