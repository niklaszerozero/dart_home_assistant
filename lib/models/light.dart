import '../util/mappable.dart';

enum LightFlash { short, long }

enum _lightBrightnessType { total, percentage }

class LightBrightness implements Mappable {
  final _lightBrightnessType _type;
  final int value;

  const LightBrightness.total(int value)
      : this._type = _lightBrightnessType.total,
        this.value = value;

  const LightBrightness.percentage(int percentage)
      : this._type = _lightBrightnessType.percentage,
        this.value = percentage;

  @override
  Map<String, dynamic> toMap() {
    switch (_type) {
      case _lightBrightnessType.total:
        return {
          'brightness': value,
        };
      case _lightBrightnessType.percentage:
        return {
          'brightness_pct': value,
        };
    }
  }
}

class LightBrightnessWithBrightnessStep extends LightBrightness
    implements Mappable {
  final bool isStep;

  const LightBrightnessWithBrightnessStep.total(int value)
      : this.isStep = false,
        super.total(value);

  const LightBrightnessWithBrightnessStep.totalStep(int value)
      : this.isStep = true,
        super.total(value);

  const LightBrightnessWithBrightnessStep.percentage(int percentage)
      : this.isStep = false,
        super.percentage(percentage);

  const LightBrightnessWithBrightnessStep.percentageStep(int percentage)
      : this.isStep = true,
        super.percentage(percentage);

  @override
  Map<String, dynamic> toMap() {
    if (!isStep) {
      return super.toMap();
    }
    switch (_type) {
      case _lightBrightnessType.total:
        return {
          'brightness_step': value,
        };
      case _lightBrightnessType.percentage:
        return {
          'brightness_step_pct': value,
        };
    }
  }
}

enum _lightColorType { name, kelvin, temperature, rgb, rgbw, rgbww, hs, xy }

class LightColor implements Mappable {
  final _lightColorType _type;
  final String? s1;
  final int? i1;
  final int? i2;
  final int? i3;
  final int? i4;
  final int? i5;
  final double? d1;
  final double? d2;

  const LightColor.name(String name)
      : this._type = _lightColorType.name,
        this.s1 = name,
        this.i1 = null,
        this.i2 = null,
        this.i3 = null,
        this.i4 = null,
        this.i5 = null,
        this.d1 = null,
        this.d2 = null;

  const LightColor.kelvin(int kelvin)
      : this._type = _lightColorType.kelvin,
        this.s1 = null,
        this.i1 = kelvin,
        this.i2 = null,
        this.i3 = null,
        this.i4 = null,
        this.i5 = null,
        this.d1 = null,
        this.d2 = null;

  const LightColor.temperature(int temperature)
      : this._type = _lightColorType.temperature,
        this.s1 = null,
        this.i1 = temperature,
        this.i2 = null,
        this.i3 = null,
        this.i4 = null,
        this.i5 = null,
        this.d1 = null,
        this.d2 = null;

  const LightColor.rgb(int red, int green, int blue)
      : this._type = _lightColorType.rgb,
        this.s1 = null,
        this.i1 = red,
        this.i2 = green,
        this.i3 = blue,
        this.i4 = null,
        this.i5 = null,
        this.d1 = null,
        this.d2 = null;

  const LightColor.rgbw(int red, int green, int blue, int white)
      : this._type = _lightColorType.rgbw,
        this.s1 = null,
        this.i1 = red,
        this.i2 = green,
        this.i3 = blue,
        this.i4 = white,
        this.i5 = null,
        this.d1 = null,
        this.d2 = null;

  const LightColor.rgbww(
      int red, int green, int blue, int cold_white, warm_white)
      : this._type = _lightColorType.rgbww,
        this.s1 = null,
        this.i1 = red,
        this.i2 = green,
        this.i3 = blue,
        this.i4 = cold_white,
        this.i5 = warm_white,
        this.d1 = null,
        this.d2 = null;

  const LightColor.hs(int hue, int saturation)
      : this._type = _lightColorType.hs,
        this.s1 = null,
        this.i1 = hue,
        this.i2 = saturation,
        this.i3 = null,
        this.i4 = null,
        this.i5 = null,
        this.d1 = null,
        this.d2 = null;

  const LightColor.xy(double x, double y)
      : this._type = _lightColorType.xy,
        this.s1 = null,
        this.i1 = null,
        this.i2 = null,
        this.i3 = null,
        this.i4 = null,
        this.i5 = null,
        this.d1 = x,
        this.d2 = y;

  @override
  Map<String, dynamic> toMap() {
    switch (_type) {
      case _lightColorType.name:
        return {'color_name': s1};
      case _lightColorType.kelvin:
        return {'kelvin': i1};
      case _lightColorType.temperature:
        return {'color_temp': i1};
      case _lightColorType.rgb:
        return {
          'rgb_color': [i1, i2, i3]
        };
      case _lightColorType.rgbw:
        return {
          'rgbw_color': [i1, i2, i3, i4]
        };
      case _lightColorType.rgbww:
        return {
          'rgbww_color': [i1, i2, i3, i4, i5]
        };
      case _lightColorType.hs:
        return {
          'hs_color': [i1, i2]
        };
      case _lightColorType.xy:
        return {
          'xy_color': [d1, d2]
        };
    }
  }
}
