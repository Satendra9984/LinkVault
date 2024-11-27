import 'package:flutter/material.dart';
import 'package:link_vault/core/common/presentation_layer/pages/page_under_construction.dart';
import 'package:link_vault/src/onboarding/presentation/pages/onboarding_home.dart';

import 'package:link_vault/src/subsciption/presentation/pages/subscription_page.dart';

Route<dynamic> generateRoute(RouteSettings settings) {
  switch (settings.name) {
    case OnBoardingHomePage.routeName:
      {
        return MaterialPageRoute(
          builder: (context) => const OnBoardingHomePage(),
          settings: settings,
        );
      }
    case SubscriptionPage.routeName:
      {
        return MaterialPageRoute(
          builder: (context) => const SubscriptionPage(),
          settings: settings,
        );
      }
    default:
      {
        return MaterialPageRoute(
          builder: (context) => const PageUnderConstructionPage(),
          settings: settings,
        );
      }
  }
}

PageRouteBuilder<dynamic> _pageRouteBuilder(
  Widget Function(BuildContext) page, {
  required RouteSettings settings,
}) {
  return PageRouteBuilder(
    settings: settings,
    transitionsBuilder: (_, animation, __, child) {
      return FadeTransition(
        opacity: animation,
        child: child,
      );
    },
    pageBuilder: (context, _, __) {
      return page(context);
    },
  );
}
