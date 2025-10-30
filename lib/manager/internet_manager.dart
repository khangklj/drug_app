import 'package:flutter/material.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

class InternetManager {
  InternetManager._();
  static final InternetManager instance = InternetManager._();

  // late GlobalKey<NavigatorState> _navigatorKey;
  final List<Future<void> Function()> _callbacks = [];

  bool _initialized = false;

  Future<void> init(GlobalKey<NavigatorState> navigatorKey) async {
    // _navigatorKey = navigatorKey;

    InternetConnection().onStatusChange.listen((status) async {
      final connected = status == InternetStatus.connected;

      if (!_initialized) {
        // skip the retry for the first if online
        _initialized = true;
        return;
      }

      if (!connected) {
        return;
      } else {
        _retryCallbacks();
      }
    });
  }

  void register(Future<void> Function() callback) {
    _callbacks.add(callback);
  }

  void unregister(Future<void> Function() callback) {
    _callbacks.remove(callback);
  }

  void _retryCallbacks() {
    for (var cb in List.from(_callbacks)) {
      cb();
    }
  }
}
