import 'package:dart_frog/dart_frog.dart';
import 'package:globe_ai/globe_ai.dart';

Future<Response> onRequest(RequestContext context) async {
  //https://mydiumtify.globeapp.dev/globechat?q=你是chatgpt吗？
  // 获取查询参数
  final params = context.request.uri.queryParameters;
  final query = params['q'] ?? 'hello how are you doing?🥰🥰';
  final result = await generateText(
    model: openai.chat('gpt-4.1'),
    prompt: query,
  );
  return Response(body: result);
}
