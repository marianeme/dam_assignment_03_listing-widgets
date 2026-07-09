import 'dart:async';
import 'package:vendas_app/src/models/order_model.dart';
import 'order_local_datasource.dart';

class OrderMemoryLocalDatasource implements OrderLocalDatasource {
  final List<OrderModel> _items = [];
  final _controller = StreamController<List<OrderModel>>.broadcast();

  OrderMemoryLocalDatasource();

  @override
  Future<List<OrderModel>> getAll() async {
    return _items;
  }

  @override
  Stream<List<OrderModel>> watchAll() {
    Future.microtask(() => _controller.add(List.unmodifiable(_items)));
    return _controller.stream;
  }

  @override
  Future<void> add(OrderModel order) async {
    _items.add(order);
    _controller.add(List.unmodifiable(_items));
  }

  @override
  Future<void> update(OrderModel order) async {
    final index = _items.indexWhere((o) => o.id == order.id);
    if (index != -1) {
      _items[index] = order;
      _controller.add(List.unmodifiable(_items));
    }
  }

  @override
  Future<void> delete(String id) async {
    _items.removeWhere((o) => o.id == id);
    _controller.add(List.unmodifiable(_items));
  }
}
