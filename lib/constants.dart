
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class Constants {
  //Primary color
  static var primaryColor = const Color.fromRGBO(184, 143, 113, 1);
  static var blackColor = const Color.fromRGBO(255, 214, 0, 1);
  static var white = const Color.fromRGBO(255,255,255,1);

  static var darkGrey = const Color.fromRGBO(33,37,40,1); 
  //Onboarding texts
  static var titleOne = "Learn more about rocks";
  static var descriptionOne = "Read how to care for rocks in our rich rocks guide.";
  static var titleTwo = "Find a rock lover friend";
  static var descriptionTwo = "Are you a rocks lover? Connect with other rocks lovers.";
  static var titleThree = "Organize your colection";
  static var descriptionThree = "Find almost all types of rocks that you like here.";

  static String GPT_API_KEY = dotenv.env['GPT_API_KEY'] ?? '';

}