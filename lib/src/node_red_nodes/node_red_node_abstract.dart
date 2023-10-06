import 'package:nodered/src/utils.dart';
import 'package:uuid/uuid.dart';

class NodeRedNodeAbstract {
  NodeRedNodeAbstract({
    required this.type,
    String? tempId,
    this.name,
  }) {
    id = tempId ?? const Uuid().v1();
  }

  String type;

  /// The id of the node, will create one for you if not given
  late String id;
  String? name;

  @override
  String toString() {
    logger.e('Abstract class does not support to string');
    throw 'Abstract class does not support to string';
  }
}
