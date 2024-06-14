import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_fonts/google_fonts.dart';

class Constants {
  // Primary color
  static var primaryColor = const Color.fromRGBO(184, 143, 113, 1);
  static var blackColor = const Color.fromRGBO(0, 0, 0, 1);
  static var white = const Color.fromRGBO(255, 255, 255, 1);

  static var darkGrey = const Color.fromRGBO(33, 37, 40, 1);
  static var naturalGrey = const Color.fromRGBO(56, 64, 70, 1);

  // Onboarding texts
  static var titleOne = "Learn more about rocks";
  static var descriptionOne =
      "Read how to care for rocks in our rich rocks guide.";
  static var titleTwo = "Find a rock lover friend";
  static var descriptionTwo =
      "Are you a rocks lover? Connect with other rocks lovers.";
  static var titleThree = "Organize your colection";
  static var descriptionThree =
      "Find almost all types of rocks that you like here.";

  static String gptApiKey = dotenv.env['GPT_API_KEY'] ?? '';
}

class AppCollors {
  static Color white = const Color(0xFFFFFFFF);

  // Natural
  static Color naturalBlack = const Color(0xFF1A1918);
  static Color naturalWhite = const Color(0xFFFCFCFC);
  static Color naturalSilver = const Color(0xFFC6CCCA);
  static Color naturalGrey = const Color(0xFF3B4046);

  // Primary
  static Color primaryMedium = const Color(0xFFB88F71);
  static Color primaryDarkest = const Color(0xFF7E4E2B);
}

class AppTypography {
  static TextStyle headline1({Color color = Colors.black}) {
    return GoogleFonts.bebasNeue(
      textStyle: TextStyle(
        fontSize: 36,
        fontWeight: FontWeight.normal,
        color: color,
      ),
    );
  }

  static TextStyle headline2({
    Color color = Colors.black,
    FontWeight fontWeight = FontWeight.normal,
  }) {
    return GoogleFonts.bebasNeue(
      textStyle: TextStyle(
        fontSize: 28,
        fontWeight: fontWeight,
        color: color,
      ),
    );
  }

  static TextStyle body1(
      {Color color = Colors.black,
      TextDecoration decoration = TextDecoration.none,
      Color decorationColor = Colors.black}) {
    return GoogleFonts.montserrat(
      textStyle: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: color,
          decoration: decoration,
          decorationColor: decorationColor),
    );
  } // TextStyle body1(

  static TextStyle body3(
      {Color color = Colors.black,
      TextDecoration decoration = TextDecoration.none,
      Color decorationColor = Colors.black}) {
    return GoogleFonts.montserrat(
      textStyle: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.normal,
          color: color,
          decoration: decoration,
          decorationColor: decorationColor),
    );
  }
}
