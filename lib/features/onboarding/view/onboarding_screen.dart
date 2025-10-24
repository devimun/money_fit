import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:money_fit/l10n/app_localizations.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: (int page) {
                setState(() {
                  _currentPage = page;
                });
              },
              children: [
                OnboardingPage(
                  imagePath: 'assets/images/onboarding_1.png',
                  title: l10n.onboardingTitle1,
                  description: l10n.onboardingDescription1,
                ),
                OnboardingPage(
                  imagePath: 'assets/images/onboarding_2.png',
                  title: l10n.onboardingTitle2,
                  description: l10n.onboardingDescription2,
                ),
                OnboardingPage(
                  imagePath: 'assets/images/onboarding_3.png',
                  title: l10n.onboardingTitle3,
                  description: l10n.onboardingDescription3,
                  isLastPage: true,
                ),
              ],
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              3, // Total number of onboarding pages
              (index) => buildDot(index, context),
            ),
          ),
          const SizedBox(height: 50),
        ],
      ),
    );
  }

  Widget buildDot(int index, BuildContext context) {
    return Container(
      height: 10,
      width: _currentPage == index ? 24 : 10,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color:
            _currentPage == index
                ? Theme.of(context).primaryColor
                : Colors.grey,
        borderRadius: BorderRadius.circular(5),
      ),
    );
  }
}

class OnboardingPage extends ConsumerWidget {
  const OnboardingPage({
    super.key,
    required this.imagePath,
    required this.title,
    required this.description,
    this.isLastPage = false,
  });

  final String imagePath;
  final String title;
  final String description;
  final bool isLastPage;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            filterQuality: FilterQuality.high,
            imagePath,
            height: MediaQuery.of(context).size.height * 0.4,
          ),
          const SizedBox(height: 40),
          Text(
            title,
            style: Theme.of(context).textTheme.displayMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          Text(
            description,
            style: Theme.of(context).textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 60),
          if (isLastPage)
            ElevatedButton(
              onPressed: () async {
                context.go(
                  '/budget_setup',
                ); // Navigate to daily budget setup screen
              },
              style: ElevatedButton.styleFrom(),
              child: Text(
                l10n.next,
                style: Theme.of(context).textTheme.labelLarge,
              ),
            ),
        ],
      ),
    );
  }
}
