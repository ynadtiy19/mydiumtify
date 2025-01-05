import 'package:dart_frog/dart_frog.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

Future<Response> onRequest(RequestContext context) async {
  // 设置 CORS 头

  // 获取查询参数
  final params = context.request.uri.queryParameters;
  final query = params['q'] ?? 'hello how are you doing?🥰🥰';

  final model = GenerativeModel(
    model: 'gemini-1.5-flash-latest',
    apiKey: 'AIzaSyBrQnxIMC5oREZUsQzaO9ijzTmZo7WRMbk',
  );
  final chat = model.startChat();

  var responseBody;

  if (query.isNotEmpty) {
    try {
      final response = await chat.sendMessage(Content.text(query));
      responseBody = response.text;
    } catch (e, stackTrace) {
      print('Error: $e');
      print('Stack Trace: $stackTrace');
      responseBody = {
        'error': 'Failed to generate content: $e',
        'stackTrace': stackTrace.toString(),
      };
    }
  } else {
    responseBody = 'This is a new route!';
  }

  return Response.json(
    body: {"isSender": false, "text": responseBody},
  );
}
