import 'package:objectbox/objectbox.dart';

import '../../../../objectbox.g.dart';
import '../../../collections/data/models/collection_model.dart';
import '../../../collections/data/models/search_history_model.dart';
import '../../../items/data/models/item_model.dart';

/// Removes all local collections, URLs (items), and search history from ObjectBox.
/// Does not touch [AuthSettingsModel] or cloud data.
class ClearLocalLibraryUseCase {
  ClearLocalLibraryUseCase(this._store);

  final Store _store;

  Future<void> call() async {
    _store.runInTransaction(TxMode.write, () {
      _store.box<CollectionModel>().removeAll();
      _store.box<ItemModel>().removeAll();
      _store.box<SearchHistoryModel>().removeAll();
    });
  }
}
