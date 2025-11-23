import 'package:drug_app/ui/drug/drug_favorite_screen.dart';
import 'package:drug_app/ui/drug_prescription/drug_prescription_screen.dart';
import 'package:drug_app/ui/medi_app_homepage_screen.dart';
import 'package:drug_app/ui/patient/patient_screen.dart';
import 'package:drug_app/ui/settings_screen.dart';
import 'package:flutter/material.dart';

class MediAppDrawer extends StatelessWidget {
  const MediAppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 100,
                    width: 100,
                    child: Image.asset("assets/icons/app_icon.png"),
                  ),
                  Text(
                    'MediApp',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ],
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: Text(
              'Trang chủ',
              style: Theme.of(context).textTheme.titleLarge,
            ),

            onTap: () {
              Navigator.of(context).pop();
              if (ModalRoute.of(context)?.settings.name ==
                  MediAppHomepageScreen.routeName) {
                return;
              }
              Navigator.of(context).pushNamedAndRemoveUntil(
                MediAppHomepageScreen.routeName,
                (route) => route.isFirst,
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.list_alt),
            title: Text(
              'Quản lý toa thuốc',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            onTap: () {
              Navigator.of(context).pop();
              if (ModalRoute.of(context)?.settings.name ==
                  DrugPrescriptionScreen.routeName) {
                return;
              }
              Navigator.of(context).pushNamedAndRemoveUntil(
                DrugPrescriptionScreen.routeName,
                (route) => route.isFirst,
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.person_outline),
            title: Text(
              'Quản lý người bệnh',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            onTap: () {
              Navigator.of(context).pop();
              if (ModalRoute.of(context)?.settings.name ==
                  PatientScreen.routeName) {
                return;
              }
              Navigator.of(context).pushNamedAndRemoveUntil(
                PatientScreen.routeName,
                (route) => route.isFirst,
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.star),
            title: Text(
              'Danh sách yêu thích',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            onTap: () {
              Navigator.of(context).pop();
              if (ModalRoute.of(context)?.settings.name ==
                  DrugFavoriteScreen.routeName) {
                return;
              }
              Navigator.of(context).pushNamedAndRemoveUntil(
                DrugFavoriteScreen.routeName,
                (route) => route.isFirst,
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: Text(
              'Cài đặt',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            onTap: () {
              Navigator.of(context).pop();
              if (ModalRoute.of(context)?.settings.name ==
                  SettingsScreen.routeName) {
                return;
              }
              Navigator.of(context).pushNamedAndRemoveUntil(
                SettingsScreen.routeName,
                (route) => route.isFirst,
              );
            },
          ),
        ],
      ),
    );
  }
}
