part of 'catalog_controller.dart';

class _CatalogModel {
  final String name;
  final List<String> imagesUrl;
  final String thumbnail;
  final String description;
  final int price;

  _CatalogModel({required this.name, required this.imagesUrl, required this.thumbnail, required this.description, required this.price});

  factory _CatalogModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      throw ArgumentError('JSON data cannot be null');
    }
    return _CatalogModel(
      name: json['name'] as String,
      imagesUrl: List<String>.from(json['imagesUrl'] as List<dynamic>),
      thumbnail: json['thumbnail'] as String,
      description: json['description'] as String,
      price: json['price'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {'name': name, 'imagesUrl': imagesUrl, 'thumbnail': thumbnail, 'description': description, 'price': price};
  }
}
