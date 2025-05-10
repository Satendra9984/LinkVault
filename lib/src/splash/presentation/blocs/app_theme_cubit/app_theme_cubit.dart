import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';
import 'package:link_vault/core/errors/failure.dart';
import 'package:link_vault/core/theme/app_theme_enums.dart';
import 'package:link_vault/src/splash/domain/usecases/save_thememode_usecase.dart';
import 'package:link_vault/src/splash/domain/usecases/watch_themedata_usecase.dart';

part 'app_theme_state.dart';

class AppThemeCubit extends Cubit<ThemeState> {
  final WatchThemedataUsecase _watchThemedataUsecase;
  final SaveThememodeUsecase _saveThememodeUsecase;
  StreamSubscription<Either<Failure, AppThemeEnums>>? _themeSubscription;

  AppThemeCubit(
    this._watchThemedataUsecase,
    this._saveThememodeUsecase,
  ) : super(
          AppThemeState(AppThemeEnums.light),
        ) {
    _themeSubscription ??= _watchThemedataUsecase.call().listen(
      (themeRes) {
        themeRes.fold(
          (_) {},
          (appTheme) {
            emit(AppThemeState(appTheme));
          },
        );
      },
    );
  }

  Future<void> setThemeMode(AppThemeEnums appTheme) async {
    await _saveThememodeUsecase(appTheme);
  }

  @override
  Future<void> close() {
    _themeSubscription?.cancel();
    return super.close();
  }
}
