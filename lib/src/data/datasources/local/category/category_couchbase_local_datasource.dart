import 'package:cbl/cbl.dart';
import 'package:vendas_app/src/models/category_model.dart';
import 'package:vendas_app/src/services/couchbase_service.dart';
import 'category_local_datasource.dart';

class CategoryCouchbaseLocalDatasource implements CategoryLocalDatasource {
  final CouchbaseService _couchbaseService;

  CategoryCouchbaseLocalDatasource(this._couchbaseService) {
    _collection;
  }

  Future<AsyncCollection> get _collection => _couchbaseService.database.createCollection('categories');

  @override
  Future<List<CategoryModel>> getAll() async {
    final col = await _collection;
    final query = await _couchbaseService.database.createQuery('SELECT * FROM categories');
    final resultSet = await query.execute();
    final results = await resultSet.allResults();
    return results.map((r) {
      final map = r.toPlainMap();
      final data = map['categories'] as Map<String, dynamic>;
      return CategoryModel.fromMap(data);
    }).toList();
  }

  @override
  Stream<List<CategoryModel>> watchAll() async* {
    final database = _couchbaseService.database;
    final query = await database.createQuery('SELECT * FROM categories');
    yield* query.changes().asyncMap((change) async {
      final results = await change.results.allResults();
      return results.map((r) {
        final map = r.toPlainMap();
        final data = map['categories'] as Map<String, dynamic>;
        return CategoryModel.fromMap(data);
      }).toList();
    });
  }

  @override
  Future<void> add(CategoryModel category) async {
    final col = await _collection;
    final doc = MutableDocument.withId(category.id, category.toMap());
    await col.saveDocument(doc);
  }

  @override
  Future<void> update(CategoryModel category) async {
    final col = await _collection;
    final doc = MutableDocument.withId(category.id, category.toMap());
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
