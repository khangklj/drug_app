import 'dart:convert';
import 'package:drug_app/manager/drug_favorite_manager.dart';
import 'package:drug_app/manager/drug_prescription_manager.dart';
import 'package:drug_app/manager/internet_manager.dart';
import 'package:drug_app/manager/notification_manager.dart';
import 'package:drug_app/manager/patient_manager.dart';
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
import 'package:drug_app/ui/patient/patient_screen.dart';
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
  final notifcationManager = NotificationManager();
  final drugManager = DrugManager();
  final drugFavoriteManager = DrugFavoriteManager();
  final patientMananger = PatientManager();

  await InternetManager.instance.init(globalNavigatorKey);
  InternetManager.instance.register(
    drugPrescriptionManager.fetchDrugPrescriptions,
  );
  InternetManager.instance.register(drugManager.fetchDrugsMetadata);
  InternetManager.instance.register(drugFavoriteManager.fetchFavoriteDrugs);
  InternetManager.instance.register(patientMananger.fetchPatients);

  await drugPrescriptionManager.fetchDrugPrescriptions();
  await notifcationManager.initSettings();
  await drugManager.fetchDrugsMetadata();
  await drugFavoriteManager.fetchFavoriteDrugs();
  await patientMananger.fetchPatients();

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
        ChangeNotifierProvider.value(value: drugManager),
        ChangeNotifierProvider(create: (_) => SearchHistoryManager()),
        ChangeNotifierProvider.value(value: drugFavoriteManager),
        ChangeNotifierProxyProvider<
          DrugPrescriptionManager,
          NotificationManager
        >(
          create: (_) => notifcationManager,
          update: (_, drugPrescriptionManager, notificationManager) =>
              notificationManager!..updateNotification(drugPrescriptionManager),
          lazy: false,
        ),
        ChangeNotifierProvider.value(value: patientMananger),
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
      title: 'MediApp',
      navigatorKey: globalNavigatorKey,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,
      initialRoute: MediAppHomepageScreen.routeName,
      onGenerateRoute: (settings) {
        if (settings.name == MediAppHomepageScreen.routeName) {
          return MaterialPageRoute(
            builder: (_) =>
                SafeArea(child: StartupWrapper(startScreen: startScreen)),
            settings: settings,
          );
        }

        if (settings.name == DrugSearchResultsScreen.routeName) {
          final drugs = settings.arguments as List<Drug>;
          return MaterialPageRoute(
            builder: (_) =>
                SafeArea(child: DrugSearchResultsScreen(drugs: drugs)),
            settings: settings,
          );
        }

        if (settings.name == DrugDetailsScreen.routeName) {
          final drugId = settings.arguments as String;
          return MaterialPageRoute(
            builder: (_) => SafeArea(child: DrugDetailsScreen(drugId: drugId)),
            settings: settings,
          );
        }

        if (settings.name == DrugPrescriptionScreen.routeName) {
          return MaterialPageRoute(
            builder: (_) => SafeArea(child: const DrugPrescriptionScreen()),
            settings: settings,
          );
        }

        if (settings.name == DrugPrescriptionEditScreen.routeName) {
          final drugPrescription = settings.arguments as DrugPrescription?;
          return MaterialPageRoute(
            builder: (_) =>
                SafeArea(child: DrugPrescriptionEditScreen(drugPrescription)),
            settings: settings,
          );
        }

        if (settings.name == DrugFavoriteScreen.routeName) {
          return MaterialPageRoute(
            builder: (_) => SafeArea(child: DrugFavoriteScreen()),
            settings: settings,
          );
        }

        if (settings.name == DrugPrescriptionPayloadScreen.routeName) {
          final timeOfDay = settings.arguments as TimeOfDayValues;
          return MaterialPageRoute(
            builder: (_) => SafeArea(
              child: DrugPrescriptionPayloadScreen(timeOfDay: timeOfDay),
            ),
            settings: settings,
          );
        }

        if (settings.name == SettingsScreen.routeName) {
          return MaterialPageRoute(
            builder: (_) => SafeArea(child: SettingsScreen()),
            settings: settings,
          );
        }

        if (settings.name == PatientScreen.routeName) {
          return MaterialPageRoute(
            builder: (_) => SafeArea(child: PatientScreen()),
            settings: settings,
          );
        }

        return null;
      },
    );
  }
}

class StartupWrapper extends StatefulWidget {
  final Widget startScreen;
  const StartupWrapper({super.key, required this.startScreen});

  @override
  State<StartupWrapper> createState() => _StartupWrapperState();
}

class _StartupWrapperState extends State<StartupWrapper> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.startScreen is! MediAppHomepageScreen) {
        Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => widget.startScreen));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return const MediAppHomepageScreen();
  }
}
