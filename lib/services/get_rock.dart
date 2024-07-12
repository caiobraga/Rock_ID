import 'dart:io';

import 'package:flutter_onboarding/db/db.dart';
import 'package:flutter_onboarding/models/rocks.dart';
import 'package:flutter_onboarding/services/chat_gpt.dart';

import '../constants.dart';
import 'check_conecctivity.dart';

class GetRockService {
  Future<Rock?> getRock(File? image) async {
    if (image != null) {
      bool isConnected =
          await CheckConnectivityService().checkIfUserHasConnectivity();
      if (!isConnected) {
        throw Exception(
          'You need to have an internet connection to scan a rock.',
        );
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
      Rock? localRock = await _getLocalRockByName(rockName);

      if (localRock != null) {
        return localRock;
      }

      return await getRockInfo(rockName);
    } else {
      throw Exception('No image identifyed');
    }
  }

  Future<Rock> getRockInfo(String rockName) async {
    try {
      final chatResponse = await ChatGPTService(apiKey: Constants.gptApiKey)
          .identifyRockInfo(rockName);
      if (chatResponse == null) {
        throw Exception('Unable to get a response. Please try again later.');
      }
      if (chatResponse['error'] != null) {
        throw Exception(chatResponse['error']);
      }

      final rockList = await DatabaseHelper().incrementDefaultRockList(
        Rock.rockList,
      );

      final lastRock = rockList.reduce(
          (current, next) => current.rockId > next.rockId ? current : next);
      final rockId = lastRock.rockId + 1;

      final newRock = Rock.empty().copyWith(
        rockId: rockId,
        rockName: rockName,
        category: chatResponse['category'],
        formula: chatResponse['formula'],
        hardness: chatResponse['hardness'],
        color: chatResponse['color'],
        isMagnetic: chatResponse['isMagnetic'],
        healthRisks: chatResponse['healthRisks'],
        description: chatResponse['description'],
        luster: chatResponse['luster'],
        crystalSystem: chatResponse['crystalSystem'],
        colors: chatResponse['colors'],
        diaphaneity: chatResponse['diaphaneity'],
        quimicalClassification: chatResponse['quimicalClassification'],
        elementsListed: chatResponse['elementsListed'],
        healingPropeties: chatResponse['healingPropeties'],
        formulation: chatResponse['formation'],
        meaning: chatResponse['meaning'],
        howToSelect: chatResponse['howToSelect'],
        types: chatResponse['types'],
        uses: chatResponse['uses'],
      );

      await DatabaseHelper().insertRock(newRock);
      return newRock;
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<Map<String, dynamic>> identifyRockPrice(
      String rockName, String? chosenRockForm, String? chosenRockSize) async {
    if (rockName.isNotEmpty) {
      final Map<String, dynamic>? chatResponse =
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

  Future<Rock?> _getLocalRockByName(String rockName) async {
    List<Rock> localRocks = Rock.rockList;
    final rockList =
        await DatabaseHelper().incrementDefaultRockList(localRocks);
    for (Rock rock in rockList) {
      if (rockName.toLowerCase().contains(rock.rockName.toLowerCase())) {
        return rock;
      }
    }
    return null;
  }
}
