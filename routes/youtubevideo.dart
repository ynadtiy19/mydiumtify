import 'package:dart_frog/dart_frog.dart';
import 'package:http/http.dart' as http;

Future<Response> onRequest(RequestContext context) async {
  const url =
      'https://api.github.com/repos/ynadtiy19/youtubewords/contents/README.md';

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

    // 分割内容（假设每行是一个链接）
    final lines = content.split('\n');

    // 创建一个 Map 来存储有效的键值对
    final result = <String, String>{};

    // 遍历每一行，并为每个链接生成键值对
    for (int i = 0; i < lines.length; i++) {
      final link = lines[i].trim(); // 去掉前后的空格
      if (link.isNotEmpty) {
        // 只处理非空链接
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

// {
// "uu1": "https://github.com/user-attachments/assets/f76ccb0b-2697-4e5a-bb46-3847319a3391",
// "uu2": "https://github.com/user-attachments/assets/5e808163-a345-4d75-a104-d4de05a49312",
// "uu3": "https://github.com/user-attachments/assets/e9d895b1-ce6d-44fe-bc03-a181a3dac409",
// "uu4": "https://github.com/user-attachments/assets/277b8a65-c9ec-45f4-86e9-8c8d6a400d68",
// "uu5": "https://github.com/user-attachments/assets/3e20987d-526d-4bae-a29b-4d37a1b61317",
// "uu6": "https://github.com/user-attachments/assets/1abc80bb-f0fb-4bbf-bc2e-07ee720f7652",
// "uu7": "https://github.com/user-attachments/assets/c44d83d5-7dfa-4427-a1d0-6a245dee3240",
// "uu8": "https://github.com/user-attachments/assets/e0492880-7909-4953-ac2b-d3ac1fd576d4",
// "uu9": "https://github.com/user-attachments/assets/57e7b6cb-011a-46a8-8c7a-c205a41611be",
// "uu10": "https://github.com/user-attachments/assets/9c826bb4-9ca3-496a-bac9-fc89f29e6e9d",
// "uu11": "https://github.com/user-attachments/assets/762f6f6f-3bd5-49d1-bf70-990438bf5878",
// "uu12": "https://github.com/user-attachments/assets/c021c8e0-c79a-4368-8827-95fd5c9a4f38",
// "uu13": "https://github.com/user-attachments/assets/e0a1ddda-9445-45c5-b987-d15f40ef772a"
// }
