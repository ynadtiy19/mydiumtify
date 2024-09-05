import 'dart:async';
import 'dart:io';

import 'package:beautiful_soup_dart/beautiful_soup.dart';
import 'package:dart_frog/dart_frog.dart';
import 'package:http/http.dart' as http;

class TranslationService {
  static const _userAgent =
      'Mozilla/5.0 (Macintosh; Intel Mac OS X 10.11; rv:47.0) Gecko/20100101 Firefox/47.0';

  Future<Map<String, dynamic>> translate({
    required String text,
    String toLang = 'auto',
    String fromLang = 'auto',
  }) async {
    final url =
        'https://translate.google.com/m?tl=$toLang&sl=$fromLang&q=${Uri.encodeComponent(text)}';

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {HttpHeaders.userAgentHeader: _userAgent},
      );

      if (response.statusCode != 200) {
        return {
          'success': false,
          'data': null,
          'error_message': 'A problem has occurred on our end',
        };
      }

      final soup = BeautifulSoup(response.body);
      final translatedText =
          soup.find('div', class_: 'result-container')?.text ?? '';

      return {
        'success': true,
        'data': translatedText,
        'error_message': null,
      };
    } catch (e) {
      return {
        'success': false,
        'data': null,
        'error_message': 'An error occurred: $e',
      };
    }
  }
}

Future<Response> onRequest(RequestContext context) async {
  final service = TranslationService();
  final queryParams = context.request.uri.queryParameters;

  final text = queryParams['text'] ?? '';
  final toLang = queryParams['to_lang'] ?? 'auto';
  final fromLang = queryParams['from_lang'] ?? 'auto';

  if (text.isEmpty) {
    return Response.json(
      body: {
        'success': false,
        'data': null,
        'error_message': 'Text parameter is required.',
      },
      statusCode: 400,
    );
  }

  final result = await service.translate(
    text: text,
    toLang: toLang,
    fromLang: fromLang,
  );

  return Response.json(
    body: result,
    headers: {'Content-Type': 'application/json'},
    statusCode: result['success'] == true ? 200 : 500,
  );
}
