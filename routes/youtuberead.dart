import 'package:dart_frog/dart_frog.dart';
import 'package:http/http.dart' as http;

Future<Response> onRequest(RequestContext context) async {
  //youtuberead?repo=uu1
  final queryParams = context.request.uri.queryParameters;
  final repo = queryParams['repo'] ?? 'uu1';
  final url =
      'https://api.github.com/repos/ynadtiy19/youtubewords/contents/$repo';
  final response = await http.get(
    Uri.parse(url),
    headers: {
      'Accept': 'application/vnd.github.v3.raw',
      // 在这里可以添加其他自定义的头部
    },
  );

  if (response.statusCode == 200) {
    // 返回文件内容
    return Response(
      body: response.body,
      // headers: {'Content-Type': 'text/html'},//如果需要返回html
    );
  } else {
    // 返回错误消息
    return Response(
      statusCode: response.statusCode,
      body: 'Error fetching file: ${response.reasonPhrase}',
    );
  }
}
