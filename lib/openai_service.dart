import 'dart:convert';

import 'package:aiassistant/secrets.dart';
import 'package:http/http.dart' as http;

class OpenAIService {
  final List<Map<String,String>> content =[];
  Future <String> isArtPromptAPI(String prompt) async {
  try{
     final res = await http.post(
        Uri.parse('https://openrouter.ai/api/v1/chat/completions'),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer ${Secrets.openAIAPIKey}",
        },
        body: jsonEncode({
          "model": "openai/gpt-4o",
          "messages": [
            {
              "role": "developer",
              "content":
                  'You are a helpful assistant.',
            },
            {
              "role": "user",
              "content":
                  'Does the following message want to generate an AI picture, image, art, or anything similar? $prompt. Please answer with "yes" or "no".',
            },
          ],
          "temperature": 0,
        }),
      );

      if (res.statusCode == 200) {
        final body = jsonDecode(res.body);
        final message = body['choices'][0]['message']['content'];
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
    }catch (e) {
      return e.toString();
    }
  }
  Future<String> chatGPTAPI(String prompt) async {
    content.add({
      "role": "user", 
      "content": prompt
      });
    try {
      final res = await http.post(
        Uri.parse('https://openrouter.ai/api/v1/chat/completions'),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer ${Secrets.openAIAPIKey}",
        },
        body: jsonEncode({
          "model": "openai/gpt-4o",
          "messages": content,
          "temperature": 0,
        }),
      );

      if (res.statusCode == 200) {
        final body = jsonDecode(res.body);
        String message = body['choices'][0]['message']['content'];
        message = message.trim();
        content.add({
          "role": "assistant",
          "content": message
        });
        return message;}
      return 'Error: ${res.statusCode}';
    } catch (e) {
      return e.toString();
    }
  }
  Future<String> dallEAPI(String prompt) async {
    content.add({"role": "user", "content": prompt});
    try {
      final res = await http.post(
        Uri.parse('https://openrouter.ai/api/v1/images/generation'),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer ${Secrets.openAIAPIKey}",
        },
        body: jsonEncode({
          "model": "openai/dall-e",
          "prompt": prompt,
          "n": 1,
          
        }),
      );

      if (res.statusCode == 200) {
        final body = jsonDecode(res.body);
        String imageUrl = body['data'][0]['url'];
        imageUrl = imageUrl.trim();
        content.add({"role": "assistant", "content": imageUrl});
        return imageUrl;
      }
      return 'Error: ${res.statusCode}';
    } catch (e) {
      return e.toString();
    }
  }
 }