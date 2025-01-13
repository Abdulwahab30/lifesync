import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:hive_flutter/adapters.dart';
import 'package:provider/provider.dart';
import 'package:todo_app/data/expense_data.dart';
import 'package:todo_app/firebase_options.dart';
import 'package:todo_app/auth/signin_screen.dart';
import 'package:todo_app/notifications/notification_service.dart';

import 'package:todo_app/screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await NotificationService.initializeNotification();
  await requestExactAlarmPermission();
  await NotificationService.scheduleNotificationAtTime();
  await Hive.initFlutter();
  await Hive.openBox("expense_database");
  await AndroidAlarmManager.initialize();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  static GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
        create: (context) => ExpenseData(),
        builder: (context, child) => MaterialApp(
              theme: ThemeData(
                useMaterial3: true,
                fontFamily: 'Poppins', // Set Poppins as the default font
              ),
              debugShowCheckedModeBanner: false,
              title: 'To-Do App',
              home: const AuthCheck(),
            ));
  }
}

// AuthCheck widget to decide which screen to show based on user's authentication status
class AuthCheck extends StatelessWidget {
  const AuthCheck({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream:
          FirebaseAuth.instance.authStateChanges(), // Listen to auth changes
      builder: (context, snapshot) {
        // If user is signed in, go to HomeScreen
        if (snapshot.connectionState == ConnectionState.active) {
          final user = snapshot.data;
          if (user == null) {
            return const SignInScreen(); // If no user is signed in, show SignInScreen
          } else {
            return const HomeScreen(); // If user is signed in, show HomeScreen
          }
        }

        // Show a loading spinner while checking auth state
        return const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        );
      },
    );
  }
}
