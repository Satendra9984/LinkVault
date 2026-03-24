import '../../../../objectbox.g.dart';
import '../../domain/entities/app_settings.dart' as domain;
import '../../domain/repositories/i_settings_repository.dart';
import '../models/app_settings_model.dart' as data;
import '../mappers/app_settings_mapper.dart';
import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failures.dart';

class SettingsRepositoryImpl implements ISettingsRepository {
  final Store _store;

  SettingsRepositoryImpl(this._store);

  @override
  Future<Either<Failure, domain.AppSettings>> getSettings() async {
    try {
      final box = _store.box<data.AppSettingsModel>();
      final first = box.query().build().findFirst();

      if (first != null) {
        return Right(AppSettingsMapper.toEntity(first));
      } else {
        // Return default
        return const Right(domain.AppSettings(id: 0));
      }
    } catch (e, stackTrace) {
      return Left(DatabaseFailure('Failed to get settings',
          error: e, stackTrace: stackTrace));
    }
  }

  @override
  Stream<Either<Failure, domain.AppSettings>> watchSettings() {
    final box = _store.box<data.AppSettingsModel>();
    return box.query().watch(triggerImmediately: true).map((query) {
      final models = query.find();
      if (models.isNotEmpty) {
        return Right<Failure, domain.AppSettings>(
            AppSettingsMapper.toEntity(models.first));
      } else {
        return const Right<Failure, domain.AppSettings>(
            domain.AppSettings(id: 0));
      }
    }).handleError((e, stackTrace) {
      return Left<Failure, domain.AppSettings>(
          DatabaseFailure('Stream error', error: e, stackTrace: stackTrace));
    });
  }

  @override
  Future<Either<Failure, void>> updateSettings(
      domain.AppSettings settings) async {
    try {
      final model = AppSettingsMapper.toModel(settings);
      final box = _store.box<data.AppSettingsModel>();
      
      _store.runInTransaction(TxMode.write, () {
        // Check if exists
        final existing = box.query().build().findFirst();
        if (existing != null) {
          model.id = existing.id;
        }
        box.put(model);
      });
      return const Right(null);
    } catch (e, stackTrace) {
      return Left(DatabaseFailure('Failed to update settings',
          error: e, stackTrace: stackTrace));
    }
  }
}
