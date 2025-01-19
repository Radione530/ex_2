import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:movie_browser/screens/settings_screen.dart';
import 'package:movie_browser/screens/home_screen.dart';
import 'package:movie_browser/screens/auth/login_screen.dart';
import 'package:movie_browser/screens/auth/register_screen.dart';
import 'package:movie_browser/screens/auth/user_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  static MyAppState? of(BuildContext context) {
    return context.findAncestorStateOfType<MyAppState>();
  }

  @override
  MyAppState createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.light;

  void setThemeMode(ThemeMode themeMode) {
    setState(() {
      _themeMode = themeMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Movie Browser',
      theme: ThemeData(
        brightness: Brightness.light,
        primarySwatch: MaterialColor(0xFFD7B899, {
          50: Color(0xFFF9F3ED),
          100: Color(0xFFF2E2D2),
          200: Color(0xFFEAD0B5),
          300: Color(0xFFE2BD99),
          400: Color(0xFFDBAC81),
          500: Color(0xFFD7B899),
          600: Color(0xFFB4916A),
          700: Color(0xFF8F6F4F),
          800: Color(0xFF6A4C34),
          900: Color(0xFF4B311E),
        }),
        scaffoldBackgroundColor: Color(0xFFF9F3ED),
        appBarTheme: AppBarTheme(
          backgroundColor: Color(0xFFD7B899),
          foregroundColor: Colors.black,
        ),
        textTheme: TextTheme(
          bodyLarge: TextStyle(
              color: Color(0xFF4B311E)), // Zmiana z bodyText2 na bodyLarge
        ),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: MaterialColor(0xFF4B311E, {
          50: Color(0xFFEEE7E2),
          100: Color(0xFFD2C4B3),
          200: Color(0xFFB49F7D),
          300: Color(0xFF967A48),
          400: Color(0xFF7A562B),
          500: Color(0xFF4B311E),
          600: Color(0xFF392618),
          700: Color(0xFF281C12),
          800: Color(0xFF1B140D),
          900: Color(0xFF110C08),
        }),
        scaffoldBackgroundColor: Color(0xFF1B140D),
        appBarTheme: AppBarTheme(
          backgroundColor: Color(0xFF4B311E),
          foregroundColor: Colors.white,
        ),
        textTheme: TextTheme(
          bodyLarge: TextStyle(
              color: Color(0xFFD7B899)), // Zmiana z bodyText2 na bodyLarge
        ),
      ),
      themeMode: _themeMode,
      initialRoute: '/home',
      routes: {
        '/home': (context) => HomeScreen(),
        '/settings': (context) => SettingsScreen(),
        '/auth/user': (context) => UserScreen(),
        '/auth/login': (context) => LoginScreen(),
        '/auth/register': (context) => RegisterScreen(),
      },
    );
  }
}
