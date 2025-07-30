import 'dart:io';
import 'package:drug_app/shared/app_theme.dart';
import 'package:drug_app/manager/drug_manager.dart';
import 'package:drug_app/ui/drug/drug_details_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'screen_routing.dart';

Future<void> main() async {
  await dotenv.load();
  runApp(
    MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => DrugManager())],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
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

        if (settings.name == DrugDetailsScreen.routeName) {
          final drugId = settings.arguments as String;
          return MaterialPageRoute(
            builder: (_) => SafeArea(child: DrugDetailsScreen(drugId: drugId)),
          );
        }
        return null;
      },
    );
  }
}
