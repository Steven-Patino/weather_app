import '../domain/usecases/get_weather_by_location_usecase.dart';
import '../domain/usecases/get_weather_usecase.dart';
import '../infrastructure/repositories/weather_repository_impl.dart';
import '../infrastructure/services/location_service.dart';
import '../infrastructure/services/weather_api_service.dart';
import 'providers/weather_provider.dart';

class WeatherAppBootstrap {
  static WeatherProvider createProvider() {
    final apiService = WeatherApiService();
    final repository = WeatherRepositoryImpl(apiService);
    return WeatherProvider(
      getWeatherUseCase: GetWeatherUseCase(repository),
      getWeatherByLocationUseCase: GetWeatherByLocationUseCase(repository),
      locationService: LocationService(),
    );
  }
}
