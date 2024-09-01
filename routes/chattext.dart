import 'package:dart_frog/dart_frog.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

Future<Response> onRequest(RequestContext context) async {
  //website/chattext?q=...
  final params = context.request.uri.queryParameters;
  final query = params['q'] ?? 'hello how are you doing?🥰🥰';

  final apiKey = 'AIzaSyCGGBq3APIQsWqHh9Rg9ZUC5zqpW0d5kYc';

  final model = GenerativeModel(
    model: 'gemini-1.5-flash-latest',
    apiKey: apiKey,
  );
  final chat = model.startChat();

  final prompt = '$query';
  var responseBody;

  if (prompt.isNotEmpty) {
    try {
      final response = await chat.sendMessage(Content.text(prompt));
      responseBody = response.text;
    } catch (e) {
      print('Error: $e');
      responseBody = {'error': 'Failed to generate content'};
    }
  } else {
    responseBody = 'This is a new route!';
  }

  return Response.json(body: responseBody);
}
