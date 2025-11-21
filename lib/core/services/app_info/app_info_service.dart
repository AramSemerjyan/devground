import 'package:package_info_plus/package_info_plus.dart';

abstract class AppInfoServiceInterface {
  Future<AppInfo> getAppInfo();
}

class AppInfoService implements AppInfoServiceInterface {
  @override
  Future<AppInfo> getAppInfo() async {
    final info = await PackageInfo.fromPlatform();

    return AppInfo(
      appName: info.appName,
      packageName: info.packageName,
      version: info.version,
      buildNumber: info.buildNumber,
    );
  }
}

class AppInfo {
  final String appName;
  final String packageName;
  final String version;
  final String buildNumber;

  AppInfo({
    required this.appName,
    required this.packageName,
    required this.version,
    required this.buildNumber,
  });
}
