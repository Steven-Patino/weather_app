import '../models/weather.dart';
import '../repositories/weather_repository.dart';

class GetWeatherByLocationUseCase {
  final WeatherRepository repository;

  GetWeatherByLocationUseCase(this.repository);

  Future<Weather> call(double lat, double lon) {
    return repository.getWeatherByCoordinates(lat, lon);
  }
}
