import '../entities/collection.dart';
import '../repositories/i_collections_repository.dart';

class WatchCollectionsUseCase {
  final ICollectionsRepository repository;

  WatchCollectionsUseCase(this.repository);

  Stream<List<Collection>> call() {
    return repository.watchCollections();
  }
}
