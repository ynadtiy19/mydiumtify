import 'dart:convert';

import 'package:dart_frog/dart_frog.dart';
import 'package:http/http.dart' as http;
import 'package:json_path/json_path.dart';

Future<Response> onRequest(RequestContext context) async {
  //medium/search?q=apple%20iphone%2013&pageindex=3
  // Access the incoming request.
  final request = context.request;

  // Access the query parameters as a `Map<String, String>`.
  final params = request.uri.queryParameters;

  // Get the value for the key `name`.
  // Default to `there` if there is no query parameter.
  var query = params['q'] ?? 'apple iphone 13';
  var pageindex = params['pageindex'] ?? '3';

  Future<String?> fetchData(String url) async {
    try {
      // 发送 HTTP GET 请求
      var response = await http.get(Uri.parse(url));

      // 检查响应状态码是否为成功(200)
      if (response.statusCode == 200) {
        // 返回 HTML 内容
        return response.body;
      } else {
        // 如果响应状态码不是 200，返回 null
        return null;
      }
    } catch (e) {
      // 如果发生任何错误，返回 null
      return null;
    }
  }

  var jsonresult = await fetchData(
      "https://readmedium.com/api/search-posts?query=$query&pageIndex=$pageindex");

  // 假设 jsonresult 是通过 fetchData 获取的 JSON 响应并已被解析为一个 Map
  var json = jsonDecode(jsonresult!);

  Map<String, Map<String, dynamic>> mediaInfoMap = {};

  // 将 previewInfos 转换为 List
  List<dynamic> previewInfos = json['previewInfos'] as List<dynamic>;

  // 遍历 JSON 数据并创建 MediaInfo 实例
  for (var data in previewInfos) {
    final uniqueSlug = JsonPath(r'$.uniqueSlug').readValues(data).toString();
    final title = JsonPath(r'$.title').readValues(data).toString();
    final subtitle = JsonPath(r'$.subtitle').readValues(data).toString();
    final name = JsonPath(r'$.authorInfo.name').readValues(data).toString();

    // 获取并修改 avatarUrl
    String avatarUrl =
        JsonPath(r'$.authorInfo.avatarUrl').readValues(data).toString();
    avatarUrl = avatarUrl
        .replaceFirst('miro.medium.com', 'cdn-images-1.readmedium.com')
        .replaceFirst(
          'v2/resize:fill:88:88',
          'v2/resize:fill:2048:1152',
        ); // 2K 分辨率

// 如果需要 4K 分辨率，可以使用如下替换方式
// .replaceFirst('v2', 'v2/resize:fill:3840:2160'); // 4K 分辨率

// 获取并修改 postImg
    String postImg = JsonPath(r'$.postImg').readValues(data).toString();
    postImg = postImg
        .replaceFirst('miro.medium.com', 'cdn-images-1.readmedium.com')
        .replaceFirst('v2/resize:fit:224', 'v2/resize:fit:2048'); // 2K 分辨率

// 如果需要 4K 分辨率，可以使用如下替换方式
// .replaceFirst('v2', 'v2/resize:fit:3840'); // 4K 分辨率

    final readingTime = JsonPath(r'$.readingTime').readValues(data).toString();
    final createdAt = JsonPath(r'$.createdAt').readValues(data).toString();
    final isEligibleForRevenueString =
        JsonPath(r'$.isEligibleForRevenue').readValues(data).toString();

    //JsonPath(r'$.isEligibleForRevenue').readValues(data).first.value.toString();

// 将字符串转换为布尔值
    final isEligibleForRevenue =
        isEligibleForRevenueString.toLowerCase() == 'true';

    // 创建 MediaInfo 实例
    MediaInfo mediaInfo = MediaInfo(
      uniqueSlug: uniqueSlug,
      title: title,
      subtitle: subtitle,
      name: name,
      avatarUrl: avatarUrl, // 使用修改后的 avatarUrl
      postImg: postImg, // 使用修改后的 postImg
      readingTime: readingTime,
      createdAt: createdAt,
      isEligibleForRevenue: isEligibleForRevenue,
    );

    // 将 MediaInfo 实例添加到 Map 中
    mediaInfoMap[uniqueSlug] = mediaInfo.toJson();
  }

  // 返回 JSON 响应
  return Response.json(body: mediaInfoMap);
}

class MediaInfo {
  final String uniqueSlug;
  final String title;
  final String subtitle;
  final String name;
  final String avatarUrl;
  final String postImg;
  final String readingTime;
  final String createdAt;
  final bool isEligibleForRevenue;

  MediaInfo({
    required this.uniqueSlug,
    required this.title,
    required this.subtitle,
    required this.name,
    required this.avatarUrl,
    required this.postImg,
    required this.readingTime,
    required this.createdAt,
    required this.isEligibleForRevenue,
  });

  // 将 MediaInfo 转换为 Map
  Map<String, dynamic> toJson() {
    return {
      'uniqueSlug': uniqueSlug,
      'title': title,
      'subtitle': subtitle,
      'name': name,
      'avatarUrl': avatarUrl,
      'postImg': postImg,
      'readingTime': readingTime,
      'createdAt': createdAt,
      'isEligibleForRevenue': isEligibleForRevenue,
    };
  }
}
