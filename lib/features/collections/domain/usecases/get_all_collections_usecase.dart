import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failures.dart';
import '../entities/collection.dart';
import '../repositories/i_collections_repository.dart';

class GetAllCollectionsUseCase {
  final ICollectionsRepository _repository;

  GetAllCollectionsUseCase(this._repository);

  Future<Either<Failure, List<Collection>>> call() {
    return _repository.getAllCollections();
  }
}
