import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/apod_model.dart';

class NasaApi {
  static const String _apiKey = 'h0VeaWh0NB5OTu6si78IbbfNrK0cIq7cUHfs7J8H';
  static const String _baseUrl = 'https://api.nasa.gov/planetary/apod';

  static Future<List<APOD>> fetchMultipleAPODs({int count = 10}) async {
    final response = await http.get(
      Uri.parse('$_baseUrl?api_key=$_apiKey&count=$count'),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => APOD.fromJson(json)).toList();
    }
    throw Exception('Error ${response.statusCode}');
  }
}
