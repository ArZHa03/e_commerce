part of 'cart_controller.dart';

class _CartModel {
  final String name;
  final String thumbnail;
  final String description;
  final int price;
  int quantity;

  _CartModel({required this.name, required this.thumbnail, required this.description, required this.price, required this.quantity});

  factory _CartModel.fromJson(Map<String, dynamic> json) {
    return _CartModel(
      name: json['name'] as String,
      thumbnail: json['thumbnail'] as String,
      description: json['description'] as String,
      price: json['price'] as int,
      quantity: json['quantity'] as int,
    );
  }

  Map<String, dynamic> toJson() => {'name': name, 'thumbnail': thumbnail, 'description': description, 'price': price, 'quantity': quantity};
}
