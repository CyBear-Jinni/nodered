import 'package:nodered/nodered.dart';
import 'package:nodered/src/utils.dart';

void main() {
  NodeRedAPI nodeRed = NodeRedAPI();
  logger.i('IP ${nodeRed.address} port ${nodeRed.port}');
}
