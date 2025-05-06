// ignore_for_file: public_member_api_docs

import 'package:flutter/material.dart';
import 'package:link_vault/src/on_boarding/presentation/screens/widgets/onboarding_page_template.dart';

class OnBoardingHomePage extends StatelessWidget {
  const OnBoardingHomePage({super.key});
  static const routeName = '/';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: PageView(
        children: const [
          OnBoardingPageTemplate(
            title: 'Your Personal Link Sanctuary',
            description:
                'Tired of losing track of all your bookmarks? LinkVault makes it effortless to store, organize, and revisit your favorite web pages—all in one secure place.',
            imageUrl: '',
            pageNumber: 1,
          ),
          OnBoardingPageTemplate(
            title: 'Organize Links Your Way',
            description:
                'Create nested collections (folders within folders) to group links by project, topic, or mood. Drag, drop, and reorder to keep everything exactly where you need it.',
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
