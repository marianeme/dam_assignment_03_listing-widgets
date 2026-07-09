import 'package:uuid/uuid.dart';
import 'client_model.dart';
import 'product_model.dart';

class OrderItem {
  final ProductModel product;
  final int quantity;

  OrderItem({
    required this.product,
    required this.quantity,
  });

  double get total => product.price * quantity;

  OrderItem copyWith({
    ProductModel? product,
    int? quantity,
  }) {
    return OrderItem(
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'product': product.toMap(),
      'quantity': quantity,
    };
  }

  factory OrderItem.fromMap(Map<String, dynamic> map) {
    return OrderItem(
      product: ProductModel.fromMap(map['product']),
      quantity: map['quantity'] ?? 1,
    );
  }
}

class OrderModel {
  final String id;
  final ClientModel client;
  final List<OrderItem> items;
  final DateTime date;

  OrderModel({
    String? id,
    required this.client,
    required this.items,
    DateTime? date,
  }) : id = id ?? const Uuid().v4(),
       date = date ?? DateTime.now();

  double get totalAmount {
    return items.fold(0.0, (sum, item) => sum + item.total);
  }

  OrderModel copyWith({
    String? id,
    ClientModel? client,
    List<OrderItem>? items,
    DateTime? date,
  }) {
    return OrderModel(
      id: id ?? this.id,
      client: client ?? this.client,
      items: items ?? this.items,
      date: date ?? this.date,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'client': client.toMap(),
      'items': items.map((item) => item.toMap()).toList(),
      'date': date.toIso8601String(),
    };
  }

  factory OrderModel.fromMap(Map<String, dynamic> map) {
    return OrderModel(
      id: map['id'] ?? '',
      client: ClientModel.fromMap(map['client']),
      items: List<OrderItem>.from(
        (map['items'] as List<dynamic>).map((item) => OrderItem.fromMap(item)),
      ),
      date: DateTime.parse(map['date']),
    );
  }
}
