import 'dart:convert'; // To handle JSON parsing

import 'package:dart_frog/dart_frog.dart';
import 'package:http/http.dart' as http; // For making HTTP requests

Future<String> fetchLocation(String longitude, String latitude) async {
  const String accessToken =
      'pk.eyJ1IjoiemF0YWUiLCJhIjoiY2wza21vZTZwMDNtNDNwdXRjZHpwbWJlYyJ9.qRHHEJwEov5seQ4iKfpbdw';
  final url =
      'https://api.mapbox.com/geocoding/v5/mapbox.places/$longitude%2C$latitude.json?access_token=$accessToken';

  final response = await http.get(Uri.parse(url));

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    // 将返回值转换为 String 类型
    final placeName = data['features'][1]['place_name'] as String?;
    print('placeName: $placeName');
    return placeName ?? '无法获取位置地址';
  } else {
    return '请求错误: ${response.statusCode}';
  }
}

Future<Response> onRequest(RequestContext context) async {
  //https://mydiumtify.globeapp.dev/myfilebase?url=${Uri.encodeComponent(text)}
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
      orElse: () => null, //这种写法很经典
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
    final String longitudeValue = longitude['value'].toString();
    final String latitudeValue = latitude['value'].toString();
    print('longitudeValue: $longitudeValue');
    print('latitudeValue: $latitudeValue');

    final placeName = await fetchLocation(longitudeValue, latitudeValue);

    // 构建新的 JSON
    final newJson = {
      'placeName': placeName,
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
