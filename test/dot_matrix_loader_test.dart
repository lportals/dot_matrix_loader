import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dot_matrix_loader/dot_matrix_loader.dart';

void main() {
  testWidgets('DotMatrixLoader renders without errors', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: DotMatrixLoader(
            preset: PulseRings(),
          ),
        ),
      ),
    );

    // Verify CustomPaint is present
    expect(find.byType(CustomPaint), findsWidgets);
  });

  testWidgets('DotMatrixLoader respects size parameter inline', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Row(
            children: [
              Text('Uploading'),
              DotMatrixLoader(
                preset: PulseRings(),
                size: 24.0,
              ),
            ],
          ),
        ),
      ),
    );

    final box = tester.renderObject(find.byType(DotMatrixLoader)) as RenderBox;
    expect(box.size.width, 24.0);
    expect(box.size.height, 24.0);
  });
}
