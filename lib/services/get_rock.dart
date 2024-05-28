import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_onboarding/models/rocks.dart';
import 'package:flutter_onboarding/services/chat_gpt.dart';
import '../constants.dart';
import 'dart:io';

class GetRockService {

  Future<Rock?> getRock(BuildContext context, File? image ) async {
    var snackbar = ScaffoldMessenger.of(context);
    try{
       if(image != null){
      
      Map<String, dynamic>? chatResponse = await ChatGPTService(apiKey: Constants.GPT_API_KEY).identifyRock(image!);
      if(chatResponse == null) return null;
      print(chatResponse);
      if (chatResponse['error'] != null) {
          print('Error: ${chatResponse['error']}');
          snackbar.showSnackBar(
            SnackBar(content: Text('Error: ${chatResponse['error']}')),
          );
          return null;
      }
      return Rock(RockId: 0, price: 0, category: chatResponse['type'], RockName: chatResponse['rock'], size: "", rating: 5, humidity: 0, temperature: "", imageURL: 'assets/images/rock1.png', isFavorated: false, decription: "", isSelected: false);
    } else {
      return null;
    }
    }catch(e){
      print(e);
    }
   
  }
}
