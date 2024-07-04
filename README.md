# link_vault

## Feature - Offline Viewing and Text Highlighting
To enable offline viewing and highlighting of websites in your app, you'll need to follow a series of steps to save web content, allow users to view and interact with it offline, and provide functionality for highlighting and annotating. Below is a high-level overview and a more detailed approach to achieve this:

### High-Level Overview

1. **Save Web Content for Offline Use**
   - Fetch and store the HTML content of the website.
   - Save related assets like CSS, JavaScript, and images.
   - Use a local database or file storage to save the content.

2. **Display Web Content Offline**
   - Load saved HTML content into a WebView.
   - Ensure assets are loaded from local storage.

3. **Highlighting and Annotation**
   - Provide functionality to highlight text.
   - Save highlighted text and annotations.
   - Restore highlights and annotations when the page is reloaded.

4. **Sync Annotations (Optional)**
   - If users want their highlights and annotations to be available across devices, implement a synchronization mechanism using a cloud database like Firebase.

### Detailed Approach

#### 1. Save Web Content for Offline Use

**Step 1: Fetch and Store HTML Content**
- Use an HTTP client to fetch the HTML content.
- Save the HTML content to local storage or a local database.

```dart
import 'package:http/http.dart' as http;

Future<void> saveWebContent(String url) async {
  final response = await http.get(Uri.parse(url));
  if (response.statusCode == 200) {
    final htmlContent = response.body;
    // Save htmlContent to local storage or database
  } else {
    throw Exception('Failed to load webpage');
  }
}
```

**Step 2: Save Related Assets**
- Parse the HTML to find and download related assets (CSS, JavaScript, images).
- Store these assets in the local storage.

```dart
import 'package:html/parser.dart';

void parseAndSaveAssets(String htmlContent) {
  var document = parse(htmlContent);
  var links = document.getElementsByTagName('link');
  var scripts = document.getElementsByTagName('script');
  var images = document.getElementsByTagName('img');

  // Download and save these assets similarly to how HTML was saved
}
```

#### 2. Display Web Content Offline

**Step 3: Load HTML Content in WebView**
- Load the saved HTML content into a WebView.
- Ensure the WebView loads assets from local storage.

```dart
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class OfflineWebView extends StatelessWidget {
  final String htmlFilePath;

  OfflineWebView(this.htmlFilePath);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Offline Web View')),
      body: WebView(
        initialUrl: 'file://$htmlFilePath',
        javascriptMode: JavascriptMode.unrestricted,
      ),
    );
  }
}
```

#### 3. Highlighting and Annotation

**Step 4: Enable Text Highlighting**
- Use JavaScript to enable text highlighting within the WebView.
- Inject JavaScript into the WebView to handle text selection and highlighting.

```html
<script>
  document.addEventListener('mouseup', function() {
    var selection = window.getSelection();
    if (selection.toString().length > 0) {
      var range = selection.getRangeAt(0);
      var newNode = document.createElement('span');
      newNode.setAttribute('style', 'background-color: yellow;');
      range.surroundContents(newNode);
    }
  });
</script>
```

**Step 5: Save Highlights and Annotations**
- Store highlighted text and annotations in local storage or a local database.

```dart
void saveHighlights(String pageId, String highlightedText) {
  // Save the highlighted text with the page ID
}
```

**Step 6: Restore Highlights and Annotations**
- When the page is reloaded, retrieve the highlights and annotations and reapply them.

```html
<script>
  document.addEventListener('DOMContentLoaded', function() {
    // Fetch highlights from local storage or database and apply them
  });
</script>
```

#### 4. Sync Annotations (Optional)

**Step 7: Sync Highlights and Annotations**
- Use a cloud database like Firebase to sync highlights and annotations across devices.

```dart
import 'package:cloud_firestore/cloud_firestore.dart';

void syncHighlights(String userId, String pageId, String highlightedText) {
  FirebaseFirestore.instance.collection('highlights').add({
    'userId': userId,
    'pageId': pageId,
    'highlightedText': highlightedText,
  });
}
```

### Summary

By following these steps, you can implement offline viewing and highlighting functionality in your app. This approach involves fetching and storing web content, displaying it offline using WebView, enabling and saving text highlights, and optionally syncing annotations across devices. The implementation can be adapted and extended based on your specific requirements and use cases.