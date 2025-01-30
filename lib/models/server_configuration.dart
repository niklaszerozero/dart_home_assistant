import '../util/mappable.dart';

class ServerConfiguration implements Mappable {
  final List<String> _allowlistExternalDirs;
  final List<String> _allowlistExternalUrls;
  final List<String> _components;
  final String? _configDir;
  final String? _configSource;
  final String? _country;
  final String? _currency;
  final bool _debug;
  final int? _elevation;
  final String? _externalUrl;
  final String? _internalUrl;
  final String? _language;
  final double? _latitude;
  final String? _locationName;
  final double? _longitude;
  final int? _radius;
  final bool _recoveryMode;
  final bool _safeMode;
  final String? _state;
  final String? _timeZone;
  final Map<String, String> _unitSystem;
  final String? _version;
  final List<String> _whitelistExternalDirs;

  ServerConfiguration.fromMap(Map<String, dynamic> map)
      : _allowlistExternalDirs = map['allowlist_external_dirs'] ?? [],
        _allowlistExternalUrls = map['allowlist_external_urls'] ?? [],
        _components = map['components'] ?? [],
        _configDir = map['config_dir'],
        _configSource = map['config_source'],
        _country = map['country'],
        _currency = map['currency'],
        _debug = map['debug'] ?? false,
        _elevation = map['elevation'],
        _externalUrl = map['external_url'],
        _internalUrl = map['internal_url'],
        _language = map['language'],
        _latitude = map['latitude'],
        _locationName = map['location_name'],
        _longitude = map['longitude'],
        _radius = map['radius'],
        _recoveryMode = map['recovery_mode'] ?? false,
        _safeMode = map['safe_mode'] ?? false,
        _state = map['state'],
        _timeZone = map['time_zone'],
        _unitSystem = map['unit_system'] ?? {},
        _version = map['version'],
        _whitelistExternalDirs = map['whitelist_external_dirs'];

  List<String> get allowlistExternalDirs => List.from(_allowlistExternalDirs);
  List<String> get allowlistExternalUrls => List.from(_allowlistExternalUrls);
  List<String> get components => List.from(_components);
  String? get configDir => _configDir;
  String? get configSource => _configSource;
  String? get country => _country;
  String? get currency => _currency;
  bool get debug => _debug;
  int? get elevation => _elevation;
  String? get externalUrl => _externalUrl;
  String? get internalUrl => _internalUrl;
  String? get language => _language;
  double? get latitude => _latitude;
  String? get locationName => _locationName;
  double? get longitude => _longitude;
  int? get radius => _radius;
  bool get recoveryMode => _recoveryMode;
  bool get safeMode => _safeMode;
  String? get state => _state;
  String? get timeZone => _timeZone;
  Map<String, String> get unitSystem => Map.from(_unitSystem);
  String? get version => _version;
  List<String> get whitelistExternalDirs => List.from(_whitelistExternalDirs);

  @override
  Map<String, dynamic> toMap() {
    return {
      'allowlist_external_dirs': _allowlistExternalDirs,
      'allowlist_external_urls': _allowlistExternalUrls,
      'components': _components,
      'config_dir': _configDir,
      'config_source': _configSource,
      'country': _country,
      'currency': _currency,
      'debug': _debug,
      'elevation': _elevation,
      'external_url': _externalUrl,
      'internal_url': _internalUrl,
      'language': _language,
      'latitude': _latitude,
      'location_name': _locationName,
      'longitude': _longitude,
      'radius': _radius,
      'recovery_mode': _recoveryMode,
      'safe_mode': _safeMode,
      'state': _state,
      'time_zone': _timeZone,
      'unit_system': _unitSystem,
      'version': _version,
      'whitelist_external_dirs': _whitelistExternalDirs,
    };
  }
}
