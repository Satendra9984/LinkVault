import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:link_vault/core/common/views/page_under_construction.dart';
import 'package:link_vault/src/onboarding/presentation/pages/onboarding_home.dart';

Route<dynamic> generateRoute(RouteSettings settings) {
  switch (settings.name) {
    case OnBoardingHomePage.routeName:
      {
        return _pageRouteBuilder(
          (_) => const OnBoardingHomePage(),
          settings: settings,
        );
      }
    default:
      {
        return _pageRouteBuilder(
          (_) => const PageUnderConstructionPage(),
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
