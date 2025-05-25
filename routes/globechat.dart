import 'package:dart_frog/dart_frog.dart';


Future<Response> onRequest(RequestContext context) async {
  //http://localhost:8080/globechat?q=你是chatgpt吗？
  //https://mydiumtify.globeapp.dev/globechat?q=你是chatgpt吗？
  // 获取查询参数
   return Response.json(
      statusCode: 500,
      body: {
        'error': 'Internal server error',
      },
    );
}
