import 'package:dartpad_lite/UI/command_palette/command_palette.dart';

enum SupportedLanguageType {
  dart('dart'),
  shell('shell'),
  c('c'),
  cpp('cpp'),
  python('python'),
  swift('swift'),
  javascript('javascript'),
  html('html'),
  css('css');

  final String value;

  const SupportedLanguageType(this.value);

  static SupportedLanguageType fromString(String type) {
    return SupportedLanguageType.values.firstWhere(
      (e) => e.value == type,
      orElse: () => SupportedLanguageType.dart,
    );
  }

  String toJson() => value;
}

enum LanguageSupport {
  supported('supported'),
  notSupported('notSupported'),
  upcoming('upcoming');

  final String value;

  const LanguageSupport(this.value);

  String toJson() {
    return name;
  }

  static LanguageSupport fromJson(String value) {
    return LanguageSupport.values.firstWhere(
      (e) => e.name == value,
      orElse: () => LanguageSupport.upcoming,
    );
  }
}

class Path {
  final String validation;
  final String hint;

  Path({required this.validation, required this.hint});

  factory Path.fromJson(Map<String, dynamic> json) {
    return Path(validation: json['validation'], hint: json['hint']);
  }

  Map<String, dynamic> toJson() {
    return {'validation': validation, 'hint': hint};
  }
}

class SupportedLanguage implements CommandPaletteItem {
  final SupportedLanguageType key;
  final String name;
  final String icon;
  final String extension;
  final Path path;
  final String snippet;
  final LanguageSupport supported;
  final bool needSDKPath;
  final String? sdkPath;

  SupportedLanguage({
    required this.key,
    required this.name,
    required this.icon,
    required this.extension,
    required this.path,
    required this.snippet,
    required this.supported,
    required this.needSDKPath,
    this.sdkPath,
  });

  factory SupportedLanguage.fromJson(Map<String, dynamic> json) {
    return SupportedLanguage(
      key: SupportedLanguageType.fromString(json['key'] ?? ''),
      name: json['name'] ?? '',
      icon: json['icon'] ?? '',
      extension: json['extension'] ?? '',
      path: Path.fromJson(json['path']),
      snippet: json['snippet'],
      needSDKPath: json['need_sdk_path'],
      supported: LanguageSupport.fromJson(json['supported']),
      sdkPath: json['sdk_path'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'key': key.value,
      'name': name,
      'icon': icon,
      'extension': extension,
      'snippet': snippet,
      'path': path.toJson(),
      'supported': supported.value,
      'need_sdk_path': needSDKPath,
      'sdk_path': sdkPath,
    };
  }

  SupportedLanguage addSDKPath(String sdkPath) {
    return SupportedLanguage(
      key: key,
      name: name,
      icon: icon,
      extension: extension,
      path: path,
      snippet: snippet,
      supported: supported,
      needSDKPath: needSDKPath,
      sdkPath: sdkPath,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SupportedLanguage &&
          runtimeType == other.runtimeType &&
          key.value == other.key.value;

  @override
  int get hashCode => key.value.hashCode;

  @override
  String get itemName => name;
}
