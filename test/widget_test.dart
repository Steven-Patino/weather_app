import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:weather_app/main.dart';

void main() {
  testWidgets('smoke test for the weather app', (WidgetTester tester) async {
    dotenv.testLoad(fileInput: 'OPENWEATHER_API_KEY=test');
    await tester.pumpWidget(const MyApp());
    await tester.pump();

    expect(find.text('Clima App'), findsOneWidget);
  });
}
