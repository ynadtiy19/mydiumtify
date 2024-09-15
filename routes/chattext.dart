import 'package:dart_frog/dart_frog.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

Future<Response> onRequest(RequestContext context) async {
  // 设置 CORS 头
  final corsHeaders = {
    'Access-Control-Allow-Origin': '*', // 允许所有来源
    'Access-Control-Allow-Methods': 'GET, POST, OPTIONS', // 允许的请求方法
    'Access-Control-Allow-Headers': 'Content-Type', // 允许的请求头
  };

  // 处理 OPTIONS 请求
  if (context.request.method == HttpMethod.options) {
    return Response(
      statusCode: 204,
      headers: corsHeaders,
    );
  }

  // 获取查询参数
  final params = context.request.uri.queryParameters;
  final query = params['q'] ?? 'hello how are you doing?🥰🥰';

  final model = GenerativeModel(
    model: 'gemini-1.5-flash-latest',
    apiKey: 'AIzaSyCGGBq3APIQsWqHh9Rg9ZUC5zqpW0d5kYc',
  );
  final chat = model.startChat();

  var responseBody;

  if (query.isNotEmpty) {
    try {
      final response = await chat.sendMessage(Content.text(query));
      responseBody = response.text;
    } catch (e, stackTrace) {
      // 打印错误信息和堆栈轨迹
      print('Error: $e');
      print('Stack Trace: $stackTrace'); // 打印调用堆栈

      // 可以根据异常的类型自定义错误响应
      responseBody = {
        'error': 'Failed to generate content: $e', // 错误信息
        'stackTrace': stackTrace.toString(), // 可选：将堆栈轨迹信息包含进响应中
      };
    }
  } else {
    responseBody = 'This is a new route!';
  }

  // 返回响应并包含 CORS 头
  return Response.json(
    body: {"isSender": false, "text": responseBody},
    headers: corsHeaders,
  );
}
