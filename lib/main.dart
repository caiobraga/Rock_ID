import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_fonts/google_fonts.dart';

import 'constants.dart';
import 'ui/onboarding_screen.dart';

final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    _initVariablesAndStorage();
    super.initState();
  }

  void _initVariablesAndStorage() async {
    await dotenv.load(fileName: ".env");
    final storage = Storage.instance;
    storage.deleteAll();
    final userHistory = await storage.read(key: 'userHistory');

    if (userHistory == null) {
      await storage.write(
        key: 'userHistory',
        value: jsonEncode({
          'numberOfRocksScanned': 0, // PAYWALL
          'firstPaywallShown': false, // RATING
          'firstRockSaved': false, // RATING
          'tenthRockSaved': false, // RATING
        }),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      scaffoldMessengerKey: scaffoldMessengerKey,
      theme: ThemeData(
        textTheme: GoogleFonts.montserratTextTheme(
          Theme.of(context).textTheme,
        ).copyWith(
          titleLarge: GoogleFonts.bebasNeue(),
          titleMedium: GoogleFonts.montserrat(),
          titleSmall: GoogleFonts.bebasNeue(),
        ),
        inputDecorationTheme: InputDecorationTheme(
          hintStyle: const TextStyle(color: Constants.white),
          fillColor: Constants.darkGrey,
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: const BorderSide(color: Constants.primaryColor),
          ),
        ),
        scaffoldBackgroundColor: Colors.black,
      ),
      title: 'Onboarding Screen',
      home: const OnboardingScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
