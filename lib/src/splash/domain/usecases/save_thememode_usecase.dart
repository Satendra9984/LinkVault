import 'package:fpdart/fpdart.dart';
import 'package:link_vault/core/errors/failure.dart';
import 'package:link_vault/core/theme/app_theme_enums.dart';
import 'package:link_vault/src/splash/domain/repositories/splash_repository.dart';

class SaveThememodeUsecase {
  final LocalAppSettingsRepository repository;

  SaveThememodeUsecase(this.repository);

  Future<Either<Failure, void>> call(AppThemeEnums appTheme) =>
      repository.saveThemeData(appTheme);
}
