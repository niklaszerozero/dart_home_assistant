import '../../models/light.dart';
import '../../models/target.dart';
import '../client.dart';

class LightServices {
  final Client _client;

  const LightServices(this._client);

  Future<void> turnOn(Target target,
      {int? transition,
      LightBrightnessWithBrightnessStep? brightness,
      LightColor? color,
      String? effect,
      String? profile,
      LightFlash? flash}) {
    Map<String, dynamic> serviceData = {...target.toMap()};
    if (transition != null) {
      serviceData['transition'] = transition;
    }
    if (brightness != null) {
      serviceData = {...serviceData, ...brightness.toMap()};
    }
    if (color != null) {
      serviceData = {...serviceData, ...color.toMap()};
    }
    if (effect != null) {
      serviceData['effect'] = effect;
    }
    if (profile != null) {
      serviceData['profile'] = profile;
    }
    if (flash != null) {
      serviceData['flash'] = _parseFlash(flash);
    }
    return _client.callService('light', 'turn_on', serviceData);
  }

  Future<void> turnOff(Target target, {int? transition, LightFlash? flash}) {
    Map<String, dynamic> serviceData = {...target.toMap()};
    if (transition != null) {
      serviceData['transition'] = transition;
    }
    if (flash != null) {
      serviceData['flash'] = _parseFlash(flash);
    }
    return _client.callService('light', 'turn_off', serviceData);
  }

  Future<void> toggle(Target target,
      {int? transition,
      LightBrightness? brightness,
      LightColor? color,
      String? effect,
      String? profile,
      LightFlash? flash}) {
    Map<String, dynamic> serviceData = {...target.toMap()};
    if (transition != null) {
      serviceData['transition'] = transition;
    }
    if (brightness != null) {
      serviceData = {...serviceData, ...brightness.toMap()};
    }
    if (color != null) {
      serviceData = {...serviceData, ...color.toMap()};
    }
    if (effect != null) {
      serviceData['effect'] = effect;
    }
    if (profile != null) {
      serviceData['profile'] = profile;
    }
    if (flash != null) {
      serviceData['flash'] = _parseFlash(flash);
    }
    return _client.callService('light', 'toggle', serviceData);
  }

  String _parseFlash(LightFlash flash) {
    switch (flash) {
      case LightFlash.short:
        return 'short';
      case LightFlash.long:
        return 'long';
    }
  }
}

extension LightServicesExtension on Client {
  LightServices get light => LightServices(this);
}
