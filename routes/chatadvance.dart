import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:brotli/brotli.dart';
import 'package:dart_frog/dart_frog.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:http/http.dart' as http;
import 'package:mime/mime.dart';

Future<Response> onRequest(RequestContext context) async {
  //https://mydiumtify.globeapp.dev/chatadvance?q=${Uri.encodeComponent(text)}--post
  //https://mydiumtify.globeapp.dev/chatadvance?imgurl=https://i.pinimg.com/originals/a6/86/8f/a6868f396ee46f41bf7dc86e98220f47.jpg

  if (context.request.method == HttpMethod.post) {
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

  final params = context.request.uri.queryParameters;
  if (params.containsKey('imgurl')) {
    final imgUrl = params['imgurl'];
    String? urlquery = '';
    if (params.containsKey('q')) {
      urlquery = params['q'];
    }
    final url = Uri.parse('https://chat.writingmate.ai/api/chat/public');
    final headers = {
      'CONTENT_TYPE': ' application/json',
      'USER_AGENT':
          ' Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/134.0.0.0 Safari/537.36 Edg/134.0.0.0',
      'REFERER': 'https://labs.writingmate.ai/api/chat/public',
      'ACCEPT': ' */*',
      'ACCEPT_ENCODING': ' gzip, deflate, br, zstd',
      'ACCEPT_LANGUAGE': ' zh-CN,zh;q=0.9',
      'CACHE_CONTROL': ' no-cache',
      'ORIGIN': 'https://labs.writingmate.ai/api/chat/public',
      'PRAGMA': ' no-cache',
      'SEC_FETCH_DEST': ' empty',
      'SEC_FETCH_MODE': ' cors',
      'SEC_FETCH_SITE': ' same-origin',
      'SEC_FETCH_STORAGE_ACCESS': ' active',
      'PRIORITY': ' u=1, i',
      'SEC_CH_UA':
          ' "Chromium";v="134", "Not:A-Brand";v="24", "Microsoft Edge";v="134"',
      'SEC_CH_UA_MOBILE': ' ?0',
      'SEC_CH_UA_PLATFORM': ' "Windows"',
      'Content-Type': 'application/json'
    };
    final body = jsonEncode({
      'response_format': {
        'type': 'json_schema',
        'json_schema': {
          'name': 'image_caption',
          'strict': true,
          'schema': {
            'type': 'object',
            'properties': {
              'caption': {'type': 'string'}
            },
            'required': ['caption'],
            'additionalProperties': false
          }
        }
      },
      'chatSettings': {
        'model': 'gpt-4o-vision',
        'temperature': 0.7,
        'contextLength': 16385,
        'includeProfileContext': false,
        'includeWorkspaceInstructions': false,
        'embeddingsProvider': 'openai'
      },
      'messages': [
        {
          'role': 'user',
          'content': [
            {
              'type': 'image_url',
              'image_url': {'url': imgUrl}
            },
            {
              'type': 'text',
              'text':
                  'Provide a detailed description of this image and at the end of the description to Generate a caption for this image with a romantic and heartfelt sentiment. Include relevant hashtags at the end of the caption.. Include relevant emojis in the caption.. Keep it concise, within 480 characters.',
            },
            {
              'type': 'text',
              'text': urlquery,
            }
          ],
        }
      ],
      'customModelId': '',
    });

    try {
      final response = await http.post(
        url,
        headers: headers,
        body: body, // JSON字符串
      );

      if (response.statusCode == 200) {
        final encoding = response.headers['content-encoding'];

        Uint8List? decodedBytes;
        final compressedBytes = response.bodyBytes;

        if (encoding == 'br') {
          decodedBytes = brotli.decode(compressedBytes) as Uint8List?;
          print('br decoded');
        } else {
          // 无编码或未知编码，直接使用原始数据
          decodedBytes = response.bodyBytes;
          print('no encoding or unknown encoding');
        }

        final jsonString = utf8.decode(decodedBytes! as List<int>);
        final dynamic responseJson = jsonDecode(jsonString);

        final caption = responseJson['caption'];

        return Response.json(body: {'generated_text': caption});
      } else {
        return Response.json(
          statusCode: response.statusCode,
          body: {'error': 'Failed to fetch caption'},
        );
      }
    } catch (e) {
      print('Error: $e');
      return Response.json(
        statusCode: HttpStatus.internalServerError,
        body: {
          'error': 'Failed to process the request.',
          'detail': e.toString()
        },
      );
    }
  } else {
    return Response.json(
        statusCode: 400, body: {'error': 'imgurl parameter is missing'});
  }
}
