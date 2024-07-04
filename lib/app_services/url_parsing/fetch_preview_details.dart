import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:html/parser.dart';
import 'package:http/http.dart';

class FetchPreviewDetails {
  Future<Map<String, dynamic>> fetch(String url) async {
    final client = Client();
    final response = await client.get(Uri.parse(_validateUrl(url)));
    final document = parse(response.body);

    String? title;
    String? description;
    String? image;
    Map<String, dynamic>? desc;
    final element = document.getElementsByTagName('meta');
    for (final tmg in element) {
      if (tmg.attributes['property'] == 'og:title') {
        title = tmg.attributes['content'];
      }

      // do : handle exception in next line
      // debugPrint('title--> $title');
      try {
        title ??= document.getElementsByTagName('title')[0].text;
      } catch (e) {
        // todo: get title
        title = getTitle(url);
      }

      if (tmg.attributes['property'] == 'og:description') {
        description = tmg.attributes['content'];
      }

      if (tmg.attributes['property'] == 'og:image') {
        image = tmg.attributes['content'];
      }

      final linkElements = document.getElementsByTagName('link');
      for (final element in linkElements) {
        if (image == null &&
            element.attributes['rel']?.contains('icon') == true) {
          image = element.attributes['href'];
        }
      }
      // print('image url inlink --> $image\n');
    }

    image ??=
        'https://t1.gstatic.com/faviconV2?client=SOCIAL&type=FAVICON&fallback_opts=TYPE,SIZE,URL&url=$url&size=64';

    // get height and width of the image
    if (image.startsWith('/')) {
      image = '$url$image';
    }
    // print('image sent for unit8 --> $image');
    final imageUint = await getUint8List(image);
    final faviconUint = await getUint8List(
      'https://t1.gstatic.com/faviconV2?client=SOCIAL&type=FAVICON&fallback_opts=TYPE,SIZE,URL&url=$url&size=64',
    );
    desc = await getImageInfo(image);

    // if (kDebugMode) {
    //   print('url title --> $title\n');
    //   print('url description --> $description\n');
    //   print('url image --> $image\n\n');
    // }

    return {
      'favicon': faviconUint,
      'image': imageUint,
      'image_title': title ?? 'No title available',
      'description': description ?? 'No description available',
      'size': {
        'height': desc['height'] ?? 0,
        'width': desc['width'] ?? 0,
      },
    };
  }

  String _validateUrl(String url) {
    if (url.startsWith('http://') == true ||
        url.startsWith('https://') == true) {
      return url;
    } else {
      return 'https://$url';
    }
  }

  Future<Map<String, dynamic>> getImageInfo(String webUrl) async {
    try {
      final  completer = Completer<Size>();
      final image = Image.network(webUrl);
      image.image
          .resolve(
            const ImageConfiguration(),
          )
          .addListener(
            ImageStreamListener(
              (ImageInfo image, bool synchronousCall) {
                final myImage = image.image;
                final size =
                    Size(myImage.width.toDouble(), myImage.height.toDouble());
                completer.complete(size);
              },
              onError: (object, stackTrace) {
                const size = Size(0, 0);
                completer.complete(size);
              },
            ),
          );

      final info = completer.future;

      return info.then(
        (value) {
          return {
            'height': value.height,
            'width': value.width,
          };
        },
      );
    } catch (e) {
      return {
        'height': 0,
        'width': 0,
      };
    }
  }

  String getTitle(String url) {
    var title = url;

    if (title.startsWith('https://')) {
      title = title.substring(8, title.length);
      // debugPrint('gettitle1 --> $title');
    }
    if (title.startsWith('www.')) {
      title = title.substring(4, title.length);
      // debugPrint('gettitle2 --> $title');
    }
    final  firstSlashIndex = title.indexOf('/');
    if (firstSlashIndex != -1) {
      debugPrint(firstSlashIndex.toString());
      title = title.substring(0, firstSlashIndex);
      // debugPrint('gettitle3 --> $title');
    }
    if (title.endsWith('.com')) {
      title = title.substring(0, title.length - 4);
      // debugPrint('gettitle4 --> $title');
    }

    return title;
  }

  Future<Uint8List> getUint8List(String url) async {
    // print('url for uint8 --> $url');
    try {
      final bytes = (await NetworkAssetBundle(Uri.parse(url)).load(url))
          .buffer
          .asUint8List();

      return bytes;
    } catch (e) {
      try {
        final bytes = (await NetworkAssetBundle(Uri.parse(url)).load(
          'https://t1.gstatic.com/faviconV2?client=SOCIAL&type=FAVICON&fallback_opts=TYPE,SIZE,URL&url=$url&size=64',
        ))
            .buffer
            .asUint8List();

        return bytes;
      } catch (e) {
        // Uint8 bytes = await rootBundle.load('assets/images/click.png');
        final bytes0 =
            await rootBundle.load('assets/images/click3d.png');
        final list = bytes0.buffer.asUint8List();

        return list;
      }
    }
  }
}

// todo : remove below error
/*
E/flutter ( 5148): [ERROR:flutter/lib/ui/ui_dart_state.cc(198)] Unhandled Exception: HandshakeException: Handshake error in client (OS Error:
E/flutter ( 5148): 	CERTIFICATE_VERIFY_FAILED: unable to get local issuer certificate(handshake.cc:393))
E/flutter ( 5148): #0      _SecureFilterImpl._handshake (dart:io-patch/secure_socket_patch.dart:99:46)
E/flutter ( 5148): #1      _SecureFilterImpl.handshake (dart:io-patch/secure_socket_patch.dart:142:25)
E/flutter ( 5148): #2      _RawSecureSocket._secureHandshake (dart:io/secure_socket.dart:911:54)
E/flutter ( 5148): #3      _RawSecureSocket._tryFilter (dart:io/secure_socket.dart:1040:19)
E/flutter ( 5148): <asynchronous suspension>
E/flutter ( 5148):
*/
