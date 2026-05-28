class Weather {
  final String cityName;
  final double temperature;
  final String description;
  final String iconCode;
  final int humidity;
  final double feelsLike;
  final double windSpeed;
  final int pressure;
  final int visibility;
  final double uvIndex;
  final int timezoneOffsetSeconds;
  final int sunriseUtcSeconds;
  final int sunsetUtcSeconds;
  final int windDirectionDegrees;

  Weather({
    required this.cityName,
    required this.temperature,
    required this.description,
    required this.iconCode,
    required this.humidity,
    required this.feelsLike,
    required this.windSpeed,
    required this.pressure,
    required this.visibility,
    required this.uvIndex,
    required this.timezoneOffsetSeconds,
    required this.sunriseUtcSeconds,
    required this.sunsetUtcSeconds,
    required this.windDirectionDegrees,
  });
}
