import 'package:dart_frog/dart_frog.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

Future<Response> onRequest(RequestContext context) async {
  // 设置 CORS 头

   final headers = {
    'Access-Control-Allow-Origin': '*',  // Allow requests from any origin
    //  'Access-Control-Allow-Origin': 'https://your-frontend-domain.com', //  For production:  Restrict to your frontend's domain.
    'Access-Control-Allow-Methods': 'GET, POST, OPTIONS', //  Specify allowed methods
    'Access-Control-Allow-Headers':
        'Origin, Content-Type, Accept', //  Specify allowed headers
  };

  // Handle OPTIONS requests (preflight)
  if (context.request.method == HttpMethod.options) {
    return Response(statusCode: 204, headers: headers); //  204 No Content for OPTIONS
  }


  // 获取查询参数
  final params = context.request.uri.queryParameters;
  final query = params['q'] ?? 'hello how are you doing?🥰🥰';

  final model = GenerativeModel(
    model: 'gemini-2.0-flash',
    apiKey: 'AIzaSyCLYQaPDW-gTUrBU1nW2kXMHKuNaKMikD8',
    generationConfig: GenerationConfig(
      temperature: 2,
      topK: 64,
      topP: 0.95,
      maxOutputTokens: 65536,
      responseMimeType: 'text/plain',
    ),
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
