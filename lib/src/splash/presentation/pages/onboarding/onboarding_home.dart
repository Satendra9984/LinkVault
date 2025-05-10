// ignore_for_file: public_member_api_docs

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:link_vault/src/splash/presentation/blocs/onboarding_bloc/onboarding_bloc.dart';
import 'package:link_vault/src/splash/presentation/widgets/onboarding_page_template.dart';
import 'package:link_vault/src/on_boarding/presentation/widgets/template.dart';

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
    return Scaffold(
      backgroundColor: Colors.white,
      body: BlocConsumer<OnboardingBloc, OnboardingState>(
        listener: (context, state) {
          if (state is OnboardingCompletedState) {
            // TODO: GO TO AUTH
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
              ],
            );
          } else if (state is OnboardingErrorState) {
            return Center(child: Text('Error: ${state.message}'));
          } else {
            return const SizedBox.shrink();
          }
        },
      ),
    );
  }
}
