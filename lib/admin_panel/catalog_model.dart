part of 'admin_panel_controller.dart';

class _CatalogModel {
  String id;
  final String name;
  final List<String> imagesUrl;
  String thumbnail;
  final String description;
  final int price;

  _CatalogModel({
    this.id = '',
    required this.name,
    required this.imagesUrl,
    required this.thumbnail,
    required this.description,
    required this.price,
  });

  factory _CatalogModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) throw ArgumentError('JSON data cannot be null');
    return _CatalogModel(
      id: json['id'] as String,
      name: json['name'] as String,
      imagesUrl: List<String>.from(json['imagesUrl'] as List<dynamic>),
      thumbnail: json['thumbnail'] as String,
      description: json['description'] as String,
      price: json['price'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'imagesUrl': imagesUrl, 'thumbnail': thumbnail, 'description': description, 'price': price};
  }

  _CatalogModel copyWith({String? name, List<String>? imagesUrl, String? description, int? price}) {
    return _CatalogModel(
      id: id,
      name: name ?? this.name,
      imagesUrl: imagesUrl ?? this.imagesUrl,
      thumbnail: imagesUrl != null && imagesUrl.isNotEmpty ? imagesUrl.first : thumbnail,
      description: description ?? this.description,
      price: price ?? this.price,
    );
  }
}
