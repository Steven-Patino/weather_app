import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class WeatherApiService {
  final String _apiKey = dotenv.env['OPENWEATHER_API_KEY'] ?? '';
  final String _baseUrl = 'https://api.openweathermap.org/data/2.5/weather';
  final Dio _dio = Dio();

  Future<Map<String, dynamic>> fetchWeather(String city) async {
    try {
      final response = await _dio.get(
        _baseUrl,
        queryParameters: {
          'q': city,
          'appid': _apiKey,
          'units': 'metric',
        },
      );

      final data = response.data as Map<String, dynamic>;
      final lat = data['coord']['lat'];
      final lon = data['coord']['lon'];

      final uviResponse = await _dio.get(
        'https://api.openweathermap.org/data/2.5/uvi',
        queryParameters: {'lat': lat, 'lon': lon, 'appid': _apiKey},
      );
      data['uvi'] = uviResponse.data['value'];

      return data;
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Exception('Ciudad no encontrada');
      } else {
        throw Exception('Error al conectar con la API (Código: ${e.response?.statusCode ?? 'Desconocido'})');
      }
    }
  }

  Future<Map<String, dynamic>> fetchWeatherByLocation(double lat, double lon) async {
    try {
      final weatherResponse = await _dio.get(
        _baseUrl,
        queryParameters: {
          'lat': lat,
          'lon': lon,
          'appid': _apiKey,
          'units': 'metric',
        },
      );

      final uviResponse = await _dio.get(
        'https://api.openweathermap.org/data/2.5/uvi',
        queryParameters: {
          'lat': lat,
          'lon': lon,
          'appid': _apiKey,
        },
      );

      final data = weatherResponse.data as Map<String, dynamic>;
      data['uvi'] = uviResponse.data['value'];

      return data;
    } on DioException catch (e) {
      throw Exception('Error al conectar con la API (Código: ${e.response?.statusCode ?? 'Desconocido'})');
    }
  }
}
