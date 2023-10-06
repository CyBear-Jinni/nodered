/// Class to define all Node RED repo functions
abstract class INodeRedRepository {
  /// Install node module if not exist and set a new flow for that api
  /// Label is name of the flow
  Future<String> setFlowWithModule({
    required String moduleToUse,
    required String label,
    required String nodes,
    required String flowId,
  });

  /// Update existing flow with more nodes
  Future<String> updateFlowNodes({
    required String nodes,
    required String flowId,
  });

  /// Install node module if needed and set one global node
  /// Label is name of the flow
  Future<String> setGlobalNodes({
    required String? moduleToUse,
    required String nodes,
  });
}
