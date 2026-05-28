import 'dart:async';

import 'package:flutter/material.dart';

import '../../domain/models/weather.dart';
import '../../domain/usecases/get_weather_by_location_usecase.dart';
import '../../domain/usecases/get_weather_usecase.dart';
import '../../infrastructure/services/location_service.dart';

class WeatherProvider extends ChangeNotifier {
  WeatherProvider({
    required GetWeatherUseCase getWeatherUseCase,
    required GetWeatherByLocationUseCase getWeatherByLocationUseCase,
    required LocationService locationService,
  })  : _getWeatherUseCase = getWeatherUseCase,
        _getWeatherByLocationUseCase = getWeatherByLocationUseCase,
        _locationService = locationService;

  final GetWeatherUseCase _getWeatherUseCase;
  final GetWeatherByLocationUseCase _getWeatherByLocationUseCase;
  final LocationService _locationService;

  Weather? _weather;
  bool _isLoading = false;
  String? _errorMessage;
  Timer? _clockTimer;

  static const String _defaultBackground =
      'lib/features/weather/presentation/backgrounds/clear_sky_day.gif';

  Weather? get weather => _weather;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  DateTime? get localCityTime {
    final currentWeather = _weather;
    if (currentWeather == null) {
      return null;
    }

    return DateTime.now()
        .toUtc()
        .add(Duration(seconds: currentWeather.timezoneOffsetSeconds));
  }

  String get localTimeLabel {
    final time = localCityTime;
    if (time == null) {
      return '--:--';
    }

    final hours = time.hour.toString().padLeft(2, '0');
    final minutes = time.minute.toString().padLeft(2, '0');
    return '$hours:$minutes';
  }

  String get localDateLabel {
    final time = localCityTime;
    if (time == null) {
      return '';
    }

    const weekdays = <String>[
      'Mon',
      'Tue',
      'Wed',
      'Thu',
      'Fri',
      'Sat',
      'Sun',
    ];
    const months = <String>[
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    return '${weekdays[time.weekday - 1]}, ${time.day} ${months[time.month - 1]}';
  }

  String get backgroundAssetPath {
    final currentWeather = _weather;
    if (currentWeather == null) {
      return _defaultBackground;
    }

    final condition = _getWeatherConditionName(currentWeather.iconCode);
    final timeOfDay = _getTimeOfDay(localCityTime?.hour ?? DateTime.now().hour);
    return 'lib/features/weather/presentation/backgrounds/${condition}_$timeOfDay.gif';
  }

  Future<void> initialize() async {
    await loadWeatherByLocation();
  }

  Future<void> searchWeather(String city) async {
    final trimmedCity = city.trim();
    if (trimmedCity.isEmpty) {
      return;
    }

    await _loadWeather(() => _getWeatherUseCase(trimmedCity));
  }

  Future<void> loadWeatherByLocation() async {
    try {
      await _setLoading(true);
      final position = await _locationService.getCurrentPosition();
      await _loadWeather(
        () => _getWeatherByLocationUseCase(
          position.latitude,
          position.longitude,
        ),
      );
    } catch (error) {
      await _setError(_normalizeError(error));
    }
  }

  Future<void> retryLastWeatherFetch() async {
    if (_weather == null) {
      await loadWeatherByLocation();
      return;
    }

    final currentCity = _weather!.cityName;
    await searchWeather(currentCity);
  }

  Future<void> _loadWeather(
    Future<Weather> Function() request, {
    bool keepLoadingState = true,
  }) async {
    if (keepLoadingState) {
      await _setLoading(true);
    }

    try {
      final weather = await request();
      _weather = weather;
      _errorMessage = null;
      _restartClock();
      notifyListeners();
    } catch (error) {
      await _setError(_normalizeError(error));
    } finally {
      if (keepLoadingState) {
        await _setLoading(false);
      }
    }
  }

  Future<void> _setLoading(bool value) async {
    _isLoading = value;
    notifyListeners();
  }

  Future<void> _setError(String message) async {
    _errorMessage = message;
    _isLoading = false;
    _clockTimer?.cancel();
    _clockTimer = null;
    notifyListeners();
  }

  void _restartClock() {
    _clockTimer?.cancel();
    _clockTimer = Timer.periodic(const Duration(minutes: 1), (_) {
      if (_weather != null) {
        notifyListeners();
      }
    });
  }

  String _getWeatherConditionName(String iconCode) {
    final code = iconCode.substring(0, 2);
    switch (code) {
      case '01':
        return 'clear_sky';
      case '02':
        return 'few_clouds';
      case '03':
        return 'scattered_clouds';
      case '04':
        return 'broken_clouds';
      case '09':
        return 'shower_rain';
      case '10':
        return 'rain';
      case '11':
        return 'thunderstorm';
      case '13':
        return 'snow';
      case '50':
        return 'mist';
      default:
        return 'clear_sky';
    }
  }

  String _getTimeOfDay(int hour) {
    if (hour >= 6 && hour < 12) {
      return 'day';
    }
    if (hour >= 12 && hour < 18) {
      return 'afternoon';
    }
    return 'evening';
  }

  String _normalizeError(Object error) {
    final message = error.toString();
    return message.startsWith('Exception: ')
        ? message.replaceFirst('Exception: ', '')
        : message;
  }

  @override
  void dispose() {
    _clockTimer?.cancel();
    super.dispose();
  }
}
