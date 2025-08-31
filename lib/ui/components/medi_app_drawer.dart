import 'package:drug_app/screen_routing.dart';
import 'package:drug_app/ui/drug/drug_favorite_screen.dart';
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
              Navigator.of(context).popAndPushNamed(HomePageScreen.routeName);
            },
          ),
          ListTile(
            leading: const Icon(Icons.star),
            title: Text(
              'Danh sách yêu thích',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            onTap: () {
              Navigator.of(
                context,
              ).popAndPushNamed(DrugFavoriteScreen.routeName);
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: Text(
              'Cài đặt',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            onTap: () {
              Navigator.of(context).popAndPushNamed(SettingsScreen.routeName);
            },
          ),
        ],
      ),
    );
  }
}
