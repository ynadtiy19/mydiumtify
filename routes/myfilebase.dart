import 'dart:convert'; // To handle JSON parsing

import 'package:dart_frog/dart_frog.dart';
import 'package:http/http.dart' as http; // For making HTTP requests

Future<Response> onRequest(RequestContext context) async {
  // 从查询参数中获取 url
  final queryParams = context.request.uri.queryParameters;
  final url = queryParams['url'];

  if (url == null) {
    return Response(statusCode: 400, body: '缺少 url 参数');
  }

  try {
    // 发起 GET 请求获取数据
    final response = await http.get(Uri.parse(url));

    if (response.statusCode != 200) {
      return Response(
          statusCode: 500, body: '请求失败，状态码为 ${response.statusCode}');
    }

    // 解析获取到的 JSON 数据
    final jsonData = jsonDecode(response.body);

    // 提取需要的字段
    final attributes = jsonData['attributes'] as List<dynamic>;
    final captureDate = attributes.firstWhere(
      (attr) => attr['trait_type'] == 'Capture date',
      orElse: () => null,
    );
    final longitude = attributes.firstWhere(
      (attr) => attr['trait_type'] == 'Longitude',
      orElse: () => null,
    );
    final latitude = attributes.firstWhere(
      (attr) => attr['trait_type'] == 'Latitude',
      orElse: () => null,
    );
    final name = jsonData['name'];

    if (captureDate == null ||
        longitude == null ||
        latitude == null ||
        name == null) {
      return Response(
          statusCode: 400, body: '缺少必要的字段：captureDate、longitude、latitude、name');
    }

    // 构建新的 JSON
    final newJson = {
      'date': captureDate['value'],
      'Longitude': longitude['value'],
      'Latitude': latitude['value'],
      'name': name,
    };

    // 返回新的 JSON 响应
    return Response.json(body: newJson);
  } catch (e) {
    return Response(statusCode: 500, body: '请求失败: $e');
  }
}
