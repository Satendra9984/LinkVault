class Validator {
  /// Validates the URL format
  static String? validateUrl(String url) {
    if (url.isEmpty) {
      return 'Please enter a URL';
    }

// Check if the URL starts with "http://" or "https://"
    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      return 'URL must start with "http://" or "https://"\neg. https://www.google.com';
    }

    // URL regex pattern to validate format
    // Simplified URL regex pattern to avoid FormatException issues
// Enhanced URL regex pattern to match more accurate URLs
    // const urlPattern = r'^(https?:\/\/)?' // Protocol (http or https)
    //     r'((([a-zA-Z0-9-_]+)\.)+[a-zA-Z]{2,})' // Domain with subdomains
    //     r'(:\d{1,5})?' // Optional port
    //     r'(\/[a-zA-Z0-9@:%._\+~#=\/-]*)?' // Optional path
    //     r'(\?[a-zA-Z0-9@:%._\+~#=&]*)?' // Optional query parameters
    //     r'(#[-a-zA-Z0-9@:%_\+.~#?&//=]*)?$'; // Optional fragment

    // final urlRegex = RegExp(urlPattern);

    // if (!urlRegex.hasMatch(url)) {
    //   return 'Please enter a valid URL\neg. https://www.google.com';
    // }

    // return null; // Return null if validation is successful
    // Enhanced URL regex pattern with better support for:
    // - International domain names
    // - IP addresses
    // - Local domains
    const urlPattern = r'^(https?:\/\/)?' // Protocol (optional)
        '(' // Start domain group
        'localhost|' // Allow localhost
        r'\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}|' // IP addresses
        r'([a-zA-Z0-9_-]+\.)*[a-zA-Z0-9_-]+\.[a-zA-Z]{2,}' // Domain names
        ')' // End domain group
        r'(:\d{1,5})?' // Optional port
        r'([\/\?#][^\s]*)?$'; // Path, query parameters, and fragment

    final urlRegex = RegExp(urlPattern, caseSensitive: false);

    if (!urlRegex.hasMatch(url)) {
      return 'Please enter a valid URL';
    }

    try {
      // Additional validation using Uri.parse()
      final uri = Uri.parse(url);
      if (!uri.hasAuthority) {
        return 'Invalid URL format';
      }
    } catch (e) {
      return 'Invalid URL format';
    }

    return null;
  }

  /// Formats the URL by adding missing "https://" if necessary.
  /// Does not automatically add "www" as it's not required for modern websites.
  static String formatUrl(String url) {
    var formattedUrl = url.trim().toLowerCase();

    // Remove any leading/trailing whitespace and convert to lowercase
    formattedUrl = formattedUrl.trim().toLowerCase();

    // Handle special cases
    if (formattedUrl.startsWith('localhost')) {
      return 'http://$formattedUrl';
    }

    // Prepend https:// if no protocol is specified
    if (!formattedUrl.startsWith('http://') &&
        !formattedUrl.startsWith('https://')) {
      formattedUrl = 'https://$formattedUrl';
    }

    try {
      // Validate the final URL
      final uri = Uri.parse(formattedUrl);
      if (!uri.hasAuthority) {
        return formattedUrl;
      }
      return formattedUrl;
    } catch (e) {
      // Return original if parsing fails
      return url;
    }
  }
}
