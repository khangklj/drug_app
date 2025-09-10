import 'dart:io';
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:drug_app/manager/drug_favorite_manager.dart';
import 'package:drug_app/manager/drug_prescription_manager.dart';
import 'package:drug_app/manager/search_history_manager.dart';
import 'package:drug_app/manager/settings_manager.dart';
import 'package:drug_app/models/drug.dart';
import 'package:drug_app/models/drug_prescription.dart';
import 'package:drug_app/shared/app_theme.dart';
import 'package:drug_app/manager/drug_manager.dart';
import 'package:drug_app/ui/drug/drug_details_screen.dart';
import 'package:drug_app/ui/drug/drug_favorite_screen.dart';
import 'package:drug_app/ui/drug/drug_search_results_screen.dart';
import 'package:drug_app/ui/drug_prescription/drug_prescription_edit_screen.dart';
import 'package:drug_app/ui/drug_prescription/drug_prescription_screen.dart';
import 'package:drug_app/ui/settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'screen_routing.dart';

Future<void> main() async {
  await dotenv.load();
  WidgetsFlutterBinding.ensureInitialized();
  await AndroidAlarmManager.initialize();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SettingsManager()),
        ChangeNotifierProvider(create: (_) => DrugManager()),
        ChangeNotifierProvider(create: (_) => DrugPrescriptionManager()),
        ChangeNotifierProvider(create: (_) => SearchHistoryManager()),
        ChangeNotifierProvider(create: (_) => DrugFavoriteManager()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    ThemeMode themeMode = context.watch<SettingsManager>().themeMode;
    return MaterialApp(
      title: 'Flutter Demo',
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,
      home: SafeArea(child: const HomePageScreen()),
      onGenerateRoute: (settings) {
        if (settings.name == HomePageScreen.routeName) {
          return MaterialPageRoute(
            builder: (_) => SafeArea(child: const HomePageScreen()),
          );
        }

        if (settings.name == ImageViewScreen.routeName) {
          final image = settings.arguments as File;
          return MaterialPageRoute(
            builder: (_) => SafeArea(child: ImageViewScreen(image: image)),
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
