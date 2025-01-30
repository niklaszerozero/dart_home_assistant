import '../util/mappable.dart';

class Target implements Mappable {
  final String? floorId;
  final String? areaId;
  final List<String>? deviceIds;
  final List<String>? entityIds;
  final List<String>? labelIds;

  const Target(
      {this.floorId,
      this.areaId,
      this.deviceIds,
      this.entityIds,
      this.labelIds});

  const Target.floor(String floor)
      : this.floorId = floor,
        this.areaId = null,
        this.deviceIds = null,
        this.entityIds = null,
        this.labelIds = null;

  const Target.area(String area)
      : this.floorId = null,
        this.areaId = area,
        this.deviceIds = null,
        this.entityIds = null,
        this.labelIds = null;

  Target.device(String device)
      : this.floorId = null,
        this.areaId = null,
        this.deviceIds = [device],
        this.entityIds = null,
        this.labelIds = null;

  const Target.devices(List<String> devices)
      : this.floorId = null,
        this.areaId = null,
        this.deviceIds = devices,
        this.entityIds = null,
        this.labelIds = null;

  Target.entity(String entity)
      : this.floorId = null,
        this.areaId = null,
        this.deviceIds = null,
        this.entityIds = [entity],
        this.labelIds = null;

  const Target.entities(List<String> entities)
      : this.floorId = null,
        this.areaId = null,
        this.deviceIds = null,
        this.entityIds = entities,
        this.labelIds = null;

  Target.label(String label)
      : this.floorId = null,
        this.areaId = null,
        this.deviceIds = null,
        this.entityIds = null,
        this.labelIds = [label];

  const Target.labels(List<String> labels)
      : this.floorId = null,
        this.areaId = null,
        this.deviceIds = null,
        this.entityIds = null,
        this.labelIds = labels;

  @override
  Map<String, dynamic> toMap() {
    Map<String, dynamic> result = {};
    if (floorId != null && floorId!.isNotEmpty) {
      result['floor_id'] = floorId;
    }
    if (areaId != null && areaId!.isNotEmpty) {
      result['area_id'] = areaId;
    }
    if (deviceIds != null && deviceIds!.isNotEmpty) {
      if (deviceIds!.length == 1) {
        result['device_id'] = deviceIds!.first;
      } else {
        result['device_id'] = deviceIds;
      }
    }
    if (entityIds != null && entityIds!.isNotEmpty) {
      if (entityIds!.length == 1) {
        result['entity_id'] = entityIds!.first;
      } else {
        result['entity_id'] = entityIds;
      }
    }
    if (labelIds != null && labelIds!.isNotEmpty) {
      if (labelIds!.length == 1) {
        result['label_id'] = labelIds!.first;
      } else {
        result['label_id'] = labelIds;
      }
    }
    return result;
  }
}
