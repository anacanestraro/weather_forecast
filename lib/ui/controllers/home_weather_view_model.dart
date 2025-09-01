// ViewController seguindo padrão MVVM com Signals e Commands observáveis
import 'dart:async';

import 'package:signals_flutter/signals_flutter.dart';
import 'package:weather_app/domain/models/weather.dart';
import 'package:weather_app/domain/usecases/weather_usecases_facade_contract.dart';
import 'package:weather_app/ui/commands/wether_command_impl.dart';

class WeatherHomeViewController {
  // Dependências injetadas
  late final IWeatherUseCasesFacade _weatherFacade;

  // Signals de estado geral da ViewController
  final _isInitialized = signal<bool>(false);

  Timer? _autoRefreshTimer;

  // Estado do ViewController usando Signals
  final _currentWeather = signal<Weather?>(null);
  final _forecast = signal<List<WeatherForecast>>([]);
  final _errorMessage = signal<String?>(null);

  // Getters para acessar signals (readonly)
  ReadonlySignal<Weather?> get currentWeather => _currentWeather.readonly();
  ReadonlySignal<List<WeatherForecast>> get forecast => _forecast.readonly();
  ReadonlySignal<String?> get errorMessage => _errorMessage.readonly();
  ReadonlySignal<bool> get isInitialized => _isInitialized.readonly();

  // Comandos observáveis
  late final GetWeatherByCityCommand _getCurrentWeatherCommand;
  late final GetForecastByCityCommand _getForecastCommand;
  late final GetWeatherByCoordinatesCommand _getWeatherByCoordinatesCommand;
  late final GetForecastByCoordinatesCommand _getForecastByCoordinatesCommand;
  late final GetCompleteWeatherCommand _getCompleteWeatherCommand;

  // Computed signals para estados derivados
  late final isLoading = computed(
    () =>
        _getCurrentWeatherCommand.isExecuting.value ||
        _getForecastCommand.isExecuting.value ||
        _getWeatherByCoordinatesCommand.isExecuting.value ||
        _getForecastByCoordinatesCommand.isExecuting.value ||
        _getCompleteWeatherCommand.isExecuting.value,
  );

  late final isLoadingWeather = computed(
    () =>
        _getCurrentWeatherCommand.isExecuting.value ||
        _getWeatherByCoordinatesCommand.isExecuting.value ||
        _getCompleteWeatherCommand.isExecuting.value,
  );

  late final isLoadingForecast = computed(
    () =>
        _getForecastCommand.isExecuting.value ||
        _getForecastByCoordinatesCommand.isExecuting.value ||
        _getCompleteWeatherCommand.isExecuting.value,
  );
  // Construtor
  WeatherHomeViewController({required IWeatherUseCasesFacade weatherFacade})
    : _weatherFacade = weatherFacade {
    _initializeCommands();
    _initializeData();
    _startAutoRefresh();
  }

  // Inicializar comandos
  void _initializeCommands() {
    _getCurrentWeatherCommand = GetWeatherByCityCommand(_weatherFacade);
    _getForecastCommand = GetForecastByCityCommand(_weatherFacade);
    _getCompleteWeatherCommand = GetCompleteWeatherCommand(_weatherFacade);
    _getWeatherByCoordinatesCommand = GetWeatherByCoordinatesCommand(
      _weatherFacade,
    );
    _getForecastByCoordinatesCommand = GetForecastByCoordinatesCommand(
      _weatherFacade,
    );

    // Observar mudanças nos comandos de clima e previsão
    effect(() {
      final result = _getCurrentWeatherCommand.result.value;

      if (result == null) return;

      result.fold(
        onSuccess: (weather) {
          _currentWeather.value = weather;
          _clearError();
        },
        onFailure: (error) {
          _setError(error.msg);

          if (_currentWeather.value == null) {
            _currentWeather.value = WeatherData.getCurrentWeather();
          }
          if (_forecast.value.isEmpty) {
            _forecast.value = WeatherData.getForecast();
          }
        },
      );
    });

    effect(() {
      if (_getForecastCommand.isSuccess.value) {
        _forecast.value =
            _getForecastCommand.result.value?.successValueOrNull ?? [];
        _clearError();
      }
    });

    effect(() {
      if (_getWeatherByCoordinatesCommand.isSuccess.value) {
        _currentWeather.value =
            _getWeatherByCoordinatesCommand.result.value?.successValueOrNull;
        _clearError();
      }
    });

    effect(() {
      if (_getForecastByCoordinatesCommand.isSuccess.value) {
        _forecast.value =
            _getForecastByCoordinatesCommand.result.value?.successValueOrNull ??
            [];
        _clearError();
      }
    });
    effect(() {
      if (_getCompleteWeatherCommand.isSuccess.value) {
        final data =
            _getCompleteWeatherCommand.result.value?.successValueOrNull;

        _currentWeather.value = data?.$1;
        _forecast.value = data!.$2;

        _clearError();
      }
    });
  }

  // Inicializar com dados mock
  void _initializeData() {
    _currentWeather.value = WeatherData.getCurrentWeather();
    _forecast.value = WeatherData.getForecast();
    _isInitialized.value = true;
  }

  void _startAutoRefresh() {
    _autoRefreshTimer = Timer.periodic(const Duration(minutes: 10), (_) async {
      await refreshWeather();
    });
  }

  // Buscar clima por nome da cidade
  Future<void> searchWeatherByCity(String cityName) async {
    if (cityName.trim().isEmpty) {
      _setError('Nome da cidade é obrigatório');
      return;
    }

    //_searchQuery.value = cityName.trim();
    _clearError();
    await _getCompleteWeatherCommand.executeWith((cityName: cityName.trim()));
  }

  Future<void> refreshWeather() async {
    if (currentWeather.value != null) {
      final city = currentWeather.value!.cityName;
      await searchWeatherByCity(city);
    }
  }

  // Métodos privados
  void _clearError() {
    _errorMessage.value = null;
  }

  // Métodos privados para gerenciar erro
  void _setError(String message) {
    _errorMessage.value = message;
  }

  // Limpar busca
  void clearSearch() {
    _clearError();
    _initializeData();

    // Limpar comandos
    _getCurrentWeatherCommand.clear();
    _getForecastCommand.clear();
    _getWeatherByCoordinatesCommand.clear();
    _getForecastByCoordinatesCommand.clear();
    _getCompleteWeatherCommand.clear();
  }

  // Dispose resources
  void dispose() {
    _autoRefreshTimer?.cancel();
    _getCurrentWeatherCommand.reset();
    _getForecastCommand.reset();
    _getWeatherByCoordinatesCommand.reset();
    _getForecastByCoordinatesCommand.reset();
    _getCompleteWeatherCommand.reset();
  }
}
