import 'dart:io';

import 'package:dart_frog/dart_frog.dart';

Future<Response> onRequest(RequestContext context) async {
  // 指定 MP4 文件路径
  const mp4FilePath =
      "C:\\Users\\LHM\\Videos\\dancer素材\\Snaptik.app_7265660263217581345.mp4";

  // 检查文件是否存在
  final file = File(mp4FilePath);
  if (!file.existsSync()) {
    return Response(
        statusCode: HttpStatus.notFound, body: 'Video file not found');
  }

  try {
    // 读取文件内容
    final videoBytes = await file.readAsBytes();

    // 返回 MP4 文件，设置响应头为 'video/mp4'
    return Response.bytes(
      body: videoBytes,
      headers: {
        'Content-Type': 'video/mp4',
        'Content-Disposition': 'inline; filename="sample.mp4"',
      },
    );
  } catch (e) {
    // 处理文件读取的错误
    return Response(
        statusCode: HttpStatus.internalServerError,
        body: 'Error reading video file: $e');
  }
}
