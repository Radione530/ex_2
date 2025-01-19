import 'package:flutter/material.dart';
import 'package:movie_browser/main.dart';

class SettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
        backgroundColor: isDarkMode ? Colors.brown[900] : Colors.brown[200],
      ),
      body: Container(
        color: isDarkMode ? Colors.brown[800] : Colors.brown[100],
        child: Center(
          child: ListTile(
            title: Text(
              'Dark mode',
              style: TextStyle(
                color: isDarkMode ? Colors.white : Colors.brown[800],
              ),
            ),
            trailing: Switch(
              value: isDarkMode,
              onChanged: (bool value) {
                final themeMode = value ? ThemeMode.dark : ThemeMode.light;
                MyApp.of(context)?.setThemeMode(themeMode);
              },
              activeColor: Colors.brown[600],
            ),
          ),
        ),
      ),
    );
  }
}
