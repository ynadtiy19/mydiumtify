import 'dart:convert';

import 'package:dart_frog/dart_frog.dart';
import 'package:globe_kv/globe_kv.dart';

// 初始化 GlobeKV（可选加上持久化存储）
final kv = GlobeKV('415fa5ffe03eb6c6');
//https://mydiumtify.globeapp.dev/globestore
//key:labimage;value:string
Future<Response> onRequest(RequestContext context) async {
  try {
    final request = context.request;

    // 处理 GET 请求
    if (request.method == HttpMethod.get) {
      final labImage = await kv.getString('labimage');

      if (labImage == null) {
        return Response.json(
          statusCode: 404,
          body: {'message': 'No data found for labimage'},
        );
      }

      return Response.json(
        statusCode: 200,
        body: {'labimage': labImage},
      );
    }

    // 处理 POST 请求
    else if (request.method == HttpMethod.post) {
      final body = await request.body();
      final data = jsonDecode(body);

      if (data is! Map || !data.containsKey('labimage')) {
        return Response.json(
          statusCode: 400,
          body: {'error': 'Missing "labimage" key in request body'},
        );
      }

      final newValue = data['labimage'];
      if (newValue is! String) {
        return Response.json(
          statusCode: 400,
          body: {'error': '"labimage" must be a string'},
        );
      }

      await kv.set('labimage', newValue);

      return Response.json(
        statusCode: 200,
        body: {'message': 'labimage updated successfully'},
      );
    }

    // 不支持的请求方法
    else {
      return Response.json(
        statusCode: 405,
        body: {'error': 'Method not allowed'},
      );
    }
  } catch (e) {
    return Response.json(
      statusCode: 500,
      body: {'error': 'Internal Server Error', 'details': e.toString()},
    );
  }
}
