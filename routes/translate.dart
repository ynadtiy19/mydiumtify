import 'dart:convert';

import 'package:beautiful_soup_dart/beautiful_soup.dart';
import 'package:dart_frog/dart_frog.dart';
import 'package:http/http.dart' as http;

Future<Response> onRequest(RequestContext context) async {
  // 获取请求参数
  //translate?id=333dc1eeda1a
  final params = context.request.uri.queryParameters;
  final targetId = params['id'] ?? '333dc1eeda1a';
  final targetLanguage = params['targetLanguage'] ?? 'zh-CN';

  //https://mydiumtify.globeapp.dev/translate?targetLanguage=zh-CN&id=pitaka-magez-slider-2022-review-powerful-nightstand-wireless-charging-station-macsources-abcf152e285f

  // 从指定URL获取HTML字符串
  Future<String> fetchHtml(String url) async {
    try {
      http.Response response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        return response.body;
      } else {
        throw Exception(
            'Failed to load HTML. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
      return '';
    }
  }

// 翻译函数，heroapi-6xl7.onrender.comuuuuu
  Future<String> translateText(String text, String targetLanguage) async {
    const apiUrl =
        'https://heroapi-1.onrender.com/api/translate'; //https://mydiumtify.globeapp.dev/googlemit?text=There%27s%20a%20problem%20with%20that%20%27bullet%20in%20flight%27%20photo%20of%20Trump.%20Reporting%20a%20Problem%20The%20bullet%20seems%20to%20be%20flying%20about%20twice%20as%20fast%20as%20it%20%27should%27%20have%20been.%20What%20if%20there%27s%20a%20mistake?%20Update%201:%20The%20EXIF%20Data%20Update%202:%20A%20note%20on%20the%20angle&to_lang=ru&from_lang=auto
    Map<String, String> queryParams = {
      'text': text,
      'to_lang': targetLanguage,
      'from_lang': 'auto',
    };
    String queryString = Uri(queryParameters: queryParams).query;
    String requestUrl = '$apiUrl?$queryString';

    try {
      http.Response response = await http.get(Uri.parse(requestUrl));
      if (response.statusCode == 200) {
        Map<String, dynamic> data =
            json.decode(response.body) as Map<String, dynamic>;
        if (data['success'] == true) {
          return data['data'] as String? ?? '';
        } else {
          throw Exception('Translation failed: ${data['error_message']}');
        }
      } else {
        throw Exception(
            'Failed to translate text. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
      return '';
    }
  }

  String htmlDocString;

// 检查请求是否包含 targetId 参数
  if (params.containsKey('id') && targetId.isNotEmpty) {
    print('请求中包含有效的 targetId 参数');
    // 从指定URL获取HTML字符串
    String url = 'https://mydiumtify.globeapp.dev/mediumhtml?id=$targetId';
    htmlDocString = await fetchHtml(url);
  } else {
    print('请求中不包含有效的 targetId 参数');
    try {
      final body = await context.request.body();
      final jsonData = jsonDecode(body);

      // 检查 jsonData['html'] 是否为 String 类型且不为空
      if (jsonData['html'] is String &&
          (jsonData['html'] as String).isNotEmpty) {
        htmlDocString = jsonData['html'] as String;
        print('请求体包含 HTML 内容: $htmlDocString');
      } else {
        throw Exception('HTML 内容为空');
      }
    } catch (e) {
      return Response.json(
        body: {'错误': '请求中不包含有效的 targetId 参数或者请求体为空: $e'},
        statusCode: 400,
      );
    }
  }

  // 解析HTML文档
  BeautifulSoup bs = BeautifulSoup(htmlDocString);

  // 目标标签
  List<String> tags = [
    'h1', 'h2', 'h3', // 标题子标题
    'span', 'figcaption', // 其他标签
    // 不包括 'p'，我们将在稍后单独处理
  ];

  // 提取所有目标标签的文本内容
  List<Bs4Element> elements = [];
  List<String> originalTexts = [];

  // 处理非 'p' 标签的内容
  for (String tag in tags) {
    List<Bs4Element> foundTags = bs.findAll(tag);
    elements.addAll(foundTags);
    originalTexts.addAll(foundTags.map((e) => e.string.trim()));
  }

  // 处理 'p' 标签的内容
  List<Bs4Element> pElements = bs.findAll('p');
  elements.addAll(pElements);

// 提取所有 <p> 标签的文本内容，并按换行符拆分
  List<String> pTexts = pElements.map((e) => e.string.trim()).toList();
  String combinedPText = pTexts.join('\n');
  List<String> splitPTexts = combinedPText.split('\n');

  // 删除列表的最后两个元素
  if (splitPTexts.length >= 2) {
    splitPTexts.removeRange(splitPTexts.length - 2, splitPTexts.length);
  }

  // print(splitPTexts);

// 将拆分后的文本内容均匀分为四部分  20000个字符，html本身25300个字符
  int totalLines = splitPTexts.length;
  int baseSize = totalLines ~/ 4; // 每部分的基本行数
  int remainder = totalLines % 4; // 余数行数

  List<List<String>> pChunks = [];
  int start = 0;

  for (int i = 0; i < 4; i++) {
    int chunkSize = baseSize + (remainder > 0 ? 1 : 0); // 分配余数行
    remainder--;
    pChunks.add(splitPTexts.sublist(start, start + chunkSize));
    start += chunkSize;
  }

// 逐块翻译 'p' 标签内容
  List<String> translatedPChunks = [];
  for (List<String> chunk in pChunks) {
    String chunkText = chunk.join('\n');
    String translatedPText = await translateText(chunkText, "$targetLanguage");
    translatedPChunks.addAll(translatedPText
        .split('\n')
        .map((text) => utf8.decode(text.runes.toList())));
  }

// 翻译非 'p' 标签内容
  String combinedText = originalTexts.join('\n');
  String translatedCombinedText =
      await translateText(combinedText, "$targetLanguage");
  List<String> translatedTexts = translatedCombinedText.split('\n');
  List<String> decodedTexts =
      translatedTexts.map((text) => utf8.decode(text.runes.toList())).toList();

  // // 确保翻译后的 p 标签文本数量不超过原始文本数量
  // if (translatedPChunks.length > pElements.length) {
  //   // 如果多余，删除最后两个翻译结果
  //   translatedPChunks = translatedPChunks.sublist(0, pElements.length - 2);
  //   print('1');
  // } else if (translatedPChunks.length < pElements.length) {
  //   // 如果不足，可以考虑补齐，防止索引越界
  //   int difference = pElements.length - translatedPChunks.length;
  //   translatedPChunks
  //       .addAll(List<String>.filled(difference, '', growable: false));
  //   print('2');
  // }

// 更新每个标签的内容
  bool pTagMismatchWarningShown = false;
  bool otherTagMismatchWarningShown = false;

  int pIndex = 0, nonPIndex = 0;
  for (int i = 0; i < elements.length; i++) {
    if (elements[i].name == 'p') {
      if (pIndex < translatedPChunks.length) {
        elements[i].string = translatedPChunks[pIndex];
        pIndex++;
      } else {
        // 处理异常情况，防止索引越界
        if (!pTagMismatchWarningShown) {
          print("警告: p 标签翻译后的文本数量与原始标签数量不匹配。");
          pTagMismatchWarningShown = true;
        }
        break; // 退出循环，停止处理
      }
    } else {
      if (nonPIndex < decodedTexts.length) {
        elements[i].string = decodedTexts[nonPIndex];
        nonPIndex++;
      } else {
        // 处理异常情况，防止索引越界
        if (!otherTagMismatchWarningShown) {
          print("警告: 其他标签翻译后的文本数量与原始标签数量不匹配。");
          otherTagMismatchWarningShown = true;
        }
        break; // 退出循环，停止处理
      }
    }
  }

// 输出更新后的HTML
//   print(bs.toString());

  return Response(
    body: bs.toString(),
    headers: {'Content-Type': 'text/html'},
  );
}
