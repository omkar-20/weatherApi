
import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:weatherapi1/weather_api.dart';

class RemoteService {
  Future<Weather?>fetchData(String city) async {
    try{
      final client = http.Client();
      String url = 'http://api.weatherstack.com/current?access_key=4fc35b0ed5ebd266bbb3e4865398d637&query=$city';
      var response = await client.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        return Weather.fromJson(json);
      }
    }
   catch(e){
      print(e);
   }
    return null;
  }
}