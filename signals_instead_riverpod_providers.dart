import 'dart:async';

import 'package:flutter/material.dart';
import 'package:signals_flutter/signals_flutter.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';

///////////////////////////////////////////////////////////////////////////////
/// helloWorld Factory
///////////////////////////////////////////////////////////////////////////////

String helloWorld() => 'Hello World!';

///////////////////////////////////////////////////////////////////////////////
/// Clock
///////////////////////////////////////////////////////////////////////////////

class Clock {
  Clock() {
    _timer = Timer.periodic(Duration(seconds: 1), (_) {
      time.value = DateTime.now();
    });
  }

  late final Timer _timer;

  final time = signal(DateTime.now());

  void dispose() {
    _timer.cancel();
  }
}

///////////////////////////////////////////////////////////////////////////////
/// Counter
///////////////////////////////////////////////////////////////////////////////

class Counter {
  final current = signal(0);

  void increment() {
    current.value++;
  }

  void reset() {
    current.value = 0;
  }
}

///////////////////////////////////////////////////////////////////////////////
/// Fake WeatherRepository
///////////////////////////////////////////////////////////////////////////////

class WeatherRepository {
  static const _conditions = ['cloudy', 'sunny', 'rainy', 'foggy'];
  var _runs = 0;

  Future<String> getWeather() async {
    _runs++;
    if (_runs % 3 == 0) {
      throw StateError('server not found.');
    } else {
      await Future.delayed(const Duration(seconds: 1));
      return _conditions[_runs % 4];
    }
  }
}

class WeatherController {
  WeatherController(this._repository);

  final WeatherRepository _repository;

  final result = signal<AsyncState<String>?>(null);

  Future<void> loadWeather() async {
    result.value = AsyncLoading();
    try {
      final weather = await _repository.getWeather();
      result.value = AsyncData(weather);
    } catch (error, stackTrace) {
      result.value = AsyncError(error, stackTrace);
    }
  }
}

///////////////////////////////////////////////////////////////////////////////
/// Fake FirebaseAuth (StreamProvider)
///////////////////////////////////////////////////////////////////////////////

class FirebaseAuth {
  FirebaseAuth._();

  static final FirebaseAuth instance = FirebaseAuth._();

  final _authStateController = StreamController<String?>.broadcast();
  var _runs = 0;
  String? _currentUser;

  Stream<String?> authStateChanges() async* {
    yield _currentUser;
    yield* _authStateController.stream;
  }

  Future<void> signIn() async {
    _runs++;
    await Future.delayed(const Duration(seconds: 1));
    if (_runs % 3 == 0) {
      _authStateController.addError(StateError('SignIn error'));
    } else {
      _currentUser = 'John Doe';
      _authStateController.add(_currentUser);
    }
  }

  Future<void> signOut() async {
    await Future.delayed(const Duration(seconds: 1));
    _currentUser = null;
    _authStateController.add(_currentUser);
  }
}

class FirebaseAuthController {
  FirebaseAuthController(this._auth);

  final FirebaseAuth _auth;

  // streamSignal wandelt den Stream automatisch um und kümmert sich um Data/Error/Loading
  late final authState = streamSignal<String?>(() => _auth.authStateChanges());

  void dispose() {
    authState.dispose(); // streamSignal bringt seine eigene dispose-Methode mit
  }

  void _setReloading() {
    final current = authState.value;
    if (current is AsyncData<String?>) {
      authState.value = AsyncDataReloading(current.value);
    } else if (current is AsyncError<String?>) {
      authState.value = AsyncErrorReloading(current.error, current.stackTrace);
    } else {
      authState.value = const AsyncLoading();
    }
  }

  Future<void> signIn() async {
    _setReloading(); // Den aktuellen Zustand cachen und auf Reloading setzen
    await _auth.signIn();
  }

  Future<void> signOut() async {
    _setReloading(); // Den aktuellen Zustand cachen und auf Reloading setzen
    await _auth.signOut();
  }
}

///////////////////////////////////////////////////////////////////////////////
/// FlexibleCounter
///////////////////////////////////////////////////////////////////////////////

class FlexibleCounter {
  FlexibleCounter(this._step);

  final int _step;

  final current = signal(0);

  void increment() {
    current.value += _step;
  }
}

///////////////////////////////////////////////////////////////////////////////
/// Dependency Injection
///////////////////////////////////////////////////////////////////////////////

void setupArchitecture() {
  GetIt.I.registerLazySingleton(helloWorld, instanceName: 'helloWorld');
  GetIt.I.registerLazySingleton(
    () => Clock(),
    dispose: (clock) => clock.dispose(),
  );
  GetIt.I.registerLazySingleton(() => Counter());
  GetIt.I.registerLazySingleton(() => WeatherRepository());
  GetIt.I.registerLazySingleton(
    () => WeatherController(GetIt.I<WeatherRepository>()),
  );
  GetIt.I.registerLazySingleton(() => FirebaseAuth.instance);
  GetIt.I.registerLazySingleton(
    () => FirebaseAuthController(GetIt.I<FirebaseAuth>()),
    dispose: (controller) => controller.dispose(),
  );
  GetIt.I.registerLazySingleton(
    () => FlexibleCounter(1),
    instanceName: 'step1',
  );
  GetIt.I.registerLazySingleton(
    () => FlexibleCounter(2),
    instanceName: 'step2',
  );
}

void main() {
  setupArchitecture();
  runApp(const MainApp());
}

///////////////////////////////////////////////////////////////////////////////
/// MainApp
///////////////////////////////////////////////////////////////////////////////

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(home: HomePage());
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final Function() _disposeEffect;
  bool _isFirstRun = true;

  @override
  void initState() {
    super.initState();

    // Wir registrieren einen Effect, der auf Änderungen des Counters hört
    _disposeEffect = effect(() {
      final current = GetIt.I<Counter>().current.value;

      if (_isFirstRun) {
        _isFirstRun = false;
        return;
      }

      // Ab hier wird es nur nach Klicks aufgerufen, daher klappt es ohne addPostFrameCallback
      final messenger = ScaffoldMessenger.of(context);
      messenger.clearSnackBars();
      messenger.showSnackBar(
        SnackBar(
          content: Text('Value is $current'),
          duration: const Duration(seconds: 1),
        ),
      );
    });
  }

  @override
  void dispose() {
    _disposeEffect(); // Wichtig: Den Effect aufräumen, wenn das Widget zerstört wird
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SignalBuilder(
          builder: (context) {
            final text = GetIt.I<String>(instanceName: 'helloWorld');
            final currentTime = GetIt.I<Clock>().time.value;
            final timeFormatted = DateFormat.Hms().format(currentTime);
            final counter = GetIt.I<Counter>().current.value;
            final controller = GetIt.I<WeatherController>();
            final authController = GetIt.I<FirebaseAuthController>();
            final flexibleCounter1 = GetIt.I<FlexibleCounter>(
              instanceName: 'step1',
            );
            final flexibleCounter2 = GetIt.I<FlexibleCounter>(
              instanceName: 'step2',
            );
            return Column(
              mainAxisAlignment: .center,
              children: [
                Text(text),
                Text(timeFormatted),
                ElevatedButton(
                  onPressed: () => GetIt.I<Counter>().increment(),
                  child: Text('Value: $counter'),
                ),
                ElevatedButton(
                  onPressed: () => GetIt.I<Counter>().reset(),
                  child: const Text('Reset Counter'),
                ),
                Row(
                  mainAxisAlignment: .center,
                  children: [
                    ElevatedButton(
                      onPressed: () => controller.loadWeather(),
                      child: const Text('Weather'),
                    ),
                    switch (controller.result.value) {
                      null =>
                        const SizedBox.shrink(), // Leeres Widget für den Startzustand
                      AsyncLoading() => const CircularProgressIndicator(),
                      AsyncData(:final value) => Text('Weather: $value'),
                      AsyncError(:final error) => Text(error.toString()),
                    },
                  ],
                ),
                ElevatedButton(
                  onPressed: authController.authState.value is AsyncLoading
                      ? null
                      : () {
                          switch (authController.authState.value) {
                            case AsyncData(value: _?):
                              authController.signOut();
                            default:
                              authController.signIn();
                          }
                        },
                  child: switch (authController.authState.value) {
                    AsyncData(:final value?) => Text(value),
                    AsyncError(:final error) => Text(error.toString()),
                    _ => const Text('login'),
                  },
                ),
                Row(
                  mainAxisAlignment: .center,
                  children: [
                    ElevatedButton(
                      onPressed: () => GetIt.I<FlexibleCounter>(
                        instanceName: 'step1',
                      ).increment(),
                      child: Text(
                        '${flexibleCounter1.current.value} (next -> +1)',
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () => GetIt.I<FlexibleCounter>(
                        instanceName: 'step2',
                      ).increment(),
                      child: Text(
                        '${flexibleCounter2.current.value} (next -> +2)',
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
