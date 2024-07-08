import 'dart:typed_data';

import 'package:html/dom.dart';
import 'package:html/parser.dart' as html_parser;
import 'package:http/http.dart' as http;

class UrlParsingService {
// Function to fetch webpage content
  Future<String> fetchWebpageContent(String url) async {
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      return response.body;
    } else {
      throw Exception('Failed to load webpage');
    }
  }

// Function to extract title
  String extractTitle(Document document) {
    return document.head?.querySelector('title')?.text ?? '';
  }

// Function to extract description
  String extractDescription(Document document) {
    final description = document.head
            ?.querySelector('meta[name="description"]')
            ?.attributes['content'] ??
        document.head
            ?.querySelector('meta[property="og:description"]')
            ?.attributes['content'] ??
        '';
    return description;
  }

// Function to extract image URL
  String? extractImageUrl(Document document) {
    final imageUrl = document.head
            ?.querySelector('meta[property="og:image"]')
            ?.attributes['content'] ??
        document.head
            ?.querySelector('meta[name="twitter:image"]')
            ?.attributes['content'] 
        ;
    return imageUrl;
  }

// Function to extract website name
  String extractWebsiteName(Document document) {
    return document.head
            ?.querySelector('meta[property="og:site_name"]')
            ?.attributes['content'] ??
        '';
  }

// Function to extract website logo
  String extractWebsiteLogo(Document document) {
    final logoUrl =
        document.head?.querySelector('link[rel="icon"]')?.attributes['href'] ??
            document.head
                ?.querySelector('link[rel="shortcut icon"]')
                ?.attributes['href'] ??
            '';
    return logoUrl;
  }

// Function to fetch image as Uint8List
  Future<Uint8List?> fetchImageAsUint8List(String imageUrl) async {
    if (imageUrl.isEmpty) return null;
    final response = await http.get(Uri.parse(imageUrl));
    if (response.statusCode == 200) {
      return response.bodyBytes;
    }
    return null;
  }

// Function to handle relative URLs
  String handleRelativeUrl(String url, String baseUrl) {
    if (url.startsWith('http')) {
      return url;
    }
    return Uri.parse(baseUrl).resolve(url).toString();
  }

// Main parsing function
  Future<Map<String, dynamic>> parseHtml(String url) async {
    final htmlContent = await fetchWebpageContent(url);
    final document = html_parser.parse(htmlContent);
    final data = <String, dynamic>{};

    data['title'] = extractTitle(document);
    data['description'] = extractDescription(document);
    data['websiteName'] = extractWebsiteName(document);

    data['imageUrl'] = extractImageUrl(document);
    data['websiteLogoUrl'] = extractWebsiteLogo(document);

    // Handle relative URLs
    data['websiteLogo'] = handleRelativeUrl(
        data['websiteLogoUrl'] as String, url ?? url);
    data['imageUrl'] =
        handleRelativeUrl(data['imageUrl'] as String, url ?? url);

    // Fetch image as Uint8List
    data['imageAsBytes'] =
        await fetchImageAsUint8List(data['imageUrl'] as String? ?? url);
    data['logoAsBytes'] =
        await fetchImageAsUint8List(data['websiteLogo'] as String? ?? url);

    return data;
  }
}
