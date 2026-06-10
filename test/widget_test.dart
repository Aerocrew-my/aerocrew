import 'package:flutter_test/flutter_test.dart';
import 'package:aerocrew/main.dart';

void main() {
  testWidgets('AeroCrew smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const AeroCrewApp());
  });
}