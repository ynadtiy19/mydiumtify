import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:dart_frog/dart_frog.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:mime/mime.dart';

Future<Response> onRequest(RequestContext context) async {
  //https://mydiumtify.globeapp.dev/chatadvance?q=${Uri.encodeComponent(text)}
  final model = GenerativeModel(
    model: 'gemini-2.0-flash-exp-image-generation',
    apiKey: 'AIzaSyDQKZuhtzW6l4ZcZcCirfHmwth1oqjEe-Q',
    generationConfig: GenerationConfig(
      temperature: 1.8,
      topK: 40,
      topP: 0.95,
      maxOutputTokens: 8192,
      responseMimeType: 'text/plain',
    ),
  );

  if (context.request.method == HttpMethod.post) {
    try {
      final contentType = context.request.headers['content-type'];
      if (contentType != null &&
          contentType.startsWith('multipart/form-data')) {
        final boundary = contentType.split('boundary=')[1];
        final transformer = MimeMultipartTransformer(boundary);

        // Read the entire body as a stream of bytes
        final bodyStream = context.request.bytes().asBroadcastStream();

        final parts = await transformer.bind(bodyStream).toList();

        // Extract image file
        Uint8List? imageData;
        for (var part in parts) {
          final headers = part.headers;
          final contentDisposition = headers['content-disposition'];
          if (contentDisposition != null &&
              contentDisposition.contains('filename=')) {
            final data = await part.toList();
            imageData = Uint8List.fromList(data.expand((x) => x).toList());
            break;
          }
        }

        if (imageData == null) {
          return Response.json(
            statusCode: HttpStatus.badRequest,
            body: {'error': 'No image provided.'},
          );
        }

        // Extract optional query parameter
        final query = context.request.uri.queryParameters['q'] ??
            'What do you see? Use lists. Start with a headline for each image.';

        final content = [
          Content.multi([
            TextPart(query),
            DataPart('image/jpeg', imageData),
          ])
        ];

        // Generate text based on the image
        final responses = model.generateContentStream(content);
        final generatedText = StringBuffer();
        await for (final response in responses) {
          generatedText.write(response.text);
        }

        return Response.json(
            body: {'generated_text': generatedText.toString()});
      } else {
        return Response.json(
          statusCode: HttpStatus.unsupportedMediaType,
          body: {'error': 'Unsupported content type.'},
        );
      }
    } catch (e) {
      print('Error: $e');
      return Response.json(
        statusCode: HttpStatus.internalServerError,
        body: {'error': 'Failed to process the request.'},
      );
    }
  }

  return Response.json(
    statusCode: HttpStatus.methodNotAllowed,
    body: {'error': 'Only POST method is allowed.'},
  );
}
