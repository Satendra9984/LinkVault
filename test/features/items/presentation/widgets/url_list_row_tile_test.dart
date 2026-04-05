import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:link_vault/features/items/domain/entities/item.dart';
import 'package:link_vault/features/items/presentation/widgets/url_list_row_tile.dart';

void main() {
  testWidgets('announces row semantics and triggers callbacks', (tester) async {
    final now = DateTime.now();
    final item = Item(
      id: 'item_1',
      collectionId: 'col_1',
      link: 'https://example.com/path',
      title: 'Example title',
      status: ItemStatus.unread,
      tags: 'work,important',
      createdAt: now.subtract(const Duration(days: 1)),
      updatedAt: now.subtract(const Duration(hours: 2)),
    );
    var tapped = false;
    var longPressed = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: UrlListRowTile(
            item: item,
            onTap: () => tapped = true,
            onLongPress: () => longPressed = true,
          ),
        ),
      ),
    );

    final semantics = tester.ensureSemantics();
    expect(find.text('Unread'), findsOneWidget);

    await tester.tap(find.text('Example title'));
    await tester.pump();
    expect(tapped, isTrue);

    await tester.longPress(find.text('Example title'));
    await tester.pump();
    expect(longPressed, isTrue);
    semantics.dispose();
  });
}
