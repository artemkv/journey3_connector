import 'package:http/http.dart' as http;
import 'dart:convert';

import 'domain.dart';

const journeyBaseUrl = 'https://journey3-ingest.artemkv.net:8060';
const postSessionTimeout = Duration(seconds: 30);

class RestApi {
  Future<void> postSessionHeader(SessionHeader header) async {
    final client = http.Client();
    try {
      final url = Uri.parse('$journeyBaseUrl/session_head');
      final bodyText = jsonEncode(header);
      final response =
          await client.post(url, body: bodyText).timeout(postSessionTimeout);
      if (response.statusCode >= 400) {
        ApiResponseError errorResponse =
            ApiResponseError.fromJson(jsonDecode(response.body));
        throw Exception(
            'POST returned ${response.statusCode} ${response.reasonPhrase}: ${errorResponse.error}');
      }
    } catch (err) {
      throw Exception(
          'Error sending session header to Journey: ${err.toString()}');
    } finally {
      client.close();
    }
  }

  Future<void> postSession(Session session) async {
    final client = http.Client();
    try {
      final url = Uri.parse('$journeyBaseUrl/session_tail');
      final bodyText = jsonEncode(session);
      final response =
          await client.post(url, body: bodyText).timeout(postSessionTimeout);
      if (response.statusCode >= 400) {
        ApiResponseError errorResponse =
            ApiResponseError.fromJson(jsonDecode(response.body));
        throw Exception(
            'POST returned ${response.statusCode} ${response.reasonPhrase}: ${errorResponse.error}');
      }
    } catch (err) {
      throw Exception('Error sending session to Journey: ${err.toString()}');
    } finally {
      client.close();
    }
  }
}
