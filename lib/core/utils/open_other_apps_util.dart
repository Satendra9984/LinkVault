import 'package:url_launcher/url_launcher.dart';

class OpenOtherApps {
  OpenOtherApps._();

  static Future<void> openGmailApp() async {
// Replace with your email address
    // const email = 'example@gmail.com';
    const email = 'googlegmail://';

    final emailLaunchUri = Uri(
      scheme: 'mailto',
      // path: email,
    );

    if (await canLaunchUrl(emailLaunchUri)) {
      await launchUrl(emailLaunchUri);
    } else {
      throw Exception('Could not launch $email', );
    }
  }
}
