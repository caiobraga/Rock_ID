import 'dart:io';
import 'package:flutter_onboarding/models/rocks.dart';
import 'package:flutter_onboarding/services/chat_gpt.dart';

import '../constants.dart';
import 'snackbar.dart';

class GetRockService {
  Future<Rock?> getRock(File? image) async {
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
      localRock = localRock?.copyWith(image: image.readAsBytesSync());

      if (localRock != null) {
        return localRock;
      }
      ShowSnackbarService().showSnackBar(
          "we don't have ${chatResponse['rock']} info in our database.");
      return null;
    } else {
      throw Exception('No image identifyed');
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
