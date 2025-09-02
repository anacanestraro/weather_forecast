import 'package:flutter/material.dart';

class Weather {
  final String cityName;
  final double temperature;
  final String condition;
  final IconData icon;
  final String description;
  final double humidity;
  final double windSpeed;
  final double pressure;

  const Weather({
    required this.cityName,
    required this.temperature,
    required this.condition,
    required this.icon,
    required this.description,
    this.humidity = 0,
    this.windSpeed = 0,
    this.pressure = 0,
  });

  // Factory constructor para criar Weather a partir de JSON da API
  factory Weather.fromJson(Map<String, dynamic> json) {
    final current = json['current'];
    final location = json['location'];
    final condition = current['condition'];
    final conditionCode = condition['code'] as int;
    
    return Weather(
      cityName: location['name'],
      temperature: (current['temp_c'] as num).toDouble(),
      condition: _translateCondition(conditionCode),
      icon: _getIconFromCondition(conditionCode),
      description: condition['text'],
      humidity: (current['humidity'] as num).toDouble(),
      windSpeed: (current['wind_kph'] as num?)?.toDouble() ?? 0,
      pressure: (current['pressure_mb'] as num).toDouble(),
    );
  }

  static String _translateCondition(int code) {
    return _conditionMap[code]?['translation'] ?? 'Desconhecido';
  }

  static IconData _getIconFromCondition(int code) {
    return _conditionMap[code]?['icon'] ?? Icons.help_outline;
  }

  static final Map<int, Map<String, dynamic>> _conditionMap = {
    1000: {'icon': Icons.wb_sunny, 'translation': 'Ensolarado'},
    1003: {'icon': Icons.wb_cloudy, 'translation': 'Parcialmente Nublado'},
    1006: {'icon': Icons.cloud, 'translation': 'Nublado'},
    1009: {'icon': Icons.cloud_queue, 'translation': 'Encoberto'},
    1030: {'icon': Icons.foggy, 'translation': 'Neblina'},
    1063: {'icon': Icons.grain, 'translation': 'Possibilidade de Chuva'},
    1066: {'icon': Icons.ac_unit, 'translation': 'Possibilidade de Neve'},
    1069: {'icon': Icons.ac_unit, 'translation': 'Possibilidade de Aguaceiros'},
    1072: {'icon': Icons.grain, 'translation': 'Possibilidade de Garoa Congelante'},
    1087: {'icon': Icons.flash_on, 'translation': 'Possibilidade de Trovoadas'},
    1114: {'icon': Icons.snowing, 'translation': 'Vento com Neve'},
    1117: {'icon': Icons.snowing, 'translation': 'Nevasca'},
    1135: {'icon': Icons.foggy, 'translation': 'Névoa'},
    1147: {'icon': Icons.ac_unit, 'translation': 'Névoa Congelante'},
    1150: {'icon': Icons.grain, 'translation': 'Garoa Leve'},
    1153: {'icon': Icons.grain, 'translation': 'Garoa'},
    1168: {'icon': Icons.grain, 'translation': 'Garoa Congelante'},
    1171: {'icon': Icons.grain, 'translation': 'Garoa Congelante Forte'},
    1180: {'icon': Icons.grain, 'translation': 'Chuva Fraca'},
    1183: {'icon': Icons.grain, 'translation': 'Chuva Leve'},
    1186: {'icon': Icons.grain, 'translation': 'Chuva Moderada às Vezes'},
    1189: {'icon': Icons.grain, 'translation': 'Chuva Moderada'},
    1192: {'icon': Icons.grain, 'translation': 'Chuva Forte às Vezes'},
    1195: {'icon': Icons.grain, 'translation': 'Chuva Forte'},
    1198: {'icon': Icons.ac_unit, 'translation': 'Chuva Congelante Leve'},
    1201: {'icon': Icons.ac_unit, 'translation': 'Chuva Congelante Moderada ou Forte'},
    1204: {'icon': Icons.ac_unit, 'translation': 'Aguaceiros de Neve Leve'},
    1207: {'icon': Icons.ac_unit, 'translation': 'Aguaceiros de Neve Moderada ou Forte'},
    1210: {'icon': Icons.ac_unit, 'translation': 'Neve Fraca'},
    1213: {'icon': Icons.ac_unit, 'translation': 'Neve Leve'},
    1216: {'icon': Icons.ac_unit, 'translation': 'Neve Moderada às Vezes'},
    1219: {'icon': Icons.ac_unit, 'translation': 'Neve Moderada'},
    1222: {'icon': Icons.ac_unit, 'translation': 'Neve Forte às Vezes'},
    1225: {'icon': Icons.ac_unit, 'translation': 'Neve Forte'},
    1237: {'icon': Icons.ac_unit, 'translation': 'Granizo de Gelo'},
    1240: {'icon': Icons.grain, 'translation': 'Aguaceiros Leves'},
    1243: {'icon': Icons.grain, 'translation': 'Aguaceiros Moderados ou Fortes'},
    1246: {'icon': Icons.grain, 'translation': 'Aguaceiros Torrenciais'},
    1249: {'icon': Icons.ac_unit, 'translation': 'Aguaceiros de Neve Leve'},
    1252: {'icon': Icons.ac_unit, 'translation': 'Aguaceiros de Neve Moderada ou Forte'},
    1255: {'icon': Icons.ac_unit, 'translation': 'Neve Leve'},
    1258: {'icon': Icons.ac_unit, 'translation': 'Neve Moderada ou Forte'},
    1261: {'icon': Icons.ac_unit, 'translation': 'Aguaceiros de Granizo Leve'},
    1264: {'icon': Icons.ac_unit, 'translation': 'Aguaceiros de Granizo Moderada ou Forte'},
    1273: {'icon': Icons.flash_on, 'translation': 'Chuva Leve com Trovoadas'},
    1276: {'icon': Icons.flash_on, 'translation': 'Chuva Moderada ou Forte com Trovoadas'},
    1279: {'icon': Icons.flash_on, 'translation': 'Neve Leve com Trovoadas'},
    1282: {'icon': Icons.flash_on, 'translation': 'Neve Moderada ou Forte com Trovoadas'},
  };
}

class WeatherForecast {
  final String dayOfWeek;
  final IconData icon;
  final double maxTemp;
  final double minTemp;
  final String condition;
  final DateTime date;

  const WeatherForecast({
    required this.dayOfWeek,
    required this.icon,
    required this.maxTemp,
    required this.minTemp,
    required this.condition,
    required this.date,
  });

  // Factory constructor para criar WeatherForecast a partir de JSON da API
  factory WeatherForecast.fromJson(Map<String, dynamic> json) {
    final day = json['day'];
    final condition = day['condition'];
    final conditionCode = condition['code'] as int;
    final date = DateTime.parse(json['date']);

    return WeatherForecast(
      dayOfWeek: _getDayOfWeek(date.weekday),
      icon: Weather._getIconFromCondition(conditionCode),
      maxTemp: (day['maxtemp_c'] as num).toDouble(),
      minTemp: (day['mintemp_c'] as num).toDouble(),
      condition: Weather._translateCondition(conditionCode),
      date: date,
    );
  }

  static String _getDayOfWeek(int day) {
    switch (day) {
      case DateTime.monday:
        return 'Seg';
      case DateTime.tuesday:
        return 'Ter';
      case DateTime.wednesday:
        return 'Qua';
      case DateTime.thursday:
        return 'Qui';
      case DateTime.friday:
        return 'Sex';
      case DateTime.saturday:
        return 'Sáb';
      case DateTime.sunday:
        return 'Dom';
      default:
        return '';
    }
  }
}

class WeatherData {
  // Dados mock para fallback quando a API não estiver disponível
  static Weather getCurrentWeather() => const Weather(
    cityName: "São Paulo",
    temperature: 23,
    condition: "Ensolarado",
    icon: Icons.wb_sunny,
    description: "Céu limpo com sol",
    humidity: 65,
    windSpeed: 15,
    pressure: 1013,
  );

  static List<WeatherForecast> getForecast() => [
    WeatherForecast(
      dayOfWeek: "Hoje",
      icon: Icons.wb_sunny,
      maxTemp: 26,
      minTemp: 18,
      condition: "Ensolarado",
      date: DateTime.now(),
    ),
    WeatherForecast(
      dayOfWeek: "Amanhã",
      icon: Icons.cloud,
      maxTemp: 22,
      minTemp: 15,
      condition: "Nublado",
      date: DateTime.now().add(const Duration(days: 1)),
    ),
    WeatherForecast(
      dayOfWeek: "Quarta",
      icon: Icons.grain,
      maxTemp: 19,
      minTemp: 12,
      condition: "Chuva",
      date: DateTime.now().add(const Duration(days: 2)),
    ),
    WeatherForecast(
      dayOfWeek: "Quinta",
      icon: Icons.wb_cloudy,
      maxTemp: 24,
      minTemp: 16,
      condition: "Parcialmente nublado",
      date: DateTime.now().add(const Duration(days: 3)),
    ),
    WeatherForecast(
      dayOfWeek: "Sexta",
      icon: Icons.wb_sunny,
      maxTemp: 28,
      minTemp: 20,
      condition: "Ensolarado",
      date: DateTime.now().add(const Duration(days: 4)),
    ),
  ];
}