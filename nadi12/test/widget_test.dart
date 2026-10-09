import 'package:flutter_test/flutter_test.dart';
import 'package:nadi_gym/main.dart';

void main() {
  testWidgets('App initializes with splash screen and NADI branding', (WidgetTester tester) async {
    await tester.pumpWidget(const NadiGymApp());

    // NADI logo branding should be present
    expect(find.text('NADI'), findsWidgets);
  });
}
