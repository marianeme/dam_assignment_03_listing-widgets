import 'package:cbl/cbl.dart';
import 'package:vendas_app/src/models/product_model.dart';
import 'package:vendas_app/src/services/couchbase_service.dart';
import 'product_local_datasource.dart';

class ProductCouchbaseLocalDatasource implements ProductLocalDatasource {
  final CouchbaseService _couchbaseService;

  ProductCouchbaseLocalDatasource(this._couchbaseService) {
    _collection;
  }

  Future<AsyncCollection> get _collection => _couchbaseService.database.createCollection('products');

  @override
  Future<List<ProductModel>> getAll() async {
    final query = await _couchbaseService.database.createQuery('SELECT * FROM products');
    final resultSet = await query.execute();
    final results = await resultSet.allResults();
    return results.map((r) {
      final map = r.toPlainMap();
      final data = map['products'] as Map<String, dynamic>;
      return ProductModel.fromMap(data);
    }).toList();
  }

  @override
  Future<void> add(ProductModel product) async {
    final col = await _collection;
    final doc = MutableDocument.withId(product.id, product.toMap());
    await col.saveDocument(doc);
  }

  Stream<ProductModel> getProductStream(String id) async* {
    final col = await _collection;
    final initialDoc = await col.document(id);
    if (initialDoc != null) {
      yield ProductModel.fromMap(initialDoc.toPlainMap());
    }

    yield* col
        .documentChanges(id)
        .asyncMap((change) => col.document(id))
        .where((doc) => doc != null)
        .map((doc) => ProductModel.fromMap(doc!.toPlainMap()));
  }

  @override
  Stream<List<ProductModel>> watchAll() async* {
    final database = _couchbaseService.database;
    final query = await database.createQuery('SELECT * FROM products');
    yield* query.changes().asyncMap((change) async {
      final results = await change.results.allResults();
      return results.map((r) {
        final map = r.toPlainMap();
        final data = map['products'] as Map<String, dynamic>;
        return ProductModel.fromMap(data);
      }).toList();
    });
  }

  @override
  Future<void> update(ProductModel product) async {
    final col = await _collection;
    final doc = MutableDocument.withId(product.id, product.toMap());
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
