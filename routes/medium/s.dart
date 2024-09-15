import 'package:dart_frog/dart_frog.dart';
import 'package:http/http.dart' as http;

Future<Response> onRequest(RequestContext context) async {
  //medium/s?q=apple%20iphone%2013
  final request = context.request;

  // Access the query parameters as a `Map<String, String>`.
  final params = request.uri.queryParameters;

  // Get the value for the key `name`.
  // Default to `there` if there is no query parameter.
  var query = params['q'] ?? 'apple iphone 13';

  final String apiUrl =
      'https://mydiumtify.globeapp.dev/chattext?q=${Uri.encodeComponent(query)}';
  print(apiUrl);

  final response = await http.get(Uri.parse(apiUrl));
  return Response(body: '$response');
}
