import 'package:app_settings/app_settings.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

class InternetManager {
  InternetManager._();
  static final InternetManager instance = InternetManager._();

  late GlobalKey<NavigatorState> _navigatorKey;
  final List<Future<void> Function()> _callbacks = [];

  bool _dialogOpen = false;
  bool _initialized = false;

  Future<void> init(GlobalKey<NavigatorState> navigatorKey) async {
    _navigatorKey = navigatorKey;

    InternetConnection().onStatusChange.listen((status) async {
      final connected = status == InternetStatus.connected;

      if (!_initialized) {
        // skip the retry for the first if online
        _initialized = true;
        if (!connected) {
          _showNoInternetDialog();
        }
        return;
      }

      if (!connected) {
        _showNoInternetDialog();
      } else {
        _hideNoInternetDialog();
        _retryCallbacks();
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final hasInternet = await InternetConnection().hasInternetAccess;
      if (!hasInternet) {
        _showNoInternetDialog();
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

  void _showNoInternetDialog() {
    if (_dialogOpen) return; // prevent multiple dialogs
    final context = _navigatorKey.currentContext;
    if (context == null) return;

    _dialogOpen = true;

    AwesomeDialog(
      context: context,
      dialogType: DialogType.error,
      animType: AnimType.scale,
      dismissOnBackKeyPress: false,
      dismissOnTouchOutside: false,
      headerAnimationLoop: false,
      title: "Lỗi kết nối mạng",
      desc: "Vui lòng kiểm tra kết nối mạng.\n",
      btnOkText: "Cài đặt wifi",
      btnOkColor: Theme.of(context).colorScheme.primaryContainer,
      btnOkOnPress: () async {
        await AppSettings.openAppSettings(type: AppSettingsType.wifi);
      },
      autoDismiss: false,
      onDismissCallback: (type) {
        return;
      },
    ).show().then((_) {
      _dialogOpen = false; // Reset when closed
    });
  }

  void _hideNoInternetDialog() {
    if (!_dialogOpen) return;

    final context = _navigatorKey.currentContext;
    if (context == null) return;

    if (Navigator.of(context, rootNavigator: true).canPop()) {
      Navigator.of(context, rootNavigator: true).pop();
    }
    _dialogOpen = false;
  }
}
