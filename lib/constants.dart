
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class Constants {
  //Primary color
  static var primaryColor = const Color(0xff296e48);
  static var blackColor = Colors.black54;

  //Onboarding texts
  static var titleOne = "Learn more about rocks";
  static var descriptionOne = "Read how to care for rocks in our rich rocks guide.";
  static var titleTwo = "Find a rock lover friend";
  static var descriptionTwo = "Are you a rocks lover? Connect with other rocks lovers.";
  static var titleThree = "Organize your colection";
  static var descriptionThree = "Find almost all types of rocks that you like here.";

  static String GPT_API_KEY = dotenv.env['GPT_API_KEY'] ?? '';

}