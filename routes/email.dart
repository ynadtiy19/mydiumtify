import 'dart:convert';

import 'package:dart_frog/dart_frog.dart';
import 'package:http/http.dart' as http;

const String emailApiUrl = 'https://freeemailapi.vercel.app/sendEmail/';

Future<Response> onRequest(RequestContext context) async {
  //send-email
  // 检查请求方法是否为 POST
  if (context.request.method == HttpMethod.post) {
    try {
      // 解析请求体中的 JSON 数据
      final body = await context.request.json() as Map<String, dynamic>;

      // 检查请求体是否包含所需的字段
      if (!body.containsKey('toEmail') ||
          !body.containsKey('title') ||
          !body.containsKey('subject') ||
          !body.containsKey('body')) {
        return Response.json(
            statusCode: 400, body: {'error': 'Missing required fields'});
      }

      // 构建 HTTP POST 请求，发送邮件数据到外部 API
      var response = await http.post(
        Uri.parse(emailApiUrl),
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          'toEmail': body['toEmail'],
          'title': body['title'],
          'subject': body['subject'],
          'body': body['body'],
        }),
      );

      // 处理外部 API 响应
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return Response.json(body: responseData);
      } else {
        return Response.json(
            statusCode: response.statusCode,
            body: {'error': 'Failed to send email'});
      }
    } catch (e) {
      return Response.json(
          statusCode: 500, body: {'error': 'Internal server error'});
    }
  }

  // 如果请求不是 POST 请求，返回 405 Method Not Allowed
  return Response(statusCode: 405, body: 'Method not allowed');
}
