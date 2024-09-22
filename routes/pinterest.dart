import 'dart:convert';

import 'package:dart_frog/dart_frog.dart';
import 'package:http/http.dart' as http;

Future<Response> onRequest(RequestContext context) async {
  // https://mydiumtify.globeapp.dev/pinterest?query=&numberOfImages=5
  final queryParams = context.request.uri.queryParameters;
  final query = queryParams['query'] ?? 'beautiful nature image';
  final numberOfImages =
      int.tryParse(queryParams['numberOfImages'] ?? '10') ?? 10;

  // 创建 PinterestScraper 实例并开始抓取
  PinterestScraper scraper =
      PinterestScraper(query: query, numberOfImages: numberOfImages);
  await scraper.startScraping();

  // 返回结果作为响应
  return Response.json(body: scraper.collectionItems);
}

class PinterestScraper {
  final String query;
  final int numberOfImages;
  final List<Map<String, dynamic>> collectionItems = [];

  final String cookie =
      'csrftoken=97b01583d6330b33b7e72656a4d5ed1c; _pinterest_sess=TWc9PSZSNnhlV2xkTWpGTFltVVEvQkRBbmxDWlRPcEx6MEhSdGRYR3g0ZmJaWUk5WVVXakQwS29Ia0F1RGZiYlpSdXByTy9mckF5dDRzTG9sU2FYV3ZlbXZNUFpDOFpqYVB1c1FYV2oxWk15MEQyTT0meU1oTWZRSGR5Q1Z6Zjd5bXc0a0gvejFPR1R3PQ==; _auth=0; _routing_id="b5a67db2-93e5-4513-ab31-05ca021c6667"; sessionFunnelEventLogged=1';
  final String xCrsftoken = '97b01583d6330b33b7e72656a4d5ed1c';

  PinterestScraper(
      {this.query = 'beautiful nature image', this.numberOfImages = 10});

  Future<void> startScraping() async {
    String startUrl =
        'https://in.pinterest.com/resource/BaseSearchResource/get/?source_url=%2Fsearch%2Fpins%2F%3Fq%3D$query&data=%7B%22options%22%3A%7B%22query%22%3A%22$query%22%7D%7D';

    var response = await http.get(Uri.parse(startUrl));
    if (response.statusCode == 200) {
      var jsonResponse = jsonDecode(response.body);

      // 强制将 jsonResponse['resource_response']['data']['results'] 转换为 List<dynamic>
      List<dynamic> results =
          jsonResponse['resource_response']['data']['results'] as List<dynamic>;

      // 遍历 List<dynamic> 结果
      for (var result in results) {
        // 确保 result['images'] 存在并且不为 null
        if (result['images'] != null) {
          collectionItems.add({
            "title": result['title'],
            "image": result['images']['orig'],
            "pinner": result['pinner'],
            "board": result['board'],
          });
        }
      }

      await crawlMoreImages(); // 如果需要抓取更多图像
    } else {
      print('Failed to load initial results');
    }
  }

  Future<void> crawlMoreImages() async {
    while (collectionItems.length < numberOfImages) {
      String url =
          'https://www.pinterest.com.au/resource/BaseSearchResource/get/';
      Map<String, dynamic> payload = {
        "source_url":
            '/search/pins/?q=$query&rs=typed&term_meta[]=$query%7Ctyped',
        "data": {
          "options": {'query': query},
          "context": {}
        }
      };

      var headers = {
        'cookie': cookie,
        'x-csrftoken': xCrsftoken,
        'Content-Type': 'application/json',
      };

      var response = await http.post(Uri.parse(url),
          headers: headers, body: jsonEncode(payload));

      if (response.statusCode == 200) {
        var jsonResponse = jsonDecode(response.body);

        // 强制将 jsonResponse['resource_response']['data']['results'] 转换为 List<dynamic>
        List<dynamic> moreResults = jsonResponse['resource_response']['data']
            ['results'] as List<dynamic>;

        // 遍历 List<dynamic> 结果
        for (var result in moreResults) {
          // 确保 result['images'] 存在并且不为 null
          if (result['images'] != null) {
            collectionItems.add({
              "title": result['title'],
              "image": result['images']['orig'],
              "pinner": result['pinner'],
              "board": result['board'],
            });
          }
        }
      } else {
        print('Failed to load more results');
        break;
      }
    }
  }

  void printResults() {
    for (var item in collectionItems) {
      print('Title: ${item["title"]}, Image: ${item["image"]}');
    }
  }
}
