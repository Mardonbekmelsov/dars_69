import 'dart:convert';

import 'package:http/http.dart' as http;

class QuoteHttpService {
  static Future<Map<String, dynamic>> getQuote() async {
    Uri url = Uri.parse("https://zenquotes.io/api/random");
    final responese = await http.get(url);
    final data =  jsonDecode(responese.body);
    return  {"quote": data[0]['q'], "author": data[0]['a']};
  }
}
