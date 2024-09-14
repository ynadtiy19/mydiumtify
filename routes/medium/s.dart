import 'package:dart_frog/dart_frog.dart';

Response onRequest(RequestContext context) {
  //medium/s?q=apple%20iphone%2013
  final request = context.request;

  // Access the query parameters as a `Map<String, String>`.
  final params = request.uri.queryParameters;

  // Get the value for the key `name`.
  // Default to `there` if there is no query parameter.
  var query = params['q'] ?? 'apple iphone 13';
  return Response(body: 'This is a new route!');
}
