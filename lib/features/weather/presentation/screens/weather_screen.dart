import 'package:flutter/material.dart';
import '../../domain/models/weather.dart';
import '../../domain/usecases/get_weather_usecase.dart';
import '../../domain/usecases/get_weather_by_location_usecase.dart';
import '../../infrastructure/repositories/weather_repository_impl.dart';
import '../../infrastructure/services/weather_api_service.dart';
import '../../infrastructure/services/location_service.dart';
import '../widgets/weather_search_bar.dart';
import '../widgets/weather_detail_item.dart';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  late final GetWeatherUseCase _getWeatherUseCase;
  late final GetWeatherByLocationUseCase _getWeatherByLocationUseCase;
  late final LocationService _locationService;
  
  Future<Weather>? _weatherFuture;
  final TextEditingController _cityController = TextEditingController();

  // Ruta del GIF local de fondo
  String _bgGifPath = 'lib/features/weather/presentation/backgrounds/clear_sky_day.gif';

  @override
  void initState() {
    super.initState();
    final apiService = WeatherApiService();
    final repository = WeatherRepositoryImpl(apiService);
    _getWeatherUseCase = GetWeatherUseCase(repository);
    _getWeatherByLocationUseCase = GetWeatherByLocationUseCase(repository);
    _locationService = LocationService();

    _loadWeatherByLocation();
  }

  void _loadWeatherByLocation() {
    setState(() {
      _weatherFuture = _fetchLocalWeather();
    });
  }

  Future<Weather> _fetchLocalWeather() async {
    final position = await _locationService.getCurrentPosition();
    final weather = await _getWeatherByLocationUseCase(position.latitude, position.longitude);
    _updateBackground(weather.iconCode);
    return weather;
  }

  void _searchWeather() {
    final city = _cityController.text.trim();
    if (city.isNotEmpty) {
      setState(() {
        _weatherFuture = _getWeatherUseCase(city).then((weather) {
          _updateBackground(weather.iconCode);
          return weather;
        });
      });
    }
  }

  String _getWeatherConditionName(String iconCode) {
    final code = iconCode.substring(0, 2);
    switch (code) {
      case '01': return 'clear_sky';
      case '02': return 'few_clouds';
      case '03': return 'scattered_clouds';
      case '04': return 'broken_clouds';
      case '09': return 'shower_rain';
      case '10': return 'rain';
      case '11': return 'thunderstorm';
      case '13': return 'snow';
      case '50': return 'mist';
      default: return 'clear_sky';
    }
  }

  String _getTimeOfDay() {
    final hour = DateTime.now().hour;
    if (hour >= 6 && hour < 12) {
      return 'day';
    } else if (hour >= 12 && hour < 18) {
      return 'afternoon';
    } else {
      return 'evening';
    }
  }

  void _updateBackground(String iconCode) {
    final condition = _getWeatherConditionName(iconCode);
    final timeOfDay = _getTimeOfDay();
    
    setState(() {
      _bgGifPath = 'lib/features/weather/presentation/backgrounds/${condition}_$timeOfDay.gif';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Clima App', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Capa de fondo con GIF, forzada a llenar el espacio
          Positioned.fill(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 800),
              child: SizedBox.expand(
                key: ValueKey(_bgGifPath),
                child: Image.asset(
                  _bgGifPath,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                ),
              ),
            ),
          ),
          // Capa oscura semi-transparente para dar legibilidad al texto
          Container(
            color: Colors.black.withOpacity(0.4),
          ),
          // Contenido Principal
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  WeatherSearchBar(
                    controller: _cityController,
                    onSearch: _searchWeather,
                    onLocationRequested: _loadWeatherByLocation,
                  ),
                  const SizedBox(height: 24),
                  Expanded(
                    child: _weatherFuture == null
                        ? const Center(child: Text('Cargando...', style: TextStyle(color: Colors.white)))
                        : FutureBuilder<Weather>(
                            future: _weatherFuture,
                            builder: (context, snapshot) {
                              if (snapshot.connectionState == ConnectionState.waiting) {
                                return const Center(child: CircularProgressIndicator(color: Colors.white));
                              } else if (snapshot.hasError) {
                                return Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(Icons.error_outline, color: Colors.redAccent, size: 48),
                                      const SizedBox(height: 16),
                                      Text(
                                        'Error:\n${snapshot.error}',
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(color: Colors.white),
                                      ),
                                      const SizedBox(height: 16),
                                      ElevatedButton(
                                        onPressed: _loadWeatherByLocation,
                                        child: const Text('Reintentar ubicación'),
                                      ),
                                    ],
                                  ),
                                );
                              } else if (snapshot.hasData) {
                                final weather = snapshot.data!;
                                return SingleChildScrollView(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        weather.cityName,
                                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      if (weather.iconCode.isNotEmpty)
                                        Image.network(
                                          'https://openweathermap.org/img/wn/${weather.iconCode}@4x.png',
                                          height: 120,
                                          errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                                        ),
                                      Text(
                                        '${weather.temperature.toStringAsFixed(1)}°C',
                                        style: Theme.of(context).textTheme.displayLarge?.copyWith(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        weather.description.toUpperCase(),
                                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                          color: Colors.white70,
                                        ),
                                      ),
                                      const SizedBox(height: 48),
                                      // Grid de 6 detalles
                                      Wrap(
                                        spacing: 24,
                                        runSpacing: 24,
                                        alignment: WrapAlignment.center,
                                        children: [
                                          WeatherDetailItem(icon: Icons.water_drop, value: '${weather.humidity}%', label: 'Humedad'),
                                          WeatherDetailItem(icon: Icons.thermostat, value: '${weather.feelsLike.toStringAsFixed(1)}°C', label: 'Sensación'),
                                          WeatherDetailItem(icon: Icons.air, value: '${weather.windSpeed.toStringAsFixed(1)} m/s', label: 'Viento'),
                                          WeatherDetailItem(icon: Icons.compress, value: '${weather.pressure} hPa', label: 'Presión'),
                                          WeatherDetailItem(icon: Icons.visibility, value: '${(weather.visibility / 1000).toStringAsFixed(1)} km', label: 'Visibilidad'),
                                          WeatherDetailItem(icon: Icons.wb_sunny, value: weather.uvIndex.toStringAsFixed(1), label: 'Índice UV'),
                                        ],
                                      ),
                                      const SizedBox(height: 24),
                                    ],
                                  ),
                                );
                              }
                              return const SizedBox.shrink();
                            },
                          ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
