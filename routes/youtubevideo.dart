import 'package:dart_frog/dart_frog.dart';
import 'package:http/http.dart' as http;

Future<Response> onRequest(RequestContext context) async {
  //youtubevideo
  const url =
      'https://api.github.com/repos/ynadtiy19/youtubewords/contents/README.md';

  // 请求 GitHub API
  final response = await http.get(
    Uri.parse(url),
    headers: {
      'Accept': 'application/vnd.github.v3.raw',
    },
  );

  if (response.statusCode == 200) {
    // 获取文件内容
    final content = response.body;

    // 分割内容（假设每行是一个链接）
    final lines = content.split('\n');

    // 创建一个 Map 来存储有效的键值对
    final result = <String, String>{};

    // 遍历每一行，并为每个链接生成键值对
    for (int i = 0; i < lines.length; i++) {
      final link = lines[i].trim(); // 去掉前后的空格
      if (link.isNotEmpty) {
        final key = 'uu${result.length + 1}'; // 生成键（uu1, uu2, ...）
        result[key] = link; // 将地址赋值给对应的键
      }
    }

    // Map 来存储最终的跳转链接
    final finalLinks = <String, String>{};

    // 遍历每个链接，获取最终跳转链接
    for (var entry in result.entries) {
      final videoResponse = await http.head(Uri.parse(entry.value));

      if (videoResponse.statusCode == 302 || videoResponse.statusCode == 301) {
        // 获取跳转链接
        final finalUrl = videoResponse.headers['location'];
        if (finalUrl != null) {
          finalLinks[entry.key] = finalUrl; // 将最终链接保存到 finalLinks
        } else {
          finalLinks[entry.key] = 'No redirect found';
        }
      } else {
        finalLinks[entry.key] = 'Error fetching final URL';
      }
    }

    // 返回所有跳转链接的 JSON 响应
    return Response.json(
      body: finalLinks,
      headers: {
        'Content-Type': 'application/json',
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
