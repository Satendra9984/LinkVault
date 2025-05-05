import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:link_vault/src/splash/presentation/pages/splash_screen_template.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: Text('Splash'),
      // ),
      body: PageView(
        children: const [
          SplashScreenTemplate(
            title: 'Your Personal Link Sanctuary',
            description: 'Tired of losing track of all your bookmarks? LinkVault makes it effortless to store, organize, and revisit your favorite web pages—all in one secure place.',
            imageUrl: '',
            pageNumber: 1,
          ),
          SplashScreenTemplate(
            title: 'Organize Links Your Way',
            description: 'Create nested collections (folders within folders) to group links by project, topic, or mood. Drag, drop, and reorder to keep everything exactly where you need it.',
            imageUrl: '',
            pageNumber: 2,
          ),
          // SplashScreenTemplate(
          //   title: '',
          //   description: '',
          //   imageUrl: '',
          //   pageNumber: ,
          // ),
        ],
      ),
    );
  }
}
