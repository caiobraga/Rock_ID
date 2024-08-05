import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_onboarding/services/payment_service.dart';
import 'package:flutter_onboarding/ui/pages/premium_page.dart';
import 'package:flutter_onboarding/ui/pages/widgets/loading_component.dart';
import 'package:flutter_onboarding/ui/root_page.dart';
import 'package:google_fonts/google_fonts.dart';

import 'constants.dart';
import 'ui/onboarding_screen.dart';

final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Widget? firstShowPage = const OnboardingScreen();

  @override
  void initState() {
    super.initState();
    _initVariablesAndStorage().then((value) => setState(() {}));
  }

  Future<void> _initVariablesAndStorage() async {
    await dotenv.load(fileName: ".env");
    final storage = Storage.instance;
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
    } else if (jsonDecode(userHistory)['firstPaywallShown']) {
      if (await PaymentService.checkIfPurchased()) {
        firstShowPage = const RootPage();
      } else {
        firstShowPage = const PremiumPage(
          isFromOnboarding: true,
        );
      }
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      scaffoldMessengerKey: scaffoldMessengerKey,
      theme: ThemeData(
        dividerTheme: const DividerThemeData(color: Colors.transparent),
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
      title: 'Gem Identifier',
      home: firstShowPage ?? const LoadingComponent(),
      debugShowCheckedModeBanner: false,
    );
  }
}
