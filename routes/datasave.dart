import 'dart:async';

import 'package:dart_frog/dart_frog.dart';
import 'package:mysql1/mysql1.dart';

// 创建数据库连接
Future<MySqlConnection> connectToDatabase() async {
  final settings = ConnectionSettings(
    host: '69.165.65.242', // 数据库地址
    port: 3306, // 数据库端口
    user: 'yunyurest', // 数据库用户名
    db: 'yunyurest', // 数据库名
    password: 'W2XmNSXm84nGAexG', // 数据库密码
  );

  try {
    final connection = await MySqlConnection.connect(settings);
    print('Database connection successful');
    return connection;
  } catch (e) {
    print('Database connection failed: $e');
    throw Exception('Failed to connect to the database');
  }
}

// 处理请求
Future<Response> onRequest(RequestContext context) async {
  //datasave
  if (context.request.method == HttpMethod.post) {
    final body = await context.request.json();

    // 从请求体中获取数据
    final key = body['key'];
    final deviceId = body['deviceId'];

    // 尝试连接到数据库
    try {
      final conn = await connectToDatabase();

      try {
        // 插入数据
        await conn.query(
          'INSERT INTO your_table (key, deviceId) VALUES (?, ?)',
          [key, deviceId],
        );
        print('Data inserted successfully: key=$key, deviceId=$deviceId');

        // 返回成功响应
        return Response.json(
          body: {'message': 'Data added successfully'},
          statusCode: 200,
        );
      } catch (e) {
        print('Data insertion failed: $e');
        return Response.json(
          body: {'error': 'Failed to add data: $e'},
          statusCode: 500,
        );
      } finally {
        // 关闭数据库连接
        await conn.close();
        print('Database connection closed');
      }
    } catch (e) {
      // 捕获数据库连接错误
      return Response.json(
        body: {'error': 'Database connection failed: $e'},
        statusCode: 500,
      );
    }
  }

  // 请求方法不支持
  return Response.json(
    body: {'error': 'Unsupported method'},
    statusCode: 405,
  );
}
