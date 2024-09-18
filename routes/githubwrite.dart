// import 'dart:convert';
//
// import 'package:http/http.dart' as http;
//
// Future<void> onRequest(RequestContext context) {
//   const url =
//       'https://api.github.com/repos/ynadtiy19/youtubewords/contents/uu1';
//   const token =
//       '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'; // 用您的 GitHub 令牌替换此处
//
//   // 第一步：获取当前文件信息
//   final getResponse = await http.get(
//     Uri.parse(url),
//     headers: {
//       'Authorization': 'token $token',
//       'Accept': 'application/vnd.github.v3.raw',
//     },
//   );
//
//   if (getResponse.statusCode == 200) {
//     final data = jsonDecode(getResponse.body);
//     final String sha = data['sha']; // 获取现有文件的 SHA
//     final String filePath = data['path']; // 获取文件的路径
//
//     // 第二步：准备新的文件内容
//     const newContent = '这是更新后的文件内容。';
//
//     // 第三步：发送 PUT 请求更新文件
//     final updateResponse = await http.put(
//       Uri.parse(url),
//       headers: {
//         'Authorization': 'token $token',
//         'Content-Type': 'application/json',
//       },
//       body: jsonEncode({
//         'message': '更新文件内容', // 提交信息
//         'content':
//             base64Encode(utf8.encode(newContent)), // 文件的新内容（需要 Base64 编码）
//         'sha': sha, // 原始文件的 SHA 值
//       }),
//     );
//
//     if (updateResponse.statusCode == 200) {
//       print('文件更新成功！');
//     } else {
//       print('更新文件失败: ${updateResponse.reasonPhrase}');
//     }
//   } else {
//     print('获取文件信息失败: ${getResponse.reasonPhrase}');
//   }
// }
