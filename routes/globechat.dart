import 'package:dart_frog/dart_frog.dart';
import 'package:globe_ai/globe_ai.dart';

Future<Response> onRequest(RequestContext context) async {
  //http://localhost:8080/globechat?q=你是chatgpt吗？
  //https://mydiumtify.globeapp.dev/globechat?q=你是chatgpt吗？
  // 获取查询参数
  final params = context.request.uri.queryParameters;
  final query = params['q'] ?? 'hello how are you doing?🥰🥰';

  try {
    final result = await generateText(
      model: openai.chat('gpt-4o'),
      prompt: query,
    );

    return Response.json(
      body: {
        'query': query,
        'response': result,
      },
    );
  } catch (e, stackTrace) {
    // 日志输出（可替换为更专业的日志工具）
    print('Error generating text: $e');
    print(stackTrace);

    return Response.json(
      statusCode: 500,
      body: {
        'error': 'Internal server error',
        'details': e.toString(),
      },
    );
  }
}
