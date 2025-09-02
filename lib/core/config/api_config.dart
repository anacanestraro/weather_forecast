class ApiConfig {
  // WeatherAPI
  static const String weatherApiBaseUrl = 'https://api.weatherapi.com/v1';
  static const String weatherApiKey = '77dfb9b2071947299c301838250209';
  // Timeouts
  static const Duration requestTimeout = Duration(seconds: 30);
  static const Duration connectionTimeout = Duration(seconds: 15);

  // Métodos auxiliares - WeatherAPI
  static String buildCurrentWeatherUrl(String cityName) {
    return '$weatherApiBaseUrl/current.json'
        '?key=$weatherApiKey'
        '&q=$cityName'
        '&lang=pt';
  }

  static String buildForecastUrl(String cityName, {int days = 3}) {
    return '$weatherApiBaseUrl/forecast.json'
        '?key=$weatherApiKey'
        '&q=$cityName'
        '&days=$days'
        '&lang=pt';
  }

  static String buildCurrentWeatherByCoordinatesUrl(double lat, double lon) {
    return '$weatherApiBaseUrl/current.json'
        '?key=$weatherApiKey'
        '&q=$lat,$lon'
        '&lang=pt';
  }

  static String buildForecastByCoordinatesUrl(
    double lat,
    double lon, {
    int days = 3,
  }) {
    return '$weatherApiBaseUrl/forecast.json'
        '?key=$weatherApiKey'
        '&q=$lat,$lon'
        '&days=$days'
        '&lang=pt';
  }
}
