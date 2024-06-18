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
}
