import 'package:dart_frog/dart_frog.dart';
import 'package:http/http.dart' as http;

Future<Response> onRequest(RequestContext context) async {
  const url =
      'https://api.github.com/repos/ynadtiy19/youtubewords/contents/UREADME.md';

  // 请求 GitHub API
  final response = await http.get(
    Uri.parse(url),
    headers: {
      'Accept': 'application/vnd.github.v3.raw',
      // 在这里可以添加其他自定义的头部
    },
  );

  if (response.statusCode == 200) {
    // 获取文件内容
    final content = response.body;
    print(content);

    // 创建一个 Map 来存储有效的键值对
    final result = <String, String>{};

    // 正则表达式匹配 Markdown 图片链接
    final regex = RegExp(r'!\[.*?\]\((https?://[^\s)]+)\)');
    final matches = regex.allMatches(content);

    // 遍历匹配的链接，生成键值对
    for (var match in matches) {
      final link = match.group(1); // 提取链接部分
      if (link != null && link.isNotEmpty) {
        final key = 'uu${result.length + 1}'; // 生成键（uu1, uu2, ...）
        result[key] = link; // 将地址赋值给对应的键
      }
    }

    // 返回 JSON 格式的响应
    return Response.json(
      body: result,
      headers: {
        'Content-Type': 'application/json', // 设置响应内容类型为 JSON
      },
    );
  } else {
    // 返回错误消息
    return Response.json(
      statusCode: response.statusCode,
      body: 'Error fetching file: ${response.reasonPhrase}',
    );
  }
}
