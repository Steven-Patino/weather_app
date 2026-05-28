import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../domain/models/weather.dart';
import '../providers/weather_provider.dart';
import '../widgets/weather_detail_item.dart';
import '../widgets/weather_search_bar.dart';
import '../widgets/weather_summary_card.dart';

Color _fade(Color color, double opacity) =>
    color.withAlpha((255 * opacity).round());

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  final TextEditingController _cityController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      context.read<WeatherProvider>().initialize();
    });
  }

  @override
  void dispose() {
    _cityController.dispose();
    super.dispose();
  }

  Future<void> _handleSearch(BuildContext context) async {
    final provider = context.read<WeatherProvider>();
    await provider.searchWeather(_cityController.text);
    if (mounted) {
      FocusManager.instance.primaryFocus?.unfocus();
    }
  }

  Future<void> _handleLocation(BuildContext context) async {
    final provider = context.read<WeatherProvider>();
    await provider.loadWeatherByLocation();
    if (mounted) {
      FocusManager.instance.primaryFocus?.unfocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<WeatherProvider>(
      builder: (context, provider, _) {
        final weather = provider.weather;

        return Scaffold(
          extendBodyBehindAppBar: true,
          body: Stack(
            fit: StackFit.expand,
            children: [
              Positioned.fill(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 850),
                  child: SizedBox.expand(
                    key: ValueKey(provider.backgroundAssetPath),
                    child: Image.asset(
                      provider.backgroundAssetPath,
                      fit: BoxFit.cover,
                      alignment: Alignment.center,
                    ),
                  ),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      _fade(Colors.black, 0.08),
                      _fade(Colors.black, 0.18),
                      _fade(Colors.black, 0.28),
                    ],
                  ),
                ),
              ),
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
                  child: Column(
                    children: [
                      _HeaderPill(
                        title: 'Clima App',
                        subtitle: 'Wallpapers reactivos y hora local calculada',
                      ),
                      const SizedBox(height: 16),
                      WeatherSearchBar(
                        controller: _cityController,
                        onSearch: () => _handleSearch(context),
                        onLocationRequested: () => _handleLocation(context),
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 350),
                          child: _buildContent(context, provider, weather),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildContent(
    BuildContext context,
    WeatherProvider provider,
    Weather? weather,
  ) {
    if (provider.isLoading && weather == null) {
      return const Center(child: _LoadingPanel());
    }

    if (provider.errorMessage != null && weather == null) {
      return _ErrorPanel(
        message: provider.errorMessage!,
        onRetry: () => provider.loadWeatherByLocation(),
      );
    }

    if (weather == null) {
      return const _EmptyPanel();
    }

    return SingleChildScrollView(
      key: ValueKey(weather.cityName),
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          WeatherSummaryCard(
            weather: weather,
            localTimeLabel: provider.localTimeLabel,
            localDateLabel: provider.localDateLabel,
          ),
          const SizedBox(height: 16),
          _SectionCard(
            title: 'Detalles del clima',
            child: Wrap(
              spacing: 12,
              runSpacing: 12,
              alignment: WrapAlignment.center,
              children: [
                WeatherDetailItem(
                  icon: Icons.water_drop,
                  value: '${weather.humidity}%',
                  label: 'Humedad',
                ),
                WeatherDetailItem(
                  icon: Icons.compress,
                  value: '${weather.pressure} hPa',
                  label: 'Presión',
                ),
                WeatherDetailItem(
                  icon: Icons.visibility,
                  value: '${(weather.visibility / 1000).toStringAsFixed(1)} km',
                  label: 'Visibilidad',
                ),
                WeatherDetailItem(
                  icon: Icons.wb_sunny,
                  value: weather.uvIndex.toStringAsFixed(1),
                  label: 'Índice UV',
                ),
                WeatherDetailItem(
                  icon: Icons.navigation,
                  value: _formatWindDirection(weather.windDirectionDegrees),
                  label: 'Wind Direction',
                ),
                WeatherDetailItem(
                  icon: Icons.wb_twilight,
                  value: _formatCityTime(
                    weather.sunsetUtcSeconds,
                    weather.timezoneOffsetSeconds,
                  ),
                  label: 'Sunset Time',
                ),
                WeatherDetailItem(
                  icon: Icons.wb_sunny_outlined,
                  value: _formatCityTime(
                    weather.sunriseUtcSeconds,
                    weather.timezoneOffsetSeconds,
                  ),
                  label: 'Sunrise Time',
                ),
                WeatherDetailItem(
                  icon: Icons.air,
                  value: '${weather.windSpeed.toStringAsFixed(1)} m/s',
                  label: 'Viento',
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _SectionCard(
            title: 'Hora local',
            child: _LocalTimePanel(
              time: provider.localTimeLabel,
              date: provider.localDateLabel,
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _HeaderPill extends StatelessWidget {
  final String title;
  final String subtitle;

  const _HeaderPill({
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(26),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(26),
            color: _fade(Colors.white, 0.05),
            border: Border.all(color: _fade(Colors.white, 0.06)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  color: _fade(Colors.white, 0.82),
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _SectionCard({
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            gradient: LinearGradient(
              colors: [
                _fade(Colors.white, 0.05),
                _fade(Colors.white, 0.02),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            border: Border.all(color: _fade(Colors.white, 0.05)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 14),
              child,
            ],
          ),
        ),
      ),
    );
  }
}

class _LocalTimePanel extends StatelessWidget {
  final String time;
  final String date;

  const _LocalTimePanel({
    required this.time,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: _fade(Colors.white, 0.04),
        border: Border.all(color: _fade(Colors.white, 0.05)),
      ),
      child: Row(
        children: [
          const Icon(Icons.schedule, color: Colors.white, size: 30),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                time,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                date,
                style: TextStyle(
                  color: _fade(Colors.white, 0.84),
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LoadingPanel extends StatelessWidget {
  const _LoadingPanel();

  @override
  Widget build(BuildContext context) {
    return _StatePanel(
      icon: Icons.cloud_sync,
      title: 'Cargando clima',
      subtitle: 'Consultando la ubicación o la ciudad solicitada',
      child: const CircularProgressIndicator(color: Colors.white),
    );
  }
}

class _EmptyPanel extends StatelessWidget {
  const _EmptyPanel();

  @override
  Widget build(BuildContext context) {
    return const _StatePanel(
      icon: Icons.location_searching,
      title: 'Listo para consultar',
      subtitle: 'Busca una ciudad o usa tu ubicación actual',
    );
  }
}

class _ErrorPanel extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorPanel({
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return _StatePanel(
      icon: Icons.error_outline,
      title: 'No pudimos cargar el clima',
      subtitle: message,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black87,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
        onPressed: onRetry,
        icon: const Icon(Icons.refresh),
        label: const Text('Reintentar ubicación'),
      ),
    );
  }
}

class _StatePanel extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget? child;

  const _StatePanel({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              color: _fade(Colors.white, 0.04),
              border: Border.all(color: _fade(Colors.white, 0.05)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 42, color: Colors.white),
                const SizedBox(height: 14),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  subtitle,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: _fade(Colors.white, 0.82),
                    fontSize: 14,
                    height: 1.35,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (child != null) ...[
                  const SizedBox(height: 18),
                  child!,
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

String _formatWindDirection(int degrees) {
  if (degrees <= 0) {
    return 'N';
  }

  const directions = <String>[
    'N',
    'NNE',
    'NE',
    'ENE',
    'E',
    'ESE',
    'SE',
    'SSE',
    'S',
    'SSW',
    'SW',
    'WSW',
    'W',
    'WNW',
    'NW',
    'NNW',
  ];

  final index = ((degrees / 22.5) + 0.5).floor() % 16;
  return directions[index];
}

String _formatCityTime(int unixSeconds, int timezoneOffsetSeconds) {
  if (unixSeconds <= 0) {
    return '--:--';
  }

  final localTime = DateTime.fromMillisecondsSinceEpoch(
    (unixSeconds + timezoneOffsetSeconds) * 1000,
    isUtc: true,
  );

  final hours = localTime.hour.toString().padLeft(2, '0');
  final minutes = localTime.minute.toString().padLeft(2, '0');
  return '$hours:$minutes';
}
