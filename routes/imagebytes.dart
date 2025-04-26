import 'dart:convert';

import 'package:dart_frog/dart_frog.dart';
import 'package:http/http.dart' as http;

Future<Response> onRequest(RequestContext context) async {
  //https://mydiumtify.globeapp.dev/imagebytes?q=%E4%B8%80%E6%9D%A1%E5%B0%8F%E6%BA%AA&rebackimg=true&aspect=PORTRAIT

  //aspect=PORTRAIT,SQUARE,LANDSCAPE

  
  final params = context.request.uri.queryParameters;
  final query = params['q'] ?? '一条小河';
  final rebackimg = params['rebackimg']?.toLowerCase() == 'true';
  final aspect =
      params['aspect']?.toUpperCase() ?? 'LANDSCAPE'; // 默认值为 'LANDSCAPE'

  final headers = {
    'accept': '*/*',
    'accept-encoding': 'gzip, deflate, br, zstd',
    'accept-language': 'en-US,en;q=0.9',
    'authorization':
        'Bearer ya29.a0AZYkNZg9ImsKCGBH5Wmskg1T0qUfvz63J8BXuCxvGmRMRRnm_MORzbOBQMGlMPGOkJsH0Us7x21DZFzksEAkYqTe73LoJP_W3HTbfO9PeB3OFgkDr92wMYX51FLUwsJgRtYak-F6mlDSo6fUguDPizDYrYZtaPr4nHAFiNr-8UUGfhrnp4oegWG-BThi1Oqe8bqexXXz8VV7gsl-pLisk26EP0Y5h7xJk7fNPSWFMu3ytN0mZDW8XRRTgdqRb3IXPdQas4VY7plTyZKt6HhpkjPv3h-FG2AJaSMsHXzRayR_Zmo7tZzYmwNoRry2LdQAeh3cwyefpeg9dBKKUJK7CbWi3kfkjYwG0BVrQz6TnuN5tQYJjrEHNnULNYzrBDTtGEhaX4_Pk8knRkhYzGIMKmaJrxuzRSsxPebr0S-SeAaCgYKAUUSARISFQHGX2MizzvwIp176u-HXgn-SOb9Pw0433',
    'cache-control': 'no-cache',
    'content-type': 'text/plain;charset=UTF-8',
    'origin': 'https://labs.google',
    'pragma': 'no-cache',
    'priority': 'u=1, i',
    'referer': 'https://labs.google/',
    'sec-ch-ua':
        '"Chromium";v="136", "Microsoft Edge";v="136", "Not.A/Brand";v="99"',
    'sec-ch-ua-mobile': '?0',
    'sec-ch-ua-platform': '"Windows"',
    'sec-fetch-dest': 'empty',
    'sec-fetch-mode': 'cors',
    'sec-fetch-site': 'cross-site',
    'user-agent':
        'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36',
  };

  final imagebody = jsonEncode({
    'userInput': {
      'candidatesCount': 1,
      'prompts': [query],
      'mediaCategory': 'MEDIA_CATEGORY_BOARD'
    },
    'clientContext': {
      'sessionId': ';${DateTime.now().millisecondsSinceEpoch}',
      'tool': 'BACKBONE',
    },
    'modelInput': {'modelNameType': 'IMAGEN_3_1'},
    'aspectRatio':
        'IMAGE_ASPECT_RATIO_$aspect', // 拼接 aspect 到 IMAGE_ASPECT_RATIO
  });

  final response = await http.post(
    Uri.parse('https://aisandbox-pa.googleapis.com/v1:runImageFx'),
    body: imagebody,
    headers: headers,
  );

  if (response.statusCode == 200) {
    final json = jsonDecode(response.body);

    final encodedStr =
        json['imagePanels']?[0]?['generatedImages']?[0]?['encodedImage'];
    if (encodedStr == null) {
      return Response(body: 'No image found in response');
    }

    // 解码 base64 为字节数据
    final compressedBytes = base64Decode(encodedStr as String);
    if (rebackimg) {
      return Response.bytes(
        body: compressedBytes,
        headers: {
          'Content-Type': 'image/png', // 你可以根据实际图片类型动态设置
        },
      );
    } else {
      return Response(body: encodedStr, headers: {
        'Content-Type': 'text/plain; charset=utf-8',
      });
    }
  } else {
    return Response.json(
      statusCode: response.statusCode,
      body: {'error': '请求失败', 'message': response.reasonPhrase},
    );
  }
}
