import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

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
              children: const [
                OnboardingPage(
                  imagePath: 'assets/images/onboarding_1.png',
                  title: '복잡한 가계부는 이제 그만',
                  description: '매일의 지출을 간편하게 관리하고,\n건강한 소비 습관을 만들어보세요.',
                ),
                OnboardingPage(
                  imagePath: 'assets/images/onboarding_2.png',
                  title: '한 눈에 확인 가능한 하루 예산',
                  description: '오늘 남은 예산을 파악하고,\n계획적인 소비를 시작하세요.',
                ),
                OnboardingPage(
                  imagePath: 'assets/images/onboarding_3.png',
                  title: '성취의 기록이 꾸준한 습관으로',
                  description: '매일의 도전을 성취로 채우고,\n돈 관리의 재미를 느껴보세요.',
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
          SizedBox(height: 50),
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
        color: _currentPage == index
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
                  '/daily_budget_setup',
                ); // Navigate to daily budget setup screen
              },
              style: ElevatedButton.styleFrom(),
              child: Text(
                '다음으로',
                style: Theme.of(context).textTheme.labelLarge,
              ),
            ),
        ],
      ),
    );
  }
}
