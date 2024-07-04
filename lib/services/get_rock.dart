import 'dart:io';

import 'package:flutter_onboarding/models/rocks.dart';
import 'package:flutter_onboarding/services/chat_gpt.dart';

import '../constants.dart';
import 'check_conecctivity.dart';
import 'snackbar.dart';

class GetRockService {
  Future<Rock?> getRock(File? image) async {
    if (image != null) {
      bool isConnected =
          await CheckConnectivityService().checkIfUserHasConnectivity();
      if (!isConnected) {
        throw Exception(
            'You need to have a internet connection to scann the rock.');
      }
      Map<String, dynamic>? chatResponse =
          await ChatGPTService(apiKey: Constants.gptApiKey).identifyRock(image);
      if (chatResponse == null) {
        throw Exception('Unable to get a response. Please try again later.');
      }
      if (chatResponse['error'] != null) {
        throw Exception(chatResponse['error']);
      }
      String rockName = chatResponse['rock'];
      Rock? localRock = _getLocalRockByName(rockName);

      if (localRock != null) {
        return localRock;
      }
      ShowSnackbarService().showSnackBar(
          "We don't have ${chatResponse['rock']} info in our database.");
      return Rock(
          rockId: 0,
          price: 0,
          category: '',
          rockName: rockName,
          size: "",
          rating: 0,
          humidity: 0,
          temperature: '',
          imageURL: '',
          isFavorited: false,
          description: '',
          isSelected: false,
          formula: "",
          hardness: 0,
          color: "",
          isMagnetic: false,
          healthRisks: "",
          askedQuestions: [],
          crystalSystem: "",
          colors: "",
          luster: "",
          diaphaneity: "",
          quimicalClassification: "",
          elementsListed: "",
          healingPropeties: "",
          formulation: "",
          meaning: "",
          howToSelect: "",
          types: "",
          uses: "");
    } else {
      throw Exception('No image identifyed');
    }
  }

  Future<Map<String, dynamic>> identifyRockPrice(
      String rockName, String? chosenRockForm, String? chosenRockSize) async {
    if (rockName.isNotEmpty) {
      Map<String, dynamic>? chatResponse =
          await ChatGPTService(apiKey: Constants.gptApiKey)
              .identifyRockPrice(rockName, chosenRockForm, chosenRockSize);
      if (chatResponse == null) {
        throw Exception('Unable to get a response. Please try again later.');
      }
      if (chatResponse['error'] != null) {
        throw Exception(chatResponse['error']);
      }
      return chatResponse;
    } else {
      throw Exception('No image identified.');
    }
  }

  Rock? _getLocalRockByName(String rockName) {
    List<Rock> localRocks = Rock.rockList;
    for (Rock rock in localRocks) {
      if (rockName.toLowerCase().contains(rock.rockName.toLowerCase())) {
        return rock;
      }
    }
    return null;
  }
}
