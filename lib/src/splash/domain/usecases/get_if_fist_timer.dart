import 'package:link_vault/src/splash/domain/repositories/splash_repository.dart';

class GetIfFistTimer {
  final SplashRepository _splashRepository;

  GetIfFistTimer(SplashRepository splashRepo) : _splashRepository = splashRepo;

  Future<bool> call() => _splashRepository.getIfSeenOnboarding();
}
