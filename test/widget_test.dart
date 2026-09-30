import 'package:flutter_test/flutter_test.dart';
import 'package:nirmaan/main.dart';
import 'package:nirmaan/core/constants/app_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('App renders SplashScreen and branding',
      (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(const NirmaanApp());

    // Verify Nirmaan branding appears
    expect(find.text(AppConstants.appName), findsOneWidget);
    expect(find.text(AppConstants.appTagline.toUpperCase()), findsOneWidget);

    // Advance past splash timer to settle pending navigation cleanly
    await tester.pump(const Duration(milliseconds: 2000));
    await tester.pumpAndSettle();
  });
}
