import 'package:dartpad_lite/core/storage/sp_keys.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class WorkTimerRepoInterface {
  Future<bool> setWorkInterval(Duration duration);
  Future<bool> setBreakInterval(Duration duration);
  Future<Duration> getWorkInterval();
  Future<Duration> getBreakInterval();
}

class WorkTimerRepo implements WorkTimerRepoInterface {
  WorkTimerRepo();
  
  @override
  Future<Duration> getBreakInterval() async {
    final prefs = await SharedPreferences.getInstance();
    final minutes = prefs.getInt(SPKeys.breakTimer.value) ?? 15;
    return Duration(minutes: minutes);
  }
  
  @override
  Future<Duration> getWorkInterval() async {
    final prefs = await SharedPreferences.getInstance();
    final minutes = prefs.getInt(SPKeys.workTimer.value) ?? 30;
    return Duration(minutes: minutes);
  }
  
  @override
  Future<bool> setBreakInterval(Duration duration) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.setInt(SPKeys.breakTimer.value, duration.inMinutes);
  }
  
  @override
  Future<bool> setWorkInterval(Duration duration) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.setInt(SPKeys.workTimer.value, duration.inMinutes);
  }
}