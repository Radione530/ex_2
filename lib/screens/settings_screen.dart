import 'package:flutter/material.dart';
import 'package:movie_browser/main.dart';

class SettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
      ),
      body: Center(
        child: ListTile(
          title: Text('Dark mode'),
          trailing: Switch(
            value: Theme.of(context).brightness == Brightness.dark,
            onChanged: (bool value) {
              final themeMode = value ? ThemeMode.dark : ThemeMode.light;
              MyApp.of(context)?.setThemeMode(themeMode);
            },
          ),
        ),
      ),
    );
  }
}
