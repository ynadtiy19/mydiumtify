import 'dart:convert';

import 'package:dart_frog/dart_frog.dart';
import 'package:http/http.dart' as http;
import 'package:json_path/json_path.dart';

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

  Map<String, dynamic> toJson() => {
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

Future<Response> onRequest(RequestContext context) async {
  //medium/search?q=apple%20iphone%2013&pageindex=1
  final request = context.request;
  final params = request.uri.queryParameters;
  var query = params['q'] ?? 'apple iphone 13';
  var pageindex = int.parse(params['pageindex'] ?? '1');

  Future<String?> fetchData(String url) async {
    try {
      var response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        return response.body;
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  Map<String, Map<String, dynamic>> mediaInfoMap = {};
  const int targetCount = 10;

  while (mediaInfoMap.length < targetCount) {
    var jsonresult = await fetchData(
        "https://readmedium.com/api/search-posts?query=$query&pageIndex=$pageindex");

    if (jsonresult == null) {
      break;
    }

    var json = jsonDecode(jsonresult);
    List<dynamic> previewInfos = json['previewInfos'] as List<dynamic>;

    for (var data in previewInfos) {
      String postImg = JsonPath(r'$.postImg').read(data).first.value.toString();
      postImg = postImg.replaceFirst(
          'miro.medium.com', 'cdn-images-1.readmedium.com');

      // 如果 postImg 是完整的 URL 才继续处理
      if (postImg.startsWith('https://cdn-images-1.readmedium.com')) {
        final uniqueSlug =
            JsonPath(r'$.uniqueSlug').read(data).first.value.toString();
        final title = JsonPath(r'$.title').read(data).first.value.toString();
        final subtitle =
            JsonPath(r'$.subtitle').read(data).first.value.toString();
        final name =
            JsonPath(r'$.authorInfo.name').read(data).first.value.toString();

        String avatarUrl = JsonPath(r'$.authorInfo.avatarUrl')
            .read(data)
            .first
            .value
            .toString();
        avatarUrl = avatarUrl.replaceFirst(
            'miro.medium.com', 'cdn-images-1.readmedium.com');

        final readingTime =
            JsonPath(r'$.readingTime').read(data).first.value.toString();
        final createdAt =
            JsonPath(r'$.createdAt').read(data).first.value.toString();
        final isEligibleForRevenueString = JsonPath(r'$.isEligibleForRevenue')
            .read(data)
            .first
            .value
            .toString();
        final isEligibleForRevenue =
            isEligibleForRevenueString.toLowerCase() == 'true';

        MediaInfo mediaInfo = MediaInfo(
          uniqueSlug: uniqueSlug,
          title: title,
          subtitle: subtitle,
          name: name,
          avatarUrl: avatarUrl,
          postImg: postImg,
          readingTime: readingTime,
          createdAt: createdAt,
          isEligibleForRevenue: isEligibleForRevenue,
        );

        mediaInfoMap[uniqueSlug] = mediaInfo.toJson();

        if (mediaInfoMap.length == targetCount) {
          break;
        }
      }
    }

    pageindex++;
  }

  return Response.json(body: mediaInfoMap);
}
