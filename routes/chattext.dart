import 'package:dart_frog/dart_frog.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

Future<Response> onRequest(RequestContext context) async {
  //website/chattext?q=...
  final params = context.request.uri.queryParameters;
  final query = params['q'] ?? 'hello how are you doing?🥰🥰';

  const apiKey = 'AIzaSyCGGBq3APIQsWqHh9Rg9ZUC5zqpW0d5kYc';

  final model = GenerativeModel(
    model: 'gemini-1.5-flash-latest',
    apiKey: apiKey,
  );
  final chat = model.startChat();

  var responseBody;

  if (query.isNotEmpty) {
    final response = await chat.sendMessage(Content.text(query));
    responseBody = response.text;
  } else {
    responseBody = 'This is a new route!';
  }

  return Response.json(body: {"isSender": false, "text": responseBody});
}
