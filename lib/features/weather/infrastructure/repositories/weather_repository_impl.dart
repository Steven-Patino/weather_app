import '../../domain/models/weather.dart';
import '../../domain/repositories/weather_repository.dart';
import '../services/weather_api_service.dart';

class WeatherRepositoryImpl implements WeatherRepository {
  final WeatherApiService apiService;

  WeatherRepositoryImpl(this.apiService);

  Weather _mapJsonToWeather(Map<String, dynamic> data) {
    return Weather(
      cityName: data['name'],
      temperature: (data['main']['temp'] as num).toDouble(),
      description: data['weather'][0]['description'],
      iconCode: data['weather'][0]['icon'],
      humidity: (data['main']['humidity'] as num).toInt(),
      feelsLike: (data['main']['feels_like'] as num).toDouble(),
      windSpeed: (data['wind']['speed'] as num).toDouble(),
      pressure: (data['main']['pressure'] as num).toInt(),
      visibility: (data['visibility'] as num).toInt(),
      uvIndex: (data['uvi'] as num?)?.toDouble() ?? 0.0,
    );
  }

  @override
  Future<Weather> getWeatherByCity(String city) async {
    try {
      final data = await apiService.fetchWeather(city);
      return _mapJsonToWeather(data);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<Weather> getWeatherByCoordinates(double lat, double lon) async {
    try {
      final data = await apiService.fetchWeatherByLocation(lat, lon);
      return _mapJsonToWeather(data);
    } catch (e) {
      rethrow;
    }
  }
}
