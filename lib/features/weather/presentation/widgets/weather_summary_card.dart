import 'dart:ui';

import 'package:flutter/material.dart';

import '../../domain/models/weather.dart';

Color _fade(Color color, double opacity) =>
    color.withAlpha((255 * opacity).round());

class WeatherSummaryCard extends StatelessWidget {
  final Weather weather;
  final String localTimeLabel;
  final String localDateLabel;

  const WeatherSummaryCard({
    super.key,
    required this.weather,
    required this.localTimeLabel,
    required this.localDateLabel,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(32),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(32),
            gradient: LinearGradient(
              colors: [
                _fade(Colors.white, 0.06),
                _fade(Colors.white, 0.02),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            border: Border.all(color: _fade(Colors.white, 0.05)),
            boxShadow: [
              BoxShadow(
                color: _fade(Colors.black, 0.06),
                blurRadius: 28,
                offset: const Offset(0, 16),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          weather.cityName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 30,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          weather.description.toUpperCase(),
                          style: TextStyle(
                            color: _fade(Colors.white, 0.80),
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (weather.iconCode.isNotEmpty)
                    Image.network(
                      'https://openweathermap.org/img/wn/${weather.iconCode}@4x.png',
                      height: 92,
                      width: 92,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) =>
                          const SizedBox(width: 92),
                    ),
                ],
              ),
              const SizedBox(height: 18),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${weather.temperature.toStringAsFixed(1)}°',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 60,
                      fontWeight: FontWeight.w900,
                      height: 0.95,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Text(
                      'C',
                      style: TextStyle(
                        color: _fade(Colors.white, 0.78),
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const Spacer(),
                  _Pill(
                    icon: Icons.schedule,
                    label: localTimeLabel,
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                localDateLabel,
                style: TextStyle(
                  color: _fade(Colors.white, 0.78),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  final IconData icon;
  final String label;

  const _Pill({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: _fade(Colors.white, 0.04),
        border: Border.all(color: _fade(Colors.white, 0.06)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.white),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
