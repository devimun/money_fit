import 'package:flutter_test/flutter_test.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:money_fit/features/monetization/widgets/ad_banner_widget.dart';

void main() {
  test('adaptive banner slot uses the creative height instead of 58px', () {
    expect(adaptiveBannerSlotHeight(AdSize.banner), 58);
    expect(adaptiveBannerSlotHeight(AdSize.largeBanner), 108);
  });
}
