import 'package:flutter_test/flutter_test.dart';
import 'package:dirb_engine/dirb_engine.dart';

void main() {
  test('DirbEngine initialization test', () async {
    final engine = DirbEngine();
    await engine.initialize();
    expect(engine.isInitialized, true);
  });
}
