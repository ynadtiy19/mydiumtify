import 'dart:convert';
import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';

Future<Response> onRequest(RequestContext context) async {
  //https://mydiumtify.globeapp.dev/ipfs?index=20
  try {
    // 获取请求参数
    final queryParams = context.request.uri.queryParameters;
    final index = int.tryParse(queryParams['index'] ?? '100') ?? 100;

    final mediaInfoMap = await profileImageFetch(index);

    return Response.json(body: mediaInfoMap);
  } catch (e) {
    return Response.json(
        statusCode: 500,
        body: {'error': 'Internal Server Error', 'message': e.toString()});
  }
}

Future<Map<String, Map<String, dynamic>>> profileImageFetch(
    [int index = 100]) async {
  print('开始请求图片来源于https://indexer.clickapp.com/');
  try {
    final ioClient = IOClient(HttpClient()
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true); // 忽略证书错误
    final url = Uri.parse('https://indexer.clickapp.com/');
    final headers = {
      'accept': '*/*',
      'accept-encoding': 'gzip, deflate, br, zstd',
      'accept-language': 'zh-CN,zh;q=0.9',
      'cache-control': 'no-cache',
      'content-type': 'application/json',
      'origin': 'https://clickapp.com',
      'pragma': 'no-cache',
      'priority': 'u=1, i',
      'referer': 'https://clickapp.com/',
      'sec-ch-ua':
          '"Chromium";v="134", "Not:A-Brand";v="24", "Microsoft Edge";v="134"',
      'sec-ch-ua-mobile': '?0',
      'sec-ch-ua-platform': '"Windows"',
      'sec-fetch-dest': 'empty',
      'sec-fetch-mode': 'cors',
      'sec-fetch-site': 'same-site',
      'user-agent':
          'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/134.0.0.0 Safari/537.36'
    };

    final payload = {
      'operationName': 'nftsByOwner',
      'variables': {
        'account': '0x5C4cF941cA63bA5e20493A78B54c4DACE099426b',
        'contentType': '',
        'limit': index,
      },
      'query': '''
      query nftsByOwner(\$account: String!, \$limit: Int, \$contentType: String) {
        eRC721Tokens(
          filter: {ownerId: {equalToInsensitive: \$account}, contentType: {includes: \$contentType}}
          first: \$limit
          orderBy: TIMESTAMP_DESC
        ) {
          nodes {
            id
            identifier
            uri
            timestamp
            ownerId
            owner {
              name
              __typename
            }
            channel
            content
            transactionHash
            contentType
            thumbnail
            __typename
          }
          pageInfo {
            hasNextPage
            endCursor
            __typename
          }
          __typename
        }
      }
      '''
    };

    final response = await ioClient.post(
      url,
      headers: headers,
      body: jsonEncode(payload),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final nfts = data['data']['eRC721Tokens']['nodes'] as List;

      final transformedData = nfts.map((nft) {
        final uriValue = (nft['uri'] as String).split('ipfs://').last;
        final contentValue = (nft['content'] as String).split('ipfs://').last;

        return {
          'uri':
              'https://mydiumtify.globeapp.dev/myfilebase?url=https://nodle-community-nfts.myfilebase.com/ipfs/$uriValue',
          'content':
              'https://mydiumtify.globeapp.dev/pinterestImage?isImage=true&url=https://nodle-community-nfts.myfilebase.com/ipfs/$contentValue',
        };
      }).toList();

      final futures = transformedData.map((item) async {
        try {
          final response = await http.get(Uri.parse(item['uri']!));
          if (response.statusCode == 200) {
            final responseData = jsonDecode(response.body);
            return responseData;
          } else {
            return null;
          }
        } catch (e) {
          return null;
        }
      });

      final responses = await Future.wait(futures);

      final mediaInfoMap = <String, Map<String, dynamic>>{};
      for (var i = 0; i < transformedData.length; i++) {
        final contentUrl = transformedData[i]['content'];
        final responseData = responses[i];
        if (contentUrl != null && responseData != null) {
          mediaInfoMap[contentUrl] = {
            'placeName': responseData['placeName'] ?? '未知地点',
            'name': responseData['name'] ?? '未知名称',
          };
        }
      }
      return mediaInfoMap;
    } else {
      throw Exception('请求失败，状态码：${response.statusCode}');
    }
  } catch (e) {
    throw Exception('获取内容失败: $e');
  }
}
