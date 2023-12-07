import 'package:epub_kitty_example/app/data/models/http/http_client.dart';
import 'package:http/http.dart' as http;

class HttpClient implements IHttpClient {
  final _client = http.Client();

  @override
  Future get({required String url}) async {
    return await _client.get(Uri.parse(url));
  }
}
