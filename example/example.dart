import 'package:dirb_engine/dirb_engine.dart';

void main() async {
  final engine = DirbEngine();
  await engine.initialize();
  print('DirbEngine is ready for tactical operations.');
}
