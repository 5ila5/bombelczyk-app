import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;

class WebComunicater {
  static final String _ipToAsk = 'bombelczyk-aufzuege.de';
  static final gzip = GZipCodec();

  static Future<String> sendRequest(Map<String, String> body,
      {bool login = false}) async {
    print(base64.encode(gzip.encode(utf8.encode(jsonEncode(body)))));
    http.Response response = await http.post(
      Uri.https(_ipToAsk,
          'UpP0UH3nFKMsnJk2/' + ((login) ? 'login.php' : 'index.php')),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        "Content-Encoding": "gzip",
      },
      body: gzip.encode(utf8.encode(jsonEncode(body))), //.codeUnits),
    );
    return response.body;
  }
}
