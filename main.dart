import 'dart:io';

import 'package:dart_frog/dart_frog.dart';

// 1. 创建一个处理 CORS 头的中间件
Middleware addCorsHeaders() {
  return (handler) {
    return (context) async {
      // 2. 在处理请求前添加 CORS 头部
      final response = await handler(context);
      return response.copyWith(
        headers: {
          ...response.headers,
          'Access-Control-Allow-Origin': '*', // 允许来自任何源,  生产环境替换为你的前端域名
          'Access-Control-Allow-Methods':
              'GET, POST, PUT, DELETE, OPTIONS', // 允许的方法
          'Access-Control-Allow-Headers':
              'Origin, Content-Type, Accept, Authorization', // 允许的头部
        },
      );
    };
  };
}

Future<HttpServer> run(Handler handler, InternetAddress ip, int port) {
  // 1.  使用 `Pipeline()` 和 `addMiddleware()` 添加 CORS 中间件.
  final pipeline = const Pipeline().addMiddleware(addCorsHeaders());
  // 2. 将处理管道应用于handler
  final handlerWithCors = pipeline.addHandler(handler);

  // 3. 使用处理了CORS的handler启动服务.
  return serve(handlerWithCors, ip, port);
}
