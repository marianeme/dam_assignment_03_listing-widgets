import 'package:cbl/cbl.dart';

class CouchbaseService {
  AsyncDatabase? _database;

  CouchbaseService();

  AsyncDatabase get database {
    final db = _database;
    if (db == null) {
      throw StateError('Database not initialized. Make sure init() is called first.');
    }
    return db;
  }

  Future<void> init() async {
    final databaseName = 'vendas_app';
    _database ??= await Database.openAsync(databaseName);
  }

  Future<void> close() async {
    await _database?.close();
  }
}
