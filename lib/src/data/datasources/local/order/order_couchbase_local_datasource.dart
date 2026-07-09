import 'package:cbl/cbl.dart';
import 'package:vendas_app/src/models/order_model.dart';
import 'package:vendas_app/src/services/couchbase_service.dart';
import 'order_local_datasource.dart';

class OrderCouchbaseLocalDatasource implements OrderLocalDatasource {
  final CouchbaseService _couchbaseService;

  OrderCouchbaseLocalDatasource(this._couchbaseService) {
    _collection;
  }

  Future<AsyncCollection> get _collection => _couchbaseService.database.createCollection('orders');

  @override
  Future<List<OrderModel>> getAll() async {
    final query = await _couchbaseService.database.createQuery('SELECT * FROM orders');
    final resultSet = await query.execute();
    final results = await resultSet.allResults();
    return results.map((r) {
      final map = r.toPlainMap();
      final data = map['orders'] as Map<String, dynamic>;
      return OrderModel.fromMap(data);
    }).toList();
  }

  @override
  Stream<List<OrderModel>> watchAll() async* {
    final database = _couchbaseService.database;
    final query = await database.createQuery('SELECT * FROM orders');
    yield* query.changes().asyncMap((change) async {
      final results = await change.results.allResults();
      return results.map((r) {
        final map = r.toPlainMap();
        final data = map['orders'] as Map<String, dynamic>;
        return OrderModel.fromMap(data);
      }).toList();
    });
  }

  @override
  Future<void> add(OrderModel order) async {
    final col = await _collection;
    final doc = MutableDocument.withId(order.id, order.toMap());
    await col.saveDocument(doc);
  }

  @override
  Future<void> update(OrderModel order) async {
    final col = await _collection;
    final doc = MutableDocument.withId(order.id, order.toMap());
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
