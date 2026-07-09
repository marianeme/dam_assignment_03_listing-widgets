import 'package:cbl/cbl.dart';
import 'package:vendas_app/src/models/client_model.dart';
import 'package:vendas_app/src/services/couchbase_service.dart';
import 'client_local_datasource.dart';

class ClientCouchbaseLocalDatasource implements ClientLocalDatasource {
  final CouchbaseService _couchbaseService;

  ClientCouchbaseLocalDatasource(this._couchbaseService) {
    _collection;
  }

  Future<AsyncCollection> get _collection => _couchbaseService.database.createCollection('clients');

  AsyncDatabase get database => _couchbaseService.database;

  @override
  Future<List<ClientModel>> getAll() async {
    final query = await _couchbaseService.database.createQuery('SELECT * FROM clients');
    final resultSet = await query.execute();
    final results = await resultSet.allResults();
    return results.map((r) {
      final map = r.toPlainMap();
      final data = map['clients'] as Map<String, dynamic>;
      return ClientModel.fromMap(data);
    }).toList();
  }

  @override
  Stream<List<ClientModel>> watchAll() async* {
    final database = _couchbaseService.database;
    final query = await database.createQuery('SELECT * FROM clients');
    yield* query.changes().asyncMap((change) async {
      final results = await change.results.allResults();
      return results.map((r) {
        final map = r.toPlainMap();
        final data = map['clients'] as Map<String, dynamic>;
        return ClientModel.fromMap(data);
      }).toList();
    });
  }

  @override
  Future<void> add(ClientModel client) async {
    final col = await _collection;
    final doc = MutableDocument.withId(client.id, client.toMap());
    await col.saveDocument(doc);
  }

  @override
  Future<void> update(ClientModel client) async {
    final col = await _collection;
    final doc = MutableDocument.withId(client.id, client.toMap());
    await col.saveDocument(doc);
  }

  @override
  Future<void> delete(String id) async {
    final col = await _collection;
    final doc = await col.document(id);
    if (doc != null) {
      await col.deleteDocument(doc);
    }
  }
}
