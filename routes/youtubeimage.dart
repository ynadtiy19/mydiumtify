import 'package:dart_frog/dart_frog.dart';
import 'package:http/http.dart' as http;

Future<Response> onRequest(RequestContext context) async {
  //youtubeimage
  const url =
      'https://api.github.com/repos/ynadtiy19/youtubewords/contents/UREADME.md';

  final response = await http.get(
    Uri.parse(url),
    headers: {
      'Accept': 'application/vnd.github.v3.raw',
    },
  );

  if (response.statusCode == 200) {
    final content = response.body;
    final result = <String, String>{};

    // 正则表达式匹配 Markdown 图片链接
    final regex = RegExp(r'!\[.*?\]\((https?://[^\s)]+)\)');
    final matches = regex.allMatches(content);

    for (var match in matches) {
      final link = match.group(1); // 提取链接部分
      if (link != null && link.isNotEmpty) {
        final key = 'uu${result.length + 1}';
        result[key] = link;
      }
    }

    // 随机选择一个链接
    if (result.isNotEmpty) {
      final randomLink = (result.values.toList()..shuffle()).first; //生成随机第一位链接
      print(randomLink);
      print('4545');
      print(result);

      // 请求选定的图片链接
      final imageResponse = await http.get(Uri.parse(randomLink));

      if (imageResponse.statusCode == 200) {
        // 确定图片的 MIME 类型（例如 image/jpeg, image/png）
        final contentType =
            imageResponse.headers['content-type'] ?? 'image/jpeg';

        // 返回图片的二进制数据
        return Response.bytes(
          body: imageResponse.bodyBytes,
          headers: {
            'Content-Type': contentType,
          },
        );
      } else {
        return Response.json(
          statusCode: imageResponse.statusCode,
          body: 'Error fetching image: ${imageResponse.reasonPhrase}',
        );
      }
    } else {
      return Response.json(
        statusCode: 404,
        body: 'No image links found.',
      );
    }
  } else {
    return Response.json(
      statusCode: response.statusCode,
      body: 'Error fetching file: ${response.reasonPhrase}',
    );
  }
}
