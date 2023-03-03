import 'package:flutter/cupertino.dart';
import 'package:weatherapi1/remote_services.dart';
import 'package:weatherapi1/weather_api.dart';

class WeatherProvider extends ChangeNotifier {
  WeatherModel wm = WeatherModel();
  final _service = RemoteService();
  bool isLoading = false;

  WeatherModel get getData => wm;

  Future<void> getCurrent(String city) async {
    isLoading = true;
    notifyListeners();
    final Weather response = (await _service.fetchData(city)) as Weather;
    //print(response);
    wm = WeatherModel(stutus: "ok", weather: response);
    // print(wm.weather);
    isLoading = false;
    notifyListeners();
  }
}
