import 'dart:convert';

import 'package:aiassistant/secrets.dart';
import 'package:http/http.dart' as http;

class OpenAIService {
  final List<Map<String, String>> content = [];

  Future<String> isArtPromptAPI(String prompt) async {
    try {
      final res = await http.post(
        Uri.parse('https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=${Secrets.openAIAPIKey}'),
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "contents": [
            {
              "parts": [
                {
                  "text":
                      'Does the following message want to generate an AI picture, image, art, or anything similar? $prompt. Please answer with "yes" or "no".',
                },
              ],
            },
          ],
        }),
      );

      if (res.statusCode == 200) {
        final body = jsonDecode(res.body);
        print (body);
        final message = body['candidates'][0]['content']['parts'][0]['text'];
        switch (message) {
          case 'yes':
          case 'Yes':
          case 'YES':
          case 'Yes!':
          case 'yes!':
          case 'yes.':
          case 'Yes.':
          case 'YES!':
            final res = await dallEAPI(prompt);
            return res;
          default:
            final res = await chatGPTAPI(prompt);
            return res;
        }
      }
      return 'Error: ${res.statusCode}';
    } catch (e) {
      return e.toString();
    }
  }

  Future<String> chatGPTAPI(String prompt) async {
    print ('-----------------------------------------------------');
    content.add({"role": "user", "parts": prompt});
    try {
            final res = await http.post(
        Uri.parse(
          'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=${Secrets.openAIAPIKey}',
        ),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "contents": [
            {
              "parts": [
                {
                  "text":
                      prompt,
                },
              ],
            },
          ],
        }),
      );

      if (res.statusCode == 200) {
        final body = jsonDecode(res.body);
        print (body);
        String message = body['candidates'][0]['content']['parts'][0]['text'];

        message = message.trim();
        content.add({"role": "model", "parts": message});
        return message;
      }
      return 'Error: ${res.statusCode}';
    } catch (e) {
      return e.toString();
    }
  }

  Future<String> dallEAPI(String prompt) async {
    print ("**********************************");
    content.add({"role": "user", "content": prompt});
    try {
      final res = await http.post(
        Uri.parse(
          'https://generativelanguage.googleapis.com/v1beta/models/imagen-3.0-generate-002:predict?key=${Secrets.openAIAPIKey}',
        ),
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "instances": [
            {"prompt": prompt},
          ],
          "parameters": {"sampleCount": 1},
        }),
      );

      if (res.statusCode == 200) {
        final body = jsonDecode(res.body);
        String imageUrl = body['data'][0]['url'];
        imageUrl = imageUrl.trim();
        content.add({"role": "assistant", "parts": imageUrl});
        return imageUrl;
      }
      return 'Error: ${res.statusCode}';
    } catch (e) {
      return e.toString();
    }
  }
}
