import '../models/weather.dart';

abstract class WeatherRepository {
  Future<Weather> getWeatherByCity(String city);
  Future<Weather> getWeatherByCoordinates(double lat, double lon);
}
