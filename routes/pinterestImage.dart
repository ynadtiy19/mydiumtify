import 'dart:convert';

import 'package:dart_frog/dart_frog.dart';
import 'package:http/http.dart' as http;

Future<Response> onRequest(RequestContext context) async {
  final queryParams = context.request.uri.queryParameters;
  final url = queryParams['url'] ?? 'beautiful nature image';
  Object isImage = queryParams['isImage'] ?? false;

  try {
    // 请求选定的图片链接
    final imageResponse = await http.get(Uri.parse(url));
    final base64 = base64Encode(imageResponse.bodyBytes);

    if (imageResponse.statusCode == 200 && isImage == true) {
      final contentType = imageResponse.headers['content-type'] ?? 'image/jpeg';
      // 返回图片的二进制数据
      return Response.bytes(
        body: imageResponse.bodyBytes,
        headers: {
          'Content-Type': contentType,
        },
      );
    } else if (imageResponse.statusCode == 200 && isImage == false) {
      final base64 = base64Encode(imageResponse.bodyBytes);
      return Response(body: base64);
    } else {
      return Response.json(
        statusCode: imageResponse.statusCode,
        body: 'Error fetching image: ${imageResponse.reasonPhrase}',
      );
    }
  } catch (e) {
    return Response(body: 'Failed to fetch image $e');
  }
}
