import 'dart:async';
import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:http/http.dart' as http;

Future<HttpServer> run(Handler handler, InternetAddress ip, int port) {
  // 定义异步请求函数
  Future<void> fetchTranslation() async {
    const String apiUrl = 'https://heroapi-6xl7.onrender.com/api/translate';
    const String text = 'Hello World'; // 需要翻译的文本
    const String targetLanguage = 'es'; // 目标语言

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
<<<<<<< HEAD
            await http.get(requestUrl).timeout(Duration(seconds: 10));
=======
            await http.get(requestUrl).timeout(Duration(seconds: 40));
>>>>>>> c1c66411e2b24ab38a55c0e59d6fa6509e817be0
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

    // 如果第一次请求超时或失败，进行第二次请求
    if (response == null) {
      print('Retrying request...');
      response = await sendRequest();
    }

    // 如果第二次请求超时或失败，等待30秒后再进行最后一次请求
    if (response == null) {
      print('Waiting for 30 seconds before the final retry...');
      await Future.delayed(Duration(seconds: 30));
      response = await sendRequest();
    }

    // 最终检查响应状态
    if (response != null && response.statusCode == 200) {
      print('Translation response: 请求成功');
    } else if (response != null) {
      print('Error: ${response.statusCode} ${response.reasonPhrase}');
    } else {
      print('All attempts failed');
    }
  }

  Timer.periodic(Duration(minutes: 5), (Timer timer) async {
    await fetchTranslation();
  });
  // 1. Execute any custom code prior to starting the server...

  // 2. Use the provided `handler`, `ip`, and `port` to create a custom `HttpServer`.
  // Or use the Dart Frog serve method to do that for you.
  return serve(handler, ip, port);
}
