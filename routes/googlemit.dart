import 'dart:async';
import 'dart:io';
import 'dart:isolate';

import 'package:beautiful_soup_dart/beautiful_soup.dart';
import 'package:dart_frog/dart_frog.dart';
import 'package:http/http.dart' as http;

class TranslationService {
  static const _userAgent =
      'Mozilla/5.0 (Macintosh; Intel Mac OS X 10.11; rv:47.0) Gecko/20100101 Firefox/47.0';

  Future<String> _fetchTranslation(
      String text, String toLang, String fromLang) async {
    final url =
        'https://translate.google.com/m?tl=$toLang&sl=$fromLang&q=${Uri.encodeComponent(text)}';

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {HttpHeaders.userAgentHeader: _userAgent},
      );

      if (response.statusCode != 200) {
        throw HttpException('Failed to translate');
      }

      final soup = BeautifulSoup(response.body);
      return soup.find('div', class_: 'result-container')?.text ?? '';
    } catch (e) {
      throw Exception('An error occurred during translation: $e');
    }
  }

// 使用并发翻译的函数
  Future<Map<String, dynamic>> translateWithParallelProcessing({
    required String text,
    String toLang = 'auto',
    String fromLang = 'auto',
  }) async {
    const int chunkSize = 5000; // 每块文本大小限制
    final numIsolates = 4; // 可以调整 Isolate 的数量以优化性能

    final chunks = await parallelSplitText(text, chunkSize, numIsolates); // 分块
    final translatedChunks = <String>[];

    for (final chunk in chunks) {
      final translatedChunk = await _fetchTranslation(chunk, toLang, fromLang);
      translatedChunks.add(translatedChunk);
    }

    final translatedText = translatedChunks.join(' ');

    return {
      'success': true,
      'data': translatedText,
      'error_message': null,
    };
  }

  // 并发处理文本的函数
  Future<List<String>> parallelSplitText(
      String text, int chunkSize, int numIsolates) async {
    // 计算每个 Isolate 处理的文本范围
    final length = text.length;
    final chunkSizePerIsolate = (length / numIsolates).ceil();

    List<Future<List<String>>> isolateFutures = [];

    // 创建一个用于分割文本的函数
    void isolateEntry(SendPort sendPort) {
      final receivePort = ReceivePort(); // 在函数内部创建 ReceivePort
      receivePort.listen((message) {
        final text = message[0] as String;
        final chunkSize = message[1] as int;
        final chunks = optimizedSplitText(text, chunkSize);
        sendPort.send(chunks);
      });
    }

    // 启动多个 Isolate
    for (int i = 0; i < numIsolates; i++) {
      final receivePort = ReceivePort();
      await Isolate.spawn(isolateEntry, receivePort.sendPort);

      final start = i * chunkSizePerIsolate;
      final end = (i + 1) * chunkSizePerIsolate;
      final subText = text.substring(start, end > length ? length : end);

      // 发送分割任务到 Isolate
      isolateFutures
          .add(receivePort.first.then((chunks) => chunks as List<String>));
    }

    // 等待所有 Isolate 完成并合并结果
    List<List<String>> results = await Future.wait(isolateFutures);
    return results.expand((chunk) => chunk).toList();
  }

  List<String> optimizedSplitText(String text, int chunkSize) {
    List<String> chunks = [];
    StringBuffer buffer = StringBuffer();

    for (int i = 0; i < text.length; i++) {
      buffer.write(text[i]);

      // 每 chunkSize 个字符加入到 chunks 列表，并重置 buffer
      if ((i + 1) % chunkSize == 0 || i == text.length - 1) {
        chunks.add(buffer.toString());
        buffer.clear();
      }
    }

    return chunks;
  }
}

Future<Response> onRequest(RequestContext context) async {
  final service = TranslationService();
  final request = context.request;

  if (request.method != HttpMethod.post) {
    return Response.json(
      body: {
        'success': false,
        'data': null,
        'error_message': 'Only POST method is allowed.',
      },
      statusCode: 405,
    );
  }

  final body = await request.json() as Map<String, dynamic>;
  // 明确将body中的值转换为String类型
  final text = body['text'] as String? ?? ''; // 确保 text 是 String
  final toLang = body['to_lang'] as String? ?? 'auto'; // 确保 toLang 是 String
  final fromLang =
      body['from_lang'] as String? ?? 'auto'; // 确保 fromLang 是 String

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

  final result = await service.translateWithParallelProcessing(
    text: text,
    toLang: toLang,
    fromLang: fromLang,
  );

  return Response.json(
    body: result,
    statusCode: result['success'] == true ? 200 : 500,
  );
}
