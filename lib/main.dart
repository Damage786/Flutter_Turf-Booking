import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:uiproject/Screen/Booking_Page.dart';
import 'package:uiproject/Screen/profile_page.dart';
import 'package:uiproject/Screen/registration_page.dart';
import 'package:uiproject/Screen/turf_Detailpage.dart';
import 'package:uiproject/firebase_options.dart';
import 'package:uiproject/utils/auth_managment.dart';
import 'package:uiproject/utils/colors.dart';
import 'package:reactive_theme/reactive_theme.dart';
import 'package:uiproject/Screen/Login_Page.dart';
import 'package:uiproject/Screen/Home_page.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz; // Add your home page import here


void main() async {
   tz.initializeTimeZones();
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  final thememode = await ReactiveMode.getSavedThemeMode();
  runApp(MyApp(savedThemeMode: thememode));
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key, required this.savedThemeMode}) : super(key: key);
  final ThemeMode? savedThemeMode;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => BookingSlotsProvider([]), // Initialize with empty list
      child: ReactiveThemer(
        savedThemeMode: savedThemeMode,
        builder: (reactiveMode) => MaterialApp(
          debugShowCheckedModeBanner: false,
          themeMode: reactiveMode,
          title: 'Reactive Theme Demo',
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
                brightness: Brightness.light, seedColor: Colors.deepPurple),
            useMaterial3: true,
          ),
          darkTheme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
                brightness: Brightness.dark, seedColor: Colors.deepPurple),
            useMaterial3: true,
          ),
          home: Auth(),
          routes: {
            '/login': (context) => const LoginPage(),
            '/registration': (context) => const SignUP(),
            '/profile': (context) => const UserProfilePage(),
            '/booking': (context) => const Booking(),
            // Add your home page route here if you have one
          },
        ),
      ),
    );
  }
}
