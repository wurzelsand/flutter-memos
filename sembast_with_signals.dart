import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sembast/sembast_io.dart';
import 'package:sembast_web/sembast_web.dart';
import 'package:signals_flutter/signals_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await setupDependencies();
  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  final _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final storage = GetIt.I<LocalStorageController>();

    return MaterialApp(
      home: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Center(
            child: Column(
              mainAxisAlignment: .center,
              children: [
                Row(
                  mainAxisAlignment: .center,
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                        ),
                        onSubmitted: (value) => storage.saveText(value),
                      ),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton(
                      onPressed: () => storage.saveText(_controller.text),
                      child: const Text('Apply'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SignalBuilder(
                  builder: (context) {
                    return switch (storage.text.value) {
                      AsyncData(:final value?) => SelectableText(value),
                      AsyncData() => const Text('No data'),
                      _ => const CircularProgressIndicator(),
                    };
                  },
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () async => await storage.clear(),
                  child: const Text('Clear'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class LocalStorageController {
  LocalStorageController(this._localStorageService);

  final LocalStorageService _localStorageService;

  late final _text = FutureSignal(() => _localStorageService.getText());

  late final text = _text.readonly();

  Future<void> saveText(String newText) async {
    await _localStorageService.saveText(newText);
    _text.value = AsyncData(newText);
  }

  Future<void> clear() async {
    _text.value = const AsyncLoading();
    await _localStorageService.clear();
    _text.value = const AsyncData(null);
  }
}

class LocalStorageService {
  final _dbName = 'test.db';
  final _id = '1';
  final _store = StoreRef<String, String>('text_store');

  Future<Database>? _dbFuture;

  Future<Database> get _db {
    _dbFuture ??= _initDb();
    return _dbFuture!;
  }

  Future<Database> _initDb() async {
    if (kIsWeb) {
      return await databaseFactoryWeb.openDatabase(_dbName);
    } else {
      final dir = await getApplicationDocumentsDirectory();
      await dir.create(recursive: true);
      final dbPath = p.join(dir.path, _dbName);
      return await databaseFactoryIo.openDatabase(dbPath);
    }
  }

  Future<String?> getText() async {
    final db = await _db;
    return await _store.record(_id).get(db);
  }

  Future<void> saveText(String text) async {
    final db = await _db;
    await _store.record(_id).put(db, text);
  }

  Future<void> clear() async {
    final db = await _db;
    await _store.record(_id).delete(db);
  }
}

Future<void> setupDependencies() async {
  GetIt.I.registerLazySingleton<LocalStorageService>(
    () => LocalStorageService(),
  );

  GetIt.I.registerLazySingleton<LocalStorageController>(
    () => LocalStorageController(GetIt.I()),
  );
}
