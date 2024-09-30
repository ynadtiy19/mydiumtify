import 'dart:async';

import 'package:dart_frog/dart_frog.dart';
import 'package:http/http.dart' as http;

Future<bool> fetchTranslation() async {
  const String apiUrl = 'https://heroapi-1.onrender.com/api/translate';
  const String text = 'Hello World'; // 需要翻译的文本
  const String targetLanguage = 'es'; // 目标语言

  print('执行了');
  final Map<String, String> queryParams = {
    'text': text,
    'to_lang': targetLanguage,
    'from_lang': 'auto',
  };
  final Uri requestUrl =
      Uri.parse('$apiUrl?${Uri(queryParameters: queryParams).query}');

  // 请求函数
  Future<http.Response?> sendRequest() async {
    try {
      final response =
          await http.get(requestUrl).timeout(Duration(seconds: 30));
      print('测试成功生效');
      return response;
    } on TimeoutException catch (_) {
      print('Request timed out');
      return null; // 返回 null 表示请求超时
    } catch (e) {
      print('Request failed: $e');
      return null; // 返回 null 表示请求失败
    }
  }

  // 第一次请求
  var response = await sendRequest();
  // 最终检查响应状态
  if (response != null && response.statusCode == 200) {
    print('Translation response: 请求成功');
    print(response);
    return true; // 请求成功，返回 true
  } else if (response != null) {
    print('Error: ${response.statusCode} ${response.reasonPhrase}');
    return false; // 请求返回错误状态码，返回 false
  } else {
    print('All attempts failed');
    return false; // 请求失败或超时，返回 false
  }
}

Future<Response> onRequest(RequestContext context) async {
  //carmirest
  bool success = await fetchTranslation();

  if (success) {
    // 如果请求成功，返回 200 状态码和成功消息
    return Response.json(
        body: {'message': 'Translation successful!'}, statusCode: 200);
  } else {
    // 如果请求失败，返回 500 状态码和错误消息
    return Response.json(
        body: {'error': 'Translation failed'}, statusCode: 500);
  }
}
