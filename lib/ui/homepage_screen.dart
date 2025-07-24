import 'package:drug_app/ui/components/camera_floating_button.dart';
import 'package:drug_app/ui/components/tabbar_widget.dart';
import 'package:drug_app/ui/drug/drug_list_screen.dart';
import 'package:flutter/material.dart';

class HomePageScreen extends StatefulWidget {
  const HomePageScreen({super.key});
  static const String routeName = "/home";

  @override
  State<HomePageScreen> createState() => _HomePageScreenState();
}

class _HomePageScreenState extends State<HomePageScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: TabBarWidget(),
      floatingActionButton: CameraFloatingButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      body: SingleChildScrollView(child: DrugListScreen()),
    );
  }
}
