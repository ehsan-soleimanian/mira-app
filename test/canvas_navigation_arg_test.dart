import 'package:flutter_test/flutter_test.dart';
import 'package:mira_app/redesign/widgets/rd_bottom_nav.dart';

void main() {
  test('canvas navigation argument supports every home shortcut', () {
    final modes = <String>['board', 'clusters', 'map'];

    expect(
      modes.map((mode) => RdCanvasArg(mode).initialMode),
      orderedEquals(modes),
    );
  });

  test('canvas navigation argument rejects unknown modes', () {
    expect(() => RdCanvasArg('timeline'), throwsAssertionError);
  });
}
