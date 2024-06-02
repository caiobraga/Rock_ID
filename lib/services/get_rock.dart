import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_onboarding/models/rocks.dart';
import 'package:flutter_onboarding/services/chat_gpt.dart';
import '../constants.dart';
import 'dart:io';

class GetRockService {
  Future<Rock?> getRock(BuildContext context, File? image) async {
    try {
      if (image != null) {
        Map<String, dynamic>? chatResponse =
            await ChatGPTService(apiKey: Constants.GPT_API_KEY)
                .identifyRock(image!);
        if (chatResponse == null) return null;
        print(chatResponse);
        if (chatResponse['error'] != null) {
          print('Error: ${chatResponse['error']}');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${chatResponse['error']}')),
          );
          return null;
        }
        return Rock(
            rockId: 0,
            price: 0,
            category: chatResponse['type'],
            rockName: chatResponse['rock'],
            size: "",
            rating: 5,
            humidity: 0,
            temperature: "",
            imageURL: 'assets/images/rock1.png',
            isFavorited: false,
            description: "",
            isSelected: false,
            color: '',
            formula: '',
            hardness: 0,
            isMagnetic: false);
      } else {
        return null;
      }
    } catch (e) {
      print(e);
    }
  }
}
