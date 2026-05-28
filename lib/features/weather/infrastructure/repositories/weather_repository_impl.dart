import '../../domain/models/weather.dart';
import '../../domain/repositories/weather_repository.dart';
import '../services/weather_api_service.dart';

class WeatherRepositoryImpl implements WeatherRepository {
  final WeatherApiService apiService;

  WeatherRepositoryImpl(this.apiService);

  Weather _mapJsonToWeather(Map<String, dynamic> data) {
    final timezoneOffsetSeconds = _parseTimezoneOffset(
      data['timezone'] ?? data['utc_offset'],
    );

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
      timezoneOffsetSeconds: timezoneOffsetSeconds,
      sunriseUtcSeconds: _readInt(data['sys'], 'sunrise'),
      sunsetUtcSeconds: _readInt(data['sys'], 'sunset'),
      windDirectionDegrees: _readInt(data['wind'], 'deg'),
    );
  }

  int _readInt(dynamic source, String key) {
    if (source is! Map) {
      return 0;
    }

    final rawValue = source[key];
    if (rawValue is num) {
      return rawValue.toInt();
    }

    return int.tryParse(rawValue?.toString() ?? '') ?? 0;
  }

  int _parseTimezoneOffset(dynamic rawValue) {
    if (rawValue == null) {
      return 0;
    }

    if (rawValue is num) {
      return rawValue.toInt();
    }

    final value = rawValue.toString().trim();
    if (value.isEmpty) {
      return 0;
    }

    final numericValue = int.tryParse(value);
    if (numericValue != null) {
      return numericValue;
    }

    final match = RegExp(r'^([+-])?(\d{1,2})(?::?(\d{2}))?$').firstMatch(value);
    if (match == null) {
      return 0;
    }

    final sign = match.group(1) == '-' ? -1 : 1;
    final hours = int.parse(match.group(2)!);
    final minutes = int.tryParse(match.group(3) ?? '0') ?? 0;
    return sign * ((hours * 3600) + (minutes * 60));
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
