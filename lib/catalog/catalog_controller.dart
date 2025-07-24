import 'package:cloud_firestore/cloud_firestore.dart' show FirebaseFirestore;
import 'package:e_commerce/mediator/i_mediator.dart';
import 'package:flutter/foundation.dart' show kDebugMode, kReleaseMode;
import 'package:flutter/material.dart';
import 'package:flutter_carousel_widget/flutter_carousel_widget.dart';
import 'package:get/get.dart';
import 'package:simple_responsive/simple_responsive.dart';

part 'catalog_detail_view.dart';
part 'catalog_model.dart';
part 'catalog_service.dart';
part 'catalog_view.dart';

class CatalogController extends GetxController {
  final IMediator _mediator;

  CatalogController(this._mediator);

  static const String goToDetail = '/gotoDetail';
  static const String gotoCart = '/gotoCart';
  static const String gotoSettings = '/gotoSettings';
  static const String backToCatalog = '/backToCatalog';

  late final _view = _CatalogView(this);
  late final _service = _CatalogService();
  late final _detailView = _CatalogDetailView(this);

  final _isLoading = true.obs;

  final _catalogs = <_CatalogModel>[].obs;
  final _catalogSelected = Rx<_CatalogModel?>(null);
  final _quantity = 1.obs;

  Widget build() {
    _init();
    return _view;
  }

  Widget detailBuild() {
    if (_catalogSelected.value == null) _catalogSelected.value = _CatalogModel.fromJson(_mediator.getMediatorData().getCatalogSelected());
    return _detailView;
  }

  void _init() async {
    await _getCatalogs();
  }

  Future<void> _getCatalogs() async {
    _isLoading.value = true;
    try {
      final products = await _service.fetchCatalogs();
      _catalogs.assignAll(products.map((e) => _CatalogModel.fromJson(e)).toList());
      _mediator.getMediatorData().setCatalogs(products);
    } catch (e) {
      Get.snackbar(
        'Gagal',
        'Gagal memuat produk${kDebugMode ? ': $e' : ''}',
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade800,
      );
    }
    _isLoading.value = false;
  }

  String _formatPrice(int price) => price.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.');

  void _navigateToCart() => _mediator.notify(gotoCart);
  void _navigateToSettings() async {
    await _mediator.notify(gotoSettings);
    if (_mediator.getMediatorData().getCatalogs() != null && _mediator.getMediatorData().getCatalogs()!.isNotEmpty) {
      _catalogs.assignAll(_mediator.getMediatorData().getCatalogs()!.map((e) => _CatalogModel.fromJson(e)).toList());
    } else {
      await _getCatalogs();
    }
  }

  void _addCatalogToCart() {
    Map<String, dynamic> cartItem = {
      'name': _catalogSelected.value?.name,
      'thumbnail': _catalogSelected.value?.thumbnail,
      'description': _catalogSelected.value?.description,
      'price': _catalogSelected.value?.price,
      'quantity': _quantity.value,
    };
    _mediator.getMediatorData().addToCart(cartItem);
    Get.snackbar(
      'Berhasil',
      'Ditambahkan ke keranjang (${_quantity}x ${_catalogSelected.value?.name})',
      backgroundColor: Colors.green.shade100,
      colorText: Colors.green.shade800,
      duration: const Duration(seconds: 2),
    );
  }

  void _navigateToDetail(_CatalogModel product) {
    _mediator.getMediatorData().setCatalogSelected(product.toJson());
    _mediator.notify(goToDetail);
  }

  void _navigateBackToCatalog() {
    _catalogSelected.value = null;
    _quantity.value = 1;
    _mediator.getMediatorData().setCatalogSelected(null);
    Get.key.currentState?.canPop() ?? false ? Get.back() : _mediator.notify(backToCatalog);
  }
}
