// ignore_for_file: public_member_api_docs

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:link_vault/routing/route_paths.dart';
import 'package:link_vault/src/app_initializaiton/presentation/blocs/onboarding_bloc/onboarding_bloc.dart';
import 'package:link_vault/src/app_initializaiton/presentation/widgets/onboarding_page_template.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class OnBoardingHomePage extends StatefulWidget {
  const OnBoardingHomePage({super.key});
  static const routeName = '/';

  @override
  State<OnBoardingHomePage> createState() => _OnBoardingHomePageState();
}

class _OnBoardingHomePageState extends State<OnBoardingHomePage> {
  final PageController _pageController = PageController();

  @override
  void initState() {
    context.read<OnboardingBloc>().add(LoadOnboardingPageEvent());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);
    return Scaffold(
      backgroundColor: themeData.primaryColor,
      body: BlocConsumer<OnboardingBloc, OnboardingState>(
        listener: (context, state) {
          if (state is OnboardingCompletedState) {
            context.go(RoutePaths.authHome);
          }
        },
        builder: (context, state) {
          if (state is OnboardingLoadingState) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is OnboardingLoadedState) {
            return Stack(
              children: [
                PageView.builder(
                  controller: _pageController,
                  itemCount: state.pages.length,
                  physics: const NeverScrollableScrollPhysics(),
                  onPageChanged: (index) {
                    context.read<OnboardingBloc>().add(PageChangedEvent(index));
                  },
                  itemBuilder: (context, index) {
                    final page = state.pages[index];
                    return OnBoardingPageTemplate(
                      title: page.title,
                      description: page.description,
                      imageUrl: page.imagePath,
                      pageNumber: index,
                    );
                  },
                ),
                // Bottom navigation and indicators
                Positioned(
                  bottom: 32,
                  left: 0,
                  right: 0,
                  child: Column(
                    children: [
                      // Dot indicators
                      SmoothPageIndicator(
                        controller: _pageController, // PageController
                        count: state.pages.length,
                        onDotClicked: (index) {
                          _pageController.animateToPage(
                            index,
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        },
                        effect: WormEffect(
                          activeDotColor: themeData.colorScheme.onSurface,
                          dotColor: Colors.grey.shade300,
                          dotHeight: 12,
                          strokeWidth: 4,
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Navigation buttons
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Skip button (hide on last page)
                            if (!state.isLastPage)
                              TextButton(
                                onPressed: () {
                                  context
                                      .read<OnboardingBloc>()
                                      .add(CompleteOnboardingEvent());
                                },
                                child: const Text('Skip'),
                              )
                            else
                              const SizedBox(width: 80),

                            // Next/Get Started button
                            ElevatedButton(
                              onPressed: () {
                                if (state.isLastPage) {
                                  context
                                      .read<OnboardingBloc>()
                                      .add(CompleteOnboardingEvent());
                                } else {
                                  _pageController.nextPage(
                                    duration: const Duration(milliseconds: 300),
                                    curve: Curves.easeInOut,
                                  );
                                }
                              },
                              child: Text(
                                state.isLastPage ? 'Get Started' : 'Next',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          } else if (state is OnboardingErrorState) {
            return Center(
              child: Text(
                'Error: ${state.message}',
              ),
            );
          } else {
            return const SizedBox.shrink();
          }
        },
      ),
    );
  }
}
