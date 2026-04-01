import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failures.dart';
import '../models/url_items_query.dart';
import '../repositories/i_items_repository.dart';

class QueryUrlItemsUseCase {
  QueryUrlItemsUseCase(this._repository);

  final IItemsRepository _repository;

  Future<Either<Failure, UrlItemsPage>> call(UrlItemsQuery query) {
    return _repository.queryUrlItems(query);
  }
}
