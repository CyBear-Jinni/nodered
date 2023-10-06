import 'package:nodered/nodered.dart';
import 'package:nodered/src/utils.dart';
import 'package:uuid/uuid.dart';

class EspHomeNodeRedApi {
  EspHomeNodeRedApi({
    required this.repository,
    required this.nodeRedApiBaseTopic,
    required this.nodeRedDevicesTopic,
    this.nodeRedMqttBrokerNodeName = 'NodeRed plugs Api Broker',
  });

  final INodeRedRepository repository;
  final String nodeRedApiBaseTopic;
  final String nodeRedDevicesTopic;
  final String nodeRedMqttBrokerNodeName;

  static String module = 'node-red-contrib-esphome';

  static String deviceStateProperty = 'deviceStateProperty';
  static String inputDeviceProperty = 'inputDeviceProperty';
  static String outputDeviceProperty = 'outputDeviceProperty';

  // Returns the espHome device node id
  Future<void> setNewGlobalEspHomeDeviceNode({
    required String deviceMdnsName,
    required String password,
    String? espHomeDeviceId,
  }) async {
    String nodes = '[\n';

    final String espHomeDeviceIdTemp = espHomeDeviceId ?? Uuid().v1();

    /// Device connection
    final NodeRedEspHomeDeviceNode nodeRedEspHomeDeviceNode =
        NodeRedEspHomeDeviceNode(
      tempId: espHomeDeviceIdTemp,
      host: '$deviceMdnsName.local',
      name: 'ESPHome $deviceMdnsName device id $espHomeDeviceIdTemp',
      password: password,
    );
    nodes += nodeRedEspHomeDeviceNode.toString();

    nodes += '\n]';

    /// Setting the flow
    final String response = await repository.setGlobalNodes(
      moduleToUse: module,
      nodes: nodes,
    );
    if (response != 'ok') {
      logger.e('Error setting ESPHome device node\n$response');
    }
  }

  Future<String> setNewStateNodes({
    required String flowId,
    required String entityId,
    required String espHomeDeviceId,
  }) async {
    String nodes = '[\n';

    const String mqttNodeName = 'Esphome';

    final String topic =
        '$nodeRedApiBaseTopic/$nodeRedDevicesTopic/$entityId/$deviceStateProperty';

    /// Mqtt broker
    final NodeRedMqttBrokerNode mqttBrokerNode =
        NodeRedMqttBrokerNode(name: nodeRedMqttBrokerNodeName);

    nodes += mqttBrokerNode.toString();

    /// Mqtt out

    final NodeRedMqttOutNode mqttOutNode = NodeRedMqttOutNode(
      brokerNodeId: mqttBrokerNode.id,
      topic: '$topic/$outputDeviceProperty',
      name: '$mqttNodeName - $outputDeviceProperty',
    );
    nodes += ', $mqttOutNode';

    /// Create an EspHome in node
    final NodeRedEspHomeInNode nodeRedEspHomeInNode = NodeRedEspHomeInNode(
      wires: [
        [
          mqttOutNode.id,
        ]
      ],
      espHomeNodeDeviceId: espHomeDeviceId,
      name: 'ESPHome $entityId in type',
      epsHomeDeviceEntityId: entityId,
    );
    nodes += ', $nodeRedEspHomeInNode';

    /// Create an EspHome out node
    final NodeRedEspHomeOutNode nodeRedEspHomeOutNode = NodeRedEspHomeOutNode(
      wires: [[]],
      espHomeNodeDeviceId: espHomeDeviceId,
      name: 'ESPHome $entityId out type',
      espHomeEntityId: entityId,
    );
    nodes += ', $nodeRedEspHomeOutNode';

    final NodeRedFunctionNode nodeRedFunctionToJsonNode =
        NodeRedFunctionNode.inputPayloadToJson(
      wires: [
        [
          nodeRedEspHomeOutNode.id,
        ]
      ],
    );
    nodes += ', $nodeRedFunctionToJsonNode';

    /// Mqtt in
    final NodeRedMqttInNode nodeRedMqttInNode = NodeRedMqttInNode(
      name: '$mqttNodeName - $inputDeviceProperty',
      brokerNodeId: mqttBrokerNode.id,
      topic: '$topic/$inputDeviceProperty',
      wires: [
        [
          nodeRedFunctionToJsonNode.id,
        ]
      ],
    );
    nodes += ', $nodeRedMqttInNode';

    nodes += '\n]';

    /// Setting the flow
    return repository.setFlowWithModule(
      label: 'Setting device $entityId',
      moduleToUse: module,
      nodes: nodes,
      flowId: flowId,
    );
  }
}
