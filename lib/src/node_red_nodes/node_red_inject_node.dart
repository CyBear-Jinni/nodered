import 'package:nodered/src/node_red_nodes/node_red_visual_node_abstract.dart';
import 'package:nodered/src/utils.dart';

class NodeRedInjectAtASpecificTimeNode extends NodeRedVisualNodeAbstract {
  NodeRedInjectAtASpecificTimeNode({
    required this.daysToRepeat,
    required this.hourToRepeat,
    required this.minutesToRepeat,
    super.tempId,
    super.name,
    super.wires,
  }) : super(
          type: 'inject',
        );

  List<String>? daysToRepeat;
  String? hourToRepeat;
  String? minutesToRepeat;

  @override
  String toString() {
    final String crontab =
        '$minutesToRepeat $hourToRepeat * * ${daysToRepeatAsCornTabRequire()}';
    return '''
    {
    "id": "$id",
    "type": "$type",
    "name": "$name",
    "props": [
        {
            "p": "payload"
        },
        {
            "p": "topic",
            "vt": "str"
        }
    ],
    "repeat": "",
    "crontab": "$crontab",
    "once": false,
    "onceDelay": 0.1,
    "x": 400,
    "y": 800,
    "topic": "",
    "payload": "",
    "payloadType": "date",
    "wires":  ${fixWiresForNodeRed()}
  }''';
  }

  String daysToRepeatAsCornTabRequire() {
    if (daysToRepeat!.length >= 7) {
      return '*';
    }
    String daysToRepeatTemp = '';

    for (final String dayToRepeat in daysToRepeat!) {
      if (daysToRepeatTemp != '') {
        daysToRepeatTemp += ',';
      }

      if (dayToRepeat == 'sunday') {
        daysToRepeatTemp += '0';
      } else if (dayToRepeat == 'monday') {
        daysToRepeatTemp += '1';
      } else if (dayToRepeat == 'tuesday') {
        daysToRepeatTemp += '2';
      } else if (dayToRepeat == 'wednesday') {
        daysToRepeatTemp += '3';
      } else if (dayToRepeat == 'thursday') {
        daysToRepeatTemp += '4';
      } else if (dayToRepeat == 'friday') {
        daysToRepeatTemp += '5';
      } else if (dayToRepeat == 'saturday') {
        daysToRepeatTemp += '6';
      } else {
        daysToRepeatTemp += 'Error';
        logger.e('Day does not exist');
      }
    }
    return daysToRepeatTemp;
  }
}
