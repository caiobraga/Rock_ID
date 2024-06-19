import 'dart:io';
import 'package:flutter_onboarding/models/rocks.dart';
import 'package:flutter_onboarding/services/chat_gpt.dart';

import '../constants.dart';

class GetRockService {
  Future<Rock> getRock(File? image) async {
    if (image != null) {
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
          isMagnetic: false,
          healthRisks: '',
          askedQuestions: [],
          crystalSystem: '',
          colors: '',
          luster: '',
          diaphaneity: '',
          quimicalClassification: '',
          elementsListed: '',
          healingPropeties: '',
          formulation: '',
          meaning: '',
          howToSelect: '',
          types: '',
          uses: '');
    } else {
      throw Exception('No image identifyed');
    }
  }

  Rock? _getLocalRockByName(String rockName) {
    List<Rock> localRocks = Rock.rockList;
    for (Rock rock in localRocks) {
      if (rock.rockName.toLowerCase() == rockName.toLowerCase()) {
        return rock;
      }
    }
    return null;
  }
}
