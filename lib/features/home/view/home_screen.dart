import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:money_fit/core/widgets/ads/ad_banner_widget.dart';
import 'package:money_fit/features/home/viewmodel/home_data_provider.dart';
import 'package:money_fit/features/home/widgets/home_date_header.dart';
import 'package:money_fit/features/home/widgets/home_main_card.dart';
import 'package:money_fit/features/home/widgets/home_action_buttons.dart';
import 'package:money_fit/features/settings/viewmodel/user_settings_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final homeStateAsync = ref.watch(homeViewModelProvider);
    final userAsync = ref.watch(userSettingsProvider);

    // 모든 로딩 상태
    if (homeStateAsync.isLoading || userAsync.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // 오류 처리
    if (homeStateAsync.hasError || userAsync.hasError) {
      final error = homeStateAsync.error ?? userAsync.error;
      return Scaffold(body: Center(child: Text('오류가 발생했습니다: $error')));
    }

    // 값이 있을 때
    final homeState = homeStateAsync.value!;
    final user = userAsync.value!;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: SingleChildScrollView(
            child: Column(
              children: [
                const AdBannerWidget(screenType: ScreenType.home),
                const SizedBox(height: 10),
                const HomeDateHeader(),
                const SizedBox(height: 10),
                HomeMainCard(homeState: homeState),
                const SizedBox(height: 20),
                HomeActionButtons(homeState: homeState, userId: user.id),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
