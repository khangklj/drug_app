import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';

@pragma('vm:entry-point')
class AlarmService {
  @pragma('vm:entry-point')
  static Future<void> playAlarm(int id) async {
    FlutterRingtonePlayer().playAlarm();
    await Future.delayed(const Duration(seconds: 5));
    FlutterRingtonePlayer().stop();
  }
}
