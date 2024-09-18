import 'dart:async';
import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:http/http.dart' as http;

Future<HttpServer> run(Handler handler, InternetAddress ip, int port) async {
  // 创建 public 文件夹及其子文件夹
  Future<void> createDirectories() async {
    final Directory publicDir = Directory('public');

    if (!publicDir.existsSync()) {
      await publicDir.create();
      print('Created public directory.');

      // 创建 images 文件夹
      final Directory imagesDir = Directory('public/images');
      await imagesDir.create();
      print('Created public/images directory.');

      // 创建 videos 文件夹
      final Directory videosDir = Directory('public/videos');
      await videosDir.create();
      print('Created public/videos directory.');

      // 创建 txt 文件并写入内容
      final File txtFile = File('${publicDir.path}/message.txt');
      await txtFile.writeAsString('你好世界');
      print('Created message.txt with content: 你好世界');
    } else {
      print('Public directory already exists.');
    }
  }

  // 调用确保目录存在
  await createDirectories();

  // 定义异步请求函数
  Future<void> fetchTranslation() async {
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
      // print('Translation response: 请求成功');
      print(response);
    } else if (response != null) {
      print('Error: ${response.statusCode} ${response.reasonPhrase}');
    } else {
      print('All attempts failed');
    }
  }

  Timer.periodic(Duration(seconds: 120), (Timer timer) async {
    await fetchTranslation();
  });

  // 1. Execute any custom code prior to starting the server...

  // 2. Use the provided `handler`, `ip`, and `port` to create a custom `HttpServer`.
  // Or use the Dart Frog serve method to do that for you.
  return serve(handler, ip, port);
}
