import 'dart:convert';
import 'package:drug_app/manager/drug_favorite_manager.dart';
import 'package:drug_app/manager/drug_prescription_manager.dart';
import 'package:drug_app/manager/notification_manager.dart';
import 'package:drug_app/manager/search_history_manager.dart';
import 'package:drug_app/manager/settings_manager.dart';
import 'package:drug_app/models/drug.dart';
import 'package:drug_app/models/drug_prescription.dart';
import 'package:drug_app/models/drug_prescription_item.dart';
import 'package:drug_app/services/notification_service.dart';
import 'package:drug_app/shared/app_theme.dart';
import 'package:drug_app/manager/drug_manager.dart';
import 'package:drug_app/ui/drug/drug_details_screen.dart';
import 'package:drug_app/ui/drug/drug_favorite_screen.dart';
import 'package:drug_app/ui/drug/drug_search_results_screen.dart';
import 'package:drug_app/ui/drug_prescription/drug_prescription_edit_screen.dart';
import 'package:drug_app/ui/drug_prescription/drug_prescription_payload_screen.dart';
import 'package:drug_app/ui/drug_prescription/drug_prescription_screen.dart';
import 'package:drug_app/ui/medi_app_homepage_screen.dart';
import 'package:drug_app/ui/settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';

final globalNavigatorKey = GlobalKey<NavigatorState>();

TimeOfDayValues getTimeFromPayload(String? payload) {
  final NotificationPayload notificationPayload = NotificationPayload.fromJSON(
    jsonDecode(payload!),
  );
  final timeOfDay = notificationPayload.timeOfDay;
  return timeOfDay;
}

Future<void> main() async {
  await dotenv.load();
  WidgetsFlutterBinding.ensureInitialized();
  final notificationService = NotificationService();

  // Initialize notifications
  await notificationService.initSettings((payload) {
    final timeOfDay = getTimeFromPayload(payload);
    globalNavigatorKey.currentState?.pushNamed(
      DrugPrescriptionPayloadScreen.routeName,
      arguments: timeOfDay,
    );
  });

  final settingsManager = SettingsManager();
  await settingsManager.initSettings();

  final drugPrescriptionManager = DrugPrescriptionManager();
  await drugPrescriptionManager.fetchDrugPrescriptions();

  final notifcationManager = NotificationManager();
  await notifcationManager.initSettings();

  final details = await notificationService.notifcationAppLaunchDetails;
  late final TimeOfDayValues? timeOfDayFromNotification;
  if (details != null && details.didNotificationLaunchApp) {
    String? payload = details.notificationResponse?.payload;
    timeOfDayFromNotification = getTimeFromPayload(payload);
  } else {
    timeOfDayFromNotification = null;
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: settingsManager),
        ChangeNotifierProvider.value(value: drugPrescriptionManager),
        ChangeNotifierProvider(create: (_) => DrugManager()),
        ChangeNotifierProvider(create: (_) => SearchHistoryManager()),
        ChangeNotifierProvider(create: (_) => DrugFavoriteManager()),
        ChangeNotifierProxyProvider<
          DrugPrescriptionManager,
          NotificationManager
        >(
          create: (_) => notifcationManager,
          update: (_, drugPrescriptionManager, notificationManager) =>
              notificationManager!..updateNotification(drugPrescriptionManager),
          lazy: false,
        ),
      ],
      child: MyApp(
        startScreen: timeOfDayFromNotification == null
            ? const MediAppHomepageScreen()
            : DrugPrescriptionPayloadScreen(
                timeOfDay: timeOfDayFromNotification,
              ),
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, required this.startScreen});

  final Widget startScreen;

  @override
  Widget build(BuildContext context) {
    ThemeMode themeMode = context.watch<SettingsManager>().themeMode;
    return MaterialApp(
      title: 'Flutter Demo',
      navigatorKey: globalNavigatorKey,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,
      home: startScreen,
      onGenerateRoute: (settings) {
        if (settings.name == MediAppHomepageScreen.routeName) {
          return MaterialPageRoute(
            builder: (_) => SafeArea(child: const MediAppHomepageScreen()),
          );
        }

        if (settings.name == DrugSearchResultsScreen.routeName) {
          final drugs = settings.arguments as List<Drug>;
          return MaterialPageRoute(
            builder: (_) =>
                SafeArea(child: DrugSearchResultsScreen(drugs: drugs)),
          );
        }

        if (settings.name == DrugDetailsScreen.routeName) {
          final drugId = settings.arguments as String;
          return MaterialPageRoute(
            builder: (_) => SafeArea(child: DrugDetailsScreen(drugId: drugId)),
          );
        }

        if (settings.name == DrugPrescriptionScreen.routeName) {
          return MaterialPageRoute(
            builder: (_) => SafeArea(child: const DrugPrescriptionScreen()),
          );
        }

        if (settings.name == DrugPrescriptionEditScreen.routeName) {
          final drugPrescription = settings.arguments as DrugPrescription?;
          return MaterialPageRoute(
            builder: (_) =>
                SafeArea(child: DrugPrescriptionEditScreen(drugPrescription)),
          );
        }

        if (settings.name == DrugFavoriteScreen.routeName) {
          return MaterialPageRoute(
            builder: (_) => SafeArea(child: DrugFavoriteScreen()),
          );
        }

        if (settings.name == DrugPrescriptionPayloadScreen.routeName) {
          final timeOfDay = settings.arguments as TimeOfDayValues;
          return MaterialPageRoute(
            builder: (_) => SafeArea(
              child: DrugPrescriptionPayloadScreen(timeOfDay: timeOfDay),
            ),
          );
        }

        if (settings.name == SettingsScreen.routeName) {
          return MaterialPageRoute(
            builder: (_) => SafeArea(child: SettingsScreen()),
          );
        }

        return null;
      },
    );
  }
}
