import 'package:fpdart/src/either.dart';
import 'package:link_vault/core/errors/failure.dart';
import 'package:link_vault/src/splash/domain/entities/onboarding_page_entity.dart';
import 'package:link_vault/src/splash/domain/repositories/onboarding_repository.dart';

class OnboardingRepositoryImpl implements OnboardingRepository {
  @override
  Future<Either<Failure, List<OnboardingPageEntity>>> getOnboardingPages() async{
    final onboardingPages = <OnboardingPageEntity>[
      OnboardingPageEntity(
        title: 'Your Personal Link Sanctuary',
        description:
            'Tired of losing track of all your bookmarks? LinkVault makes it effortless to store, organize, and revisit your favorite web pages—all in one secure place.',
        imagePath: '',
      ),
      OnboardingPageEntity(
        title: 'Organize Links Your Way',
        description:
            'Create nested collections (folders within folders) to group links by project, topic, or mood. Drag, drop, and reorder to keep everything exactly where you need it.',
        imagePath: '',
      ),
      OnboardingPageEntity(
        title: 'Your Most Used Links, Front and Center',
        description:
            'Automatically see your most recently visited and pinned (favorite) links at the top. Perfect for daily routines, research, or quick reference.',
        imagePath: '',
      ),
    ];

    return Right(onboardingPages);
  }
}
