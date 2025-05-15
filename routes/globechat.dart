import 'package:ai_chat_plus/ai_chat_plus.dart';
import 'package:dart_frog/dart_frog.dart';

Future<Response> onRequest(RequestContext context) async {
  //http://localhost:8080/globechat?q=你是chatgpt吗？
  //https://mydiumtify.globeapp.dev/globechat?q=你是chatgpt吗？
  // 获取查询参数
  final params = context.request.uri.queryParameters;
  final query = params['q'] ?? 'hello how are you doing?🥰🥰';

  try {
    final config = AIModelConfig(
      provider: AIProvider.openAI,
      apiKey:
          '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',
      modelId: OpenAIModel.gpt4Turbo.modelId,
    );

    final aiService = AIServiceFactory.createService(AIProvider.openAI);
    await aiService.initialize(config);

    // Generate response
    final response = await aiService.generateResponse(query);
    // final result = await generateText(
    //   model: openai.chat('gpt-4o'),
    //   prompt: query,
    // );

    return Response.json(
      body: {
        'query': query,
        'response': response,
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
