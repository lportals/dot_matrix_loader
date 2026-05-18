import 'package:flutter_test/flutter_test.dart';
import 'package:dot_matrix_loader_example/main.dart';

void main() {
  testWidgets('Dot Matrix App Navigation Smoke Test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const DotMatrixApp());
    // Pump frames for a short duration to let the widgets render, 
    // avoiding pumpAndSettle since we have infinite repeat animations.
    await tester.pump(const Duration(milliseconds: 500));

    // Verify Showcase and Sequence tabs exist in the layout
    expect(find.text('Showcase'), findsWidgets);
    expect(find.text('Sequence'), findsWidgets);

    // Verify our newly added Examples tab is rendered successfully
    expect(find.text('Examples'), findsWidgets);
  });
}
