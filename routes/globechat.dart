import 'dart:async';
import 'dart:convert';

import 'package:dart_frog/dart_frog.dart';
import 'package:http/http.dart' as http;

const _apiKey = 'AIzaSyCiqhLiPhtOXq0vQPtcv6-3nCEkpugU_3o';
const _modelId = 'veo-2.0-generate-001';

Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.post) {
    return Response(statusCode: 405, body: 'Method Not Allowed');
  }

  try {
    final body = await context.request.json() as Map<String, dynamic>;
    final prompt = body['promotes'] as String?;

    if (prompt == null || prompt.isEmpty) {
      return Response.json(
        statusCode: 400,
        body: {'error': 'Missing or empty "promotes" field'},
      );
    }

    // Step 1: 构造请求 JSON
    final requestPayload = {
      "instances": [
        {
          "prompt": prompt,
        }
      ],
      "parameters": {
        "personGeneration": "dont_allow",
        "aspectRatio": "16:9",
        "sampleCount": 1,
        "durationSeconds": 8,
      }
    };

    // Step 2: 发起视频生成请求
    final response = await http.post(
      Uri.parse(
        'https://generativelanguage.googleapis.com/v1beta/models/$_modelId:predictLongRunning?key=$_apiKey',
      ),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(requestPayload),
    );

    final json = jsonDecode(response.body);
    final opName = json['name'];
    if (opName == null) {
      return Response.json(
        statusCode: 500,
        body: {'error': 'Failed to start video generation', 'details': json},
      );
    }

    // Step 3: 轮询获取视频生成状态
    dynamic? videoUrl;
    for (int i = 0; i < 30; i++) {
      await Future.delayed(const Duration(seconds: 10));
      final checkResponse = await http.get(Uri.parse(
        'https://generativelanguage.googleapis.com/v1beta/$opName?key=$_apiKey',
      ));
      final checkJson = jsonDecode(checkResponse.body);

      if (checkJson['done'] == true) {
        videoUrl = checkJson['response']?['generateVideoResponse']
            ?['generatedSamples']?[0]?['video']?['uri'];
        break;
      }
    }

    if (videoUrl == null) {
      return Response.json(
        statusCode: 504,
        body: {'error': 'Video generation timed out'},
      );
    }

    return Response.json(
      statusCode: 200,
      body: {
        'message': 'Video generated successfully',
        'video_url': videoUrl,
      },
    );
  } catch (e) {
    return Response.json(
      statusCode: 500,
      body: {'error': 'Internal server error', 'details': e.toString()},
    );
  }
}
