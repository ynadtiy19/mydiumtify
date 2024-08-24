import 'dart:convert';

import 'package:dart_frog/dart_frog.dart';
import 'package:html/dom.dart';
import 'package:html/parser.dart' show parse;
import 'package:http/http.dart' as http;

Future<Response> onRequest(RequestContext context) async {
  // 获取请求参数
  //translate?id=333dc1eeda1a
  final params = context.request.uri.queryParameters;
  final id = params['id'] ?? '333dc1eeda1a';

  // 获取HTML内容
  final url = 'https://mydiumtify.globeapp.dev/mediumhtml?id=$id';
  final htmlResponse = await http.get(Uri.parse(url));
  if (htmlResponse.statusCode != 200) {
    return Response(statusCode: 500, body: 'Failed to load HTML content');
  }

  // 解析HTML内容
  final document = parse(htmlResponse.body);

  // 要翻译的标签
  final tags = [
    'h1',
    'h2',
    'h3',
    'p',
    'ol',
    'ul',
    'li',
    'title',
    'span',
    'button',
    'body',
    'a',
    'div',
    'main',
    'footer',
    'form',
    'strong',
    'em',
    'small',
    'dl',
    'dt',
    'dd',
    'figure',
    'figcaption',
    'input',
    'i'
  ];

  // 多语言翻译
  final translatedDocuments =
      await _translateDocument(document, tags, 'zh-CN'); // 中文

  // 返回JSON格式的多语言HTML
  // 返回翻译后的HTML内容
  return Response(
    body: translatedDocuments.outerHtml,
    headers: {'Content-Type': 'text/html'},
  );
  // return Response.json(
  //   body: {
  //     'de': translatedDocuments[0].outerHtml,
  //     'it': translatedDocuments[1].outerHtml,
  //     'en': translatedDocuments[2].outerHtml,
  //     'zh-CN': translatedDocuments[3].outerHtml,
  //   },
  // );
}

// 翻译HTML文档内容
Future<Document> _translateDocument(
    Document document, List<String> tags, String targetLang) async {
  final translations = await Future.wait(document
      .getElementsByTagName('*')
      .where((element) =>
          tags.contains(element.localName) && element.text.trim().isNotEmpty)
      .map((element) => _translateText(element.text, targetLang)));

  int i = 0;
  for (var element in document.getElementsByTagName('*')) {
    if (tags.contains(element.localName) && element.text.trim().isNotEmpty) {
      element.text = translations[i++];
    }
  }

  return document;
}

// 使用Google Translate API进行翻译
Future<String> _translateText(String text, String targetLang) async {
  final url = Uri.parse('https://translate.googleapis.com/translate_a/single?'
      'client=gtx&sl=auto&tl=$targetLang&dt=t&q=${Uri.encodeComponent(text)}');

  final response = await http.get(url);
  if (response.statusCode == 200) {
    final jsonResponse = json.decode(response.body);
    final translatedText = jsonResponse[0][0][0].toString(); // 确保转换为String类型
    return translatedText;
  } else {
    print('Failed to translate text: $text');
    return text; // 返回原始文本以防翻译失败
  }
}
