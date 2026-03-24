import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_markdown/flutter_markdown.dart';

class LegalPolicyScreen extends StatelessWidget {
  const LegalPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Legal & Privacy'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Privacy Policy'),
              Tab(text: 'Terms of Service'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _MarkdownLoader(assetPath: 'docs/08_OPERATIONS/Privacy_Policy.md'),
            _MarkdownLoader(
                assetPath: 'docs/08_OPERATIONS/Terms_Of_Service.md'),
          ],
        ),
      ),
    );
  }
}

class _MarkdownLoader extends StatelessWidget {
  final String assetPath;

  const _MarkdownLoader({required this.assetPath});

  Future<String> _loadAsset() async {
    return await rootBundle.loadString(assetPath);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: _loadAsset(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Error loading document: ${snapshot.error}\n\nMake sure $assetPath is in pubspec assets.',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red),
              ),
            ),
          );
        } else if (snapshot.hasData) {
          return Markdown(
            data: snapshot.data!,
            styleSheet: MarkdownStyleSheet(
              h1: Theme.of(context).textTheme.headlineMedium,
              h2: Theme.of(context).textTheme.titleLarge,
              h2Padding: const EdgeInsets.only(top: 16),
              p: Theme.of(context).textTheme.bodyMedium,
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}
