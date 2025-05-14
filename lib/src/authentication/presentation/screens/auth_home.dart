import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:link_vault/routing/route_paths.dart';

class AuthHome extends StatelessWidget {
  const AuthHome({super.key});

  @override
  Widget build(BuildContext context) {
    final appThemeData = Theme.of(context);
    final appTextThemeData = appThemeData.textTheme;
    final appColorThemeData = appThemeData.colorScheme;

    return Scaffold(
      backgroundColor: appColorThemeData.surface,
      appBar: AppBar(
        backgroundColor: appColorThemeData.surface,
        actions: [
          TextButton(
            onPressed: () {},
            child: Text(
              'skip',
              style: appTextThemeData.bodyLarge,
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 20,
          horizontal: 24,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Welcome To LinkVault',
              style: appTextThemeData.headlineMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Text(
              "Let's get started in organizing your scattered useful urls in one place for peace of mind.",
              style: appTextThemeData.bodySmall?.copyWith(
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => context.go(RoutePaths.login),
                    style: appThemeData.elevatedButtonTheme.style,
                    child: Text(
                      'Login',
                      style: appTextThemeData.titleMedium?.copyWith(
                        color: appColorThemeData.onPrimary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 24),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => context.go(RoutePaths.signUp),
                    style: appThemeData.outlinedButtonTheme.style,
                    child: Text(
                      'Sign Up',
                      style: appTextThemeData.titleMedium,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
