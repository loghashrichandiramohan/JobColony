import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'providers.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();
  final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
  final email = prefs.getString('email');

  runApp(
    ProviderScope(
      overrides: [
        emailProvider.overrideWithProvider(StateProvider<String?>((ref) => email)),
      ],
      child: JobRadarApp(isLoggedIn: isLoggedIn),
    ),
  );
}


class JobRadarApp extends StatelessWidget {
  final bool isLoggedIn;
  const JobRadarApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'JobColony',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      // Start on HomeScreen if logged in, otherwise LoginScreen
      home: isLoggedIn ? const HomeScreen() : const LoginScreen(),
      routes: {
        '/home': (_) => const HomeScreen(),
      },
    );
  }
}
