import 'dart:convert';
import 'dart:io';
import 'package:link_vault/core/utils/logger.dart';

class RemoteDataSource {
  RemoteDataSource();

  // Fetch RSS feed content from URL
  Future<String?> fetchRssFeed(String url) async {
    final uri = Uri.parse(url);
    final request = await HttpClient().getUrl(uri);
    final response = await request.close();

    // Check response status
    if (response.isRedirect || response.statusCode ~/ 100 != 2) {
      return null;
    }

    // Read the content
    final content = await response.transform(const Utf8Decoder()).join();
    if (response.statusCode == 200) {
      return content;
    } else {
      // Logger.printLog('error in "fetchRssFeed" status code error');
      return null;
    }
  }
}
