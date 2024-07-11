import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ChatGPTService {
  final String apiKey;

  ChatGPTService({required this.apiKey});

  Future<Map<String, dynamic>?> identifyRock(File image) async {
    try {
      final url = Uri.parse('https://api.openai.com/v1/chat/completions');
      final headers = {
        'Authorization': 'Bearer $apiKey',
        'Content-Type': 'application/json',
      };

      final bytes = await image.readAsBytes();
      final base64Image = base64Encode(bytes);

      final body = jsonEncode({
        "model": "gpt-4o",
        "messages": [
          {
            "role": "system",
            "content": [
              {
                'type': 'text',
                'text':
                    "You will help me find the rock in the image and classify them. In your response, I want just a JSON. If you fail to identify, return a JSON like this: {'error': error_message}. If you identify the rock in the image, return like this: {'rock': rock_name, 'type': rock_type}."
              }
            ]
          },
          {
            "role": "user",
            "content": [
              {
                "type": "image_url",
                "image_url": {"url": "data:image/jpeg;base64,$base64Image"}
              }
            ]
          }
        ],
        "temperature": 1,
        "max_tokens": 256,
        "top_p": 1,
        "frequency_penalty": 0,
        "presence_penalty": 0
      });

      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 200) {
        var responseBody = jsonDecode(response.body);
        var responseString = responseBody['choices'][0]['message']['content']
            .replaceAll("```json", "")
            .replaceAll("```", "")
            .trim();
        return jsonDecode(responseString);
      } else {
        return null;
      }
    } catch (e) {
      debugPrint('$e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> identifyRockPrice(
    String rockName,
    String? chosenRockForm,
    String? chosenRockSize,
  ) async {
    try {
      final url = Uri.parse('https://api.openai.com/v1/chat/completions');
      final headers = {
        'Authorization': 'Bearer $apiKey',
        'Content-Type': 'application/json',
      };

      // Constructing the content based on the provided parameters
      String content =
          "You will help me classify the rock named '$rockName', and estimate the price in dollars based on the available information. ";
      if (chosenRockForm != null && chosenRockSize != null) {
        content +=
            "The rock form is '$chosenRockForm' and the size is '$chosenRockSize'. ";
      } else if (chosenRockForm != null) {
        content += "The rock form is '$chosenRockForm'. ";
      } else if (chosenRockSize != null) {
        content += "The rock size is '$chosenRockSize'. ";
      }
      content +=
          "In your response, I want just a JSON. If you fail to identify, return a JSON like this: {'error': error_message}. If you identify the rock and estimate the price, return like this: {'rock': rock_name, 'type': rock_type, 'price': estimated_price, 'price_range': {'min': min_price, 'max': max_price}}.";

      final body = jsonEncode({
        "model": "gpt-4o",
        "messages": [
          {
            "role": "system",
            "content": [
              {'type': 'text', 'text': content}
            ]
          },
          {
            "role": "user",
            "content": [
              {'type': 'text', 'text': rockName},
            ]
          },
          if (chosenRockForm != null)
            {
              "role": "user",
              "content": [
                {'type': 'text', 'text': chosenRockForm},
              ]
            },
          if (chosenRockSize != null)
            {
              "role": "user",
              "content": [
                {'type': 'text', 'text': chosenRockSize},
              ]
            },
        ],
        "temperature": 1,
        "max_tokens": 256,
        "top_p": 1,
        "frequency_penalty": 0,
        "presence_penalty": 0
      });

      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 200) {
        var responseBody = jsonDecode(response.body);
        var responseString = responseBody['choices'][0]['message']['content']
            .replaceAll("```json", "")
            .replaceAll("```", "")
            .trim();
        return jsonDecode(responseString);
      } else {
        return null;
      }
    } catch (e) {
      debugPrint('$e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> identifyRockInfo(String rockName) async {
    try {
      final url = Uri.parse('https://api.openai.com/v1/chat/completions');
      final headers = {
        'Authorization': 'Bearer $apiKey',
        'Content-Type': 'application/json',
      };

      // Constructing the content based on the provided parameters
      String content =
          "You will help find detailed information about the rock named '$rockName'. In your response, I want just a JSON. If you fail to identify, return a JSON like this: {'error': 'error_message'}. If you identify the rock and its detailed information, return like this: {'category': 'Description of the rock category', 'formula': 'Chemical formula of the rock', 'hardness': Average mohs hardness number of the rock as a valid unique double value, 'color': 'Primary color of the rock', 'isMagnetic': true/false, 'healthRisks': 'Potential health risks associated with the rock', 'description': 'General description of the rock', 'luster': 'The luster of the rock', 'crystalSystem': 'The crystal system of the rock', 'colors': 'Possible colors for the rock', 'diaphaneity': 'Transparency of the rock', 'quimicalClassification': 'Chemical classification of the rock', 'elementsListed': 'Elements found in the rock', 'healingPropeties': 'Healing properties attributed to the rock', 'formation': 'Information about how the rock is formed', 'meaning': 'Symbolic meaning of the rock', 'howToSelect': 'Tips on how to select the rock', 'types': 'Different types or varieties of the rock', 'uses': 'Common uses of the rock', 'img1': 'hyperlink of an image of the rock', 'img2': 'hyperlink of another image of the rock', 'cmi1': 'hyperlink of an image of how to identify the rock', 'cmi2': 'hyperlink of another image of how to identify the rock', 'cmi3': 'hyperlink of a third image of how to identify the rock'}. Make sure all the hyperlinks are available.";

      final body = jsonEncode({
        "model": "gpt-4o",
        "messages": [
          {"role": "system", "content": content},
          {"role": "user", "content": rockName}
        ],
        "temperature": 1,
        "max_tokens": 1024,
        "top_p": 1,
        "frequency_penalty": 0,
        "presence_penalty": 0
      });

      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 200) {
        var responseBody = jsonDecode(response.body);
        var responseString = responseBody['choices'][0]['message']['content']
            .replaceAll("```json", "")
            .replaceAll("```", "")
            .trim();
        return jsonDecode(responseString);
      } else {
        return null;
      }
    } catch (e) {
      debugPrint('$e');
      return null;
    }
  }
}
