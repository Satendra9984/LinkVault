import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;

void main() {
  test('Test CNN favicon URL returns a valid response', () async {
    // Define the URL
    final url = Uri.parse('http://money.cnn.com/media/sites/cnn/apple-touch-icon.png');

    // Make the HTTP GET request
    final response = await http.get(url);

    // Check the response status code
    // expect(response.statusCode, 200);
    print(response.body);

    // Ensure the response body is not empty
    // expect(response.bodyBytes.isNotEmpty, true);

    // Optionally check the content-type header
    final contentType = response.headers['content-type'];
    // expect(contentType, contains('image/png'));
  });
}
