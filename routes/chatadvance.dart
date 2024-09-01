import 'dart:io';
import 'dart:typed_data';

import 'package:dart_frog/dart_frog.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:mime/mime.dart';

Future<Response> onRequest(RequestContext context) async {
  //website/chatadvance
  final apiKey = 'AIzaSyD8pA32k91ftgHbqvBto6jj7HIo_LPeRVk';
  final model = GenerativeModel(
    model: 'gemini-1.5-flash-latest',
    apiKey: apiKey,
  );

  if (context.request.method == HttpMethod.post) {
    try {
      final contentType = context.request.headers['content-type'];
      if (contentType != null &&
          contentType.startsWith('multipart/form-data')) {
        final boundary = contentType.split('boundary=')[1];
        final transformer = MimeMultipartTransformer(boundary);
        final bodyStream = context.request.body();
        final parts =
            await transformer.bind(bodyStream as Stream<List<int>>).toList();

        // 提取图片文件
        Uint8List? imageData;
        for (var part in parts) {
          final headers = part.headers;
          final contentDisposition = headers['content-disposition'];
          if (contentDisposition != null &&
              contentDisposition.contains('filename=')) {
            final data = await part
                .toList()
                .then((data) => data.expand((x) => x).toList());
            imageData = Uint8List.fromList(data); // 将 List<int> 转换为 Uint8List
            break;
          }
        }

        if (imageData == null) {
          return Response.json(
            statusCode: HttpStatus.badRequest,
            body: {'error': 'No image provided.'},
          );
        }

        // 提取可选的 query 参数
        final query = context.request.uri.queryParameters['q'] ??
            'What do you see? Use lists. Start with a headline for each image.';

        final content = [
          Content.multi([
            TextPart(query),
            DataPart('image/jpeg', imageData),
          ])
        ];

        // 生成基于图片的文本
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
