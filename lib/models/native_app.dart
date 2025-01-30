import '../util/mappable.dart';

class AppInformation implements Mappable {
  final String id;
  final String name;
  final String version;

  const AppInformation(this.id, this.name, this.version);

  AppInformation.fromMap(Map<String, dynamic> map)
      : this.id = map['app_id'],
        this.name = map['app_name'],
        this.version = map['app_version'];

  @override
  Map<String, dynamic> toMap() {
    return {
      'app_id': id,
      'app_name': name,
      'app_version': version,
    };
  }
}

class DeviceInformation implements Mappable {
  final String id;
  final String name;
  final String manufacturer;
  final String model;
  final String osName;
  final String osVersion;

  const DeviceInformation(this.id, this.name, this.manufacturer, this.model,
      this.osName, this.osVersion);

  DeviceInformation.fromMap(Map<String, dynamic> map)
      : this.id = map['device_id'],
        this.name = map['device_name'],
        this.manufacturer = map['manufacturer'],
        this.model = map['model'],
        this.osName = map['os_name'],
        this.osVersion = map['os_version'];

  @override
  Map<String, dynamic> toMap() {
    return {
      'device_id': id,
      'device_name': name,
      'manufacturer': manufacturer,
      'model': model,
      'os_name': osName,
      'os_version': osVersion,
    };
  }
}
