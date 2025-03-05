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
      'csrftoken=834b002741a882bae12da6a4d39f40fa;_pinterest_sess=TWc9PSZHOHlWL3gvUC9MbDF6NUM4KzVTQ2owMGNsMUdTdXJJSWw5Uy9PRDhLdmhGdDMxTC9wRjZKY0M2bWhrc0JGUC94SFNTNVZ6Q3pENUp2aWMzVGZoVVFpYndMaFFKZVQ4MHVSRzI0MmtZd1NqQmdsVUdrSWxjUW90WCs3cUxyT2cyenM2dmdEZnRNMnBPSGVCaHhyNDNIMzBXc2tkdXBhSWozcXRJVlZSaGdVQVRoV05VSXR2ZkZIM09taWFlbGlQZk5VSitoUXNHaHVhZExtNHlJZGc0b2ZFMTdpd21lcXB5RUNJN3dqZkV3VDhWWUNlNjlwbkFnNFBrK0IvTHpLODU4Q21lYStWc2FLaU5walZnbDQ4dHJ2RWZwOGgrekFvZ1JsWGM1YUZwNUowNG5tem81K2R3VW1SRUk1NlY4NlBTRi9CazkvUkp5K25ud1o2RFppalZVOCtPVE03ZitnSFYzbEgrYUZVQXVhY2tRcUl1eXJ2V0dVTHRIQldPUEIzZFRHZHhjNnQ3SHpPTXZIRUpjUktnYy9sUENFZDB6ZUwvM1FwV1lpcUVDOXYrUXk0RzVUMzJ6U2R2TTZNRkNXWExwRUlHM0FmTGJ6eHVLZGRMZVJOZUVGb2IxNzBBMXhRTDBDby9EL2N5NEo0d254U3RPenZOUitvbWwrMElRZkpJZlhPUWR3MnNBNk4ra2VHNTYzMjhhRVhGbkN5VVlHbk1zWGFIZFNVVDJTcW1UWUl2aEdDbDBjNitMMjdRaGgzZkJRd1ZJTUw0aGcwd2t1S2E5K0FHOS9jWkt4VDdXWWwrTzY2M1J4UkU0bkVxbkhwWkRtU1FZdzJrVFZsWVF4RkRyTUhJLzFkQi9mNXVJZHdSZUVxV1hCZGwvTHk0MmNRaE5lQXQ0Ti9TQ2tiQnZuQ0ZEU2dibDRIS3ZaQ1FJOXMvRkZRUEZoUUNXdHdzenVReU5DNjhOamFHcnIwYVR3SUlEUFNicnVpcjRSa09lU3JVMnFjVmhtRHB4aG5zYWhMQW9seExjS1ptMkNIMktJL1o1TjYrM1Z5b1dkSGllb2pIVmxnYUZTcGRsS2VSWUp3UzJaZ3ZXdzBHTVN5R2VJYWQ0WFhSRGtrcXdRQVJhZUU3K3U5bGtxUUlML00xQjVTVzJVaXBJaUpuRHh2UlE2Y2hYYTVIa0xRcTBoMjE1eTZiZ05xL1p5MmVwc0lLY3M2TDRTVTFuRWVXc0thSkRxZ29VR09rQ2Y0WjhySDRaWTcwTVBlazJySXpHaTNDN05mUmpXUmVud1VlR0Y0enh0SHdNTUVlbThvRldIclNIVTRzR1NsNDhVRnUvcGkxQ09Hc0s0ME5JSmU5M0E0MVkvUzd3d2szcXN6V2drQlc3ekxjTUFJU2dmaHVnYllKVElucmdDRFhLNVc1c1FvY3k5Y2t4cjRuUmFiU2R2b1lHeWh5aHFlWUJ2QjFScTJkUDc0SCtkS2NYZTBCRURFaDdQQ3lEeExHaTdNTy9sZE02bUZFU3NFTmlNRUFFR1BuYjUwNlh1dTJDdGxYRDRDMVBRY3hMTUd4VXVRcXpFd0o0ODYvcm9iV1pkY09hNXF0OVVqNnlJcHE4Tko1TW5RUWN2TnRhcytuZmVqYWpMK0FxalBOUGJienhTd2pWRHRMaXJCb0RkbTV1V2pTZjJjWlRTMDFOay9kY0dEdXEwQzNEMXY3aUNFeFRCTzNtR2ZmOWZJV3M0Z0l2M1M3ci8rTVhYWnRZOVlSdm00a05uc3VHZzlBUGdmT3ZQaEpadVU5c0I1NEEmM1lUeDBpYzU1UEEzWkZheGJLdUdEY2NuaGpJPQ==; __Secure-s_a=YTBkcTRxbnFDRTVLV1huYUxGTHBWU1k2dmNkaWVCTS93b3JVazN4ZFhXZ0R2Mmo3RTZIekQyTi9vTFBqdnhsZDd3M2l6WkJRZVk4b0JJUWxYU1pmVkgrd3J6bVp6eURKVjhYMlZrOFRxOHdaUUN2OGZEWTV4cVhPNGttNytHdU04MWxUcmF1WmFySWIzMW90Tk1SZ0F5ckhHOFhOenVGNTZ2SHJ2Q25zaG9uN051a3NiL0pqRzE0dElkcHpsWFJuZWc1YzMrbU1GYkFEc29PbXJpYThmcGVyVnlIc29EWTA0enpRSHlXZUNiWSt2dWdrZ2x2RHIrUnZkaU93VzJHSGRkc2QwT1NqRXVJcktTT296TWhtbFN1c2kxV0xaTW1DZ3orTHJZeS92b2VIRWc2cmIwSWpZT1pFbzVJY2FVMXY4Qk5Sc0d3UmVrd1VPT0lscEFUQ3N0N3l5WHBiNGs4bG9yUytjYkliMS90Y1VkcUgzVlBHelRTMEcrbjl5dzVYUk0wSDl6SHNXYUZpVDV4VDJwODNwQ2hJYThTNU5ab3c2YnVLejNMYmduajF5OUp4c1JLMWkzRGVMVWV2alFSWDAyTVFNaklwWllJTmxOYTZlTDR1Y2hwWk56T2VRRmZ5c2pMTFpVbmtKejdaT1VKZURWQVlBZGJSQmVjK1l1azVGS0wwa3h3eThOZWpVS2wvU29XRWkyWnc1UjRpOG5wMzhlMERtWnhITGk5VUFCU0hEa1lRNXhkRTBFL2ZubnpzeExoajJoSytuZHJ2TGovbEt1WlJDQ3Y4d1R1Q0c4K1YwRVEzUElQUEQ5SjAwM3kvR3ZJVk1EamtmWEpORjdNSUVyckQwYy9idlZOYWt6V0RIR0RvdnJGQUxkdVluODZTODhUV1BVZW1ISEtSMkJzQWgwbE83Y3ZDZ2lmWVdleGhBU09NSG5LYlZjejk4ejVMZU5ENi80Q211cGRGaUs3K0YzNklucUV6ckl5ODR5VVZ4dXVKc3NtNGUvUHBWOTJrTS9PaXYyS21HRDA1U2F4a2VlazJoUlgzMldieURYZ3V2ODRPZk9Jb25XQzUxMVpvZW5qNWxRU1FDb3VRQVIybVlIUHZkYW9iL1ZSTm1yVGdNMkkvekp0bGU5dHIwREwwVCtXbXhaUmt3MzB0OWduY3BNd1B1d2IzZFpHc0swNzhhaWdkTVNGUjduQTNQVGN4dE5zWjMwVm9VaC9sNlk4eGJycXN4U1lvNDcxbFdRRmpqaDE5QlJoeEJrZW5BRTcxUHN0MUNPSkFlZmRJZnlTVEZrVmtxTEwzVTREM1RYUk5xQk56VHAyU1FkUT0mUS9reldRL3MxNE8rQUZ1MitoWFdpY2xPWlBVPQ==; _routing_id="d32250fc-f801-494a-a255-b4391487454a"';
  final String xCrsftoken = '834b002741a882bae12da6a4d39f40fa';

  PinterestScraper(
      {this.query = 'beautiful nature image', this.numberOfImages = 10});

  Future<void> startScraping() async {
    String startUrl =
        'https://www.pinterest.com/resource/BaseSearchResource/get/?source_url=%2Fsearch%2Fpins%2F%3Fq%3D$query&data=%7B%22options%22%3A%7B%22query%22%3A%22$query%22%7D%7D'; 
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
