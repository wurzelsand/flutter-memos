import 'dart:io' as io;

import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:rxdart/subjects.dart';
import 'package:sqflite/sqflite.dart';

class DataPair {
  DataPair({this.id, required this.first, required this.second});

  int? id;
  String first;
  String second;

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'first': first,
      'second': second,
    };
  }
}

class MyDatabaseProvider with ChangeNotifier {
  MyDatabaseProvider(
      {required this.subdir, this.databaseName = 'database.sql'}) {
    _initialize();
  }

  static const tableName = 'vocabularies';

  final String subdir;
  final String databaseName;

  late io.Directory _appDirectory;
  late Database _sqlDatabase;
  final _initializingNotifier =
      BehaviorSubject<void>(); // Like StreamController, but capturing last item

  Future<void> get _initialized async {
    return await _initializingNotifier.first;
  }

  Future<void> _initialize() async {
    _appDirectory = await getApplicationDocumentsDirectory();
    final databaseDirectory = io.Directory(p.join(_appDirectory.path, subdir));
    final databasePath = p.join(databaseDirectory.path, databaseName);
    databaseDirectory.createSync();

    _sqlDatabase = await openDatabase(
      databasePath,
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE $tableName (id INTEGER PRIMARY KEY AUTOINCREMENT, first TEXT, second TEXT)',
        );
      },
      version: 1,
    );

    // ignore: void_checks
    _initializingNotifier.add(());
  }

  Future<void> add(DataPair dataPair) async {
    await _initialized;

    await _sqlDatabase.insert(
      tableName,
      dataPair.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    notifyListeners();
  }

  Future<void> update(DataPair dataPair) async {
    await _initialized;

    if (dataPair.id == null) {
      return;
    }
    await _sqlDatabase.update(
      tableName,
      dataPair.toMap(),
      where: 'id = ?',
      whereArgs: [dataPair.id],
    );
    notifyListeners();
  }

  Future<List<DataPair>> getAll() async {
    await _initialized;

    final jsonMap = await _sqlDatabase.query(tableName);
    return [
      for (final {
            'id': id as int,
            'first': first as String,
            'second': second as String,
          } in jsonMap)
        DataPair(id: id, first: first, second: second)
    ];
  }

  Future<DataPair?> get({required int id}) async {
    await _initialized;

    final rows =
        await _sqlDatabase.query(tableName, where: 'id = ?', whereArgs: [id]);
    final jsonMap = rows.firstOrNull;
    switch (jsonMap) {
      case {'id': int id, 'first': String first, 'second': String second}:
        return DataPair(id: id, first: first, second: second);
      default:
        return null;
    }
  }

  Future<void> delete({required int id}) async {
    await _initialized;

    await _sqlDatabase.delete(tableName, where: 'id = ?', whereArgs: [id]);
    notifyListeners();
  }
}
