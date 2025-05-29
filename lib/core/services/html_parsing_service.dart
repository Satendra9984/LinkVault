import 'package:html/parser.dart' as html_parser;

class HtmlParsingService {
  HtmlParsingService._();

  /// Function to check if a string is HTML and extract text content if it is.
  static String extractTextFromHtml(String input) {
    // Simple check for HTML-like content by looking for opening and closing tags
    try {
      final isHtml = input.contains(RegExp('<[^>]+>', multiLine: true));

      if (isHtml) {
        // Parse the HTML content
        final document = html_parser.parse(input);
        // Extract and return the plain text content
        return document.body?.text.trim() ?? '';
      }

      // If it's not HTML, return the original input (or handle accordingly)
      return input;
    } catch (e) {
      return input;
    }
  }
}
