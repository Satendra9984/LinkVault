enum UrlViewType {
  favicons('Favicons'),
  apps('Apps'),
  previews('Previews');

  // Associated field
  final String label;

  // Constructor
  const UrlViewType(this.label);

  // Override toString to return the label
  @override
  String toString() => label;

  // Method to get enum from string
  static UrlViewType fromString(String value) {
    return UrlViewType.values.firstWhere(
      (e) => e.label == value,
      orElse: () => UrlViewType.favicons, // Default to `favicons` if not found
    );
  }
}
