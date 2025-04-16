import 'dart:convert';

import 'package:dart_frog/dart_frog.dart';
import 'package:http/http.dart' as http;

Future<Response> onRequest(RequestContext context) async {
  //https://mydiumtify.globeapp.dev/imagebytes?q=一条小溪&rebackimg=true

  final params = context.request.uri.queryParameters;
  final query = params['q'] ?? '一条小河';
  final rebackimg = params['rebackimg']?.toLowerCase() == 'true';

  final headers = {
    'authorization':
        'Bearer ya29.a0AZYkNZjIKZYDBE7P4V42X16j9ab9zJ5AD7dpTVpB6CKoV0-HiDfa2jE6hSv0j7LnmUDAIznSNdMF4hL9y3G7yfu_q5inEPVMTHOHtV8292ymF6Vqq-bZRWdZcZA8pw55kKkpfLnOa8u2Ur_cRZ5n5qW5fwj51U_sTNwVL4voTLNJ_4863SSXese_LyZNICko_Qn3W0EQ6pdbkVDQ1aUwdXnkKsLQ4ASByzlMTtdlMq9-Oy3x9wtdRRx-LIRNf8nMlFiWwsQn3g3JV3vbyYamdix-NZDphTNDHjUkkNk1-PFNADk06SOlGgJFiV2R-aj8nwvCmDkdKgg1QFYlygr-mpn-wxtf9K-Z_gKgQNpZnFaliu3xSLwSwS8R_2ulT013j6AyTTQDznvhPpn3zpvwMpjhx74RO_UYUX8LOFRoaCgYKAQQSARISFQHGX2Mi33Vg6egBm6iXOLaoeRus9Q0431',
    'Content-Type': 'application/json'
  };
  final imagebody = jsonEncode({
    'userInput': {
      'candidatesCount': 1,
      'prompts': [query],
      'mediaCategory': 'MEDIA_CATEGORY_BOARD'
    },
    'clientContext': {'sessionId': ';1744790990107', 'tool': 'BACKBONE'},
    'modelInput': {'modelNameType': 'IMAGEN_3_1'},
    'aspectRatio': 'IMAGE_ASPECT_RATIO_LANDSCAPE'
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
