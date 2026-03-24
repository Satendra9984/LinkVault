import 'package:link_vault/core/errors/failures.dart';
import 'package:fpdart/fpdart.dart';
import '../entities/app_settings.dart';

abstract class ISettingsRepository {
  Future<Either<Failure, AppSettings>> getSettings();
  Stream<Either<Failure, AppSettings>> watchSettings();
  Future<Either<Failure, void>> updateSettings(AppSettings settings);
}
