import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;

class AnthropicService {
  static const String _apiKey = 'YOUR_API_KEY_HERE';
  static const String _baseUrl = 'https://api.anthropic.com/v1/messages';

  static Future<List<Map<String, dynamic>>> extractRosterFromImage(
      Uint8List imageBytes, String mediaType) async {
    try {
      final base64Image = base64Encode(imageBytes);

      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'x-api-key': _apiKey,
          'anthropic-version': '2023-06-01',
        },
        body: jsonEncode({
          'model': 'claude-opus-4-6',
          'max_tokens': 1024,
          'messages': [
            {
              'role': 'user',
              'content': [
                {
                  'type': 'image',
                  'source': {
                    'type': 'base64',
                    'media_type': mediaType,
                    'data': base64Image,
                  },
                },
                {
                  'type': 'text',
                  'text': '''You are an expert at reading airline crew rosters. 
Extract all flight duties from this roster image.

Return ONLY a JSON array with no other text, markdown, or explanation.
Each object must have exactly these fields:
- flightNumber: string (e.g. "AK6101")
- date: string (e.g. "Mon 16 Jun")  
- departureTime: string in HH:MM format (e.g. "05:30")
- airport: string (e.g. "SZB", "KLIA", "KUL")
- dutyType: string ("outbound" or "inbound")

Example output:
[{"flightNumber":"AK6101","date":"Mon 16 Jun","departureTime":"05:30","airport":"SZB","dutyType":"outbound"}]

If you cannot read the roster clearly, return an empty array: []'''
                }
              ],
            }
          ],
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final text = data['content'][0]['text'] as String;
        final cleaned = text
            .replaceAll('```json', '')
            .replaceAll('```', '')
            .trim();
        final List<dynamic> flights = jsonDecode(cleaned);
        return flights.cast<Map<String, dynamic>>();
      } else {
        throw Exception('API error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to extract roster: $e');
    }
  }
}