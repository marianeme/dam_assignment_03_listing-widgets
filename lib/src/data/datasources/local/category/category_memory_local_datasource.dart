import 'dart:async';
import 'package:vendas_app/src/models/category_model.dart';
import 'category_local_datasource.dart';

class CategoryMemoryLocalDatasource implements CategoryLocalDatasource {
  final List<CategoryModel> _items = [];
  final _controller = StreamController<List<CategoryModel>>.broadcast();

  CategoryMemoryLocalDatasource() {
    _items.addAll([
      CategoryModel(name: 'Informática'),
      CategoryModel(name: 'Móveis'),
      CategoryModel(name: 'Geral'),
    ]);
  }

  @override
  Future<List<CategoryModel>> getAll() async {
    return List.unmodifiable(_items);
  }

  @override
  Stream<List<CategoryModel>> watchAll() {
    Future.microtask(() => _controller.add(List.unmodifiable(_items)));
    return _controller.stream;
  }

  @override
  Future<void> add(CategoryModel category) async {
    _items.add(category);
    _controller.add(List.unmodifiable(_items));
  }

  @override
  Future<void> update(CategoryModel category) async {
    final index = _items.indexWhere((c) => c.id == category.id);
    if (index != -1) {
      _items[index] = category;
      _controller.add(List.unmodifiable(_items));
    }
  }

  @override
  Future<void> delete(String id) async {
    _items.removeWhere((c) => c.id == id);
    _controller.add(List.unmodifiable(_items));
  }
}
