import 'package:lite_storage/lite_storage.dart';

class MediatorData {
  MediatorData._();

  static final MediatorData _instance = MediatorData._();

  factory MediatorData() => _instance;

  Map<String, dynamic>? _user = LiteStorage.read('user');
  String? _role = LiteStorage.read('secret');
  List<Map<String, dynamic>>? _catalogs = [];
  Map<String, dynamic>? _catalogSelected = LiteStorage.read('catalog');
  Map<String, dynamic>? _paymentInfo = LiteStorage.read('info_payment');
  List<dynamic>? _validationPasswordsAdmin = LiteStorage.read('validation_passwords_admin');
  List<dynamic>? _carts = LiteStorage.read('carts');

  Map<String, dynamic>? getUser() => _user;
  void setUser(Map<String, dynamic> user) {
    _user = user;
    LiteStorage.write('user', user);
  }

  void setAdminRole() {
    _role = '';
    LiteStorage.write('secret', '');
  }

  bool isAdmin() => _role != null;

  void setCatalogs(List<Map<String, dynamic>>? catalogs) => _catalogs = catalogs;
  void addCatalog(Map<String, dynamic> catalog) {
    _catalogs ??= [];
    _catalogs!.add(catalog);
  }

  void updateCatalog(Map<String, dynamic> catalog) {
    if (_catalogs == null) return;
    final index = _catalogs!.indexWhere((c) => c['id'] == catalog['id']);
    if (index != -1) {
      _catalogs![index] = catalog;
    }
  }

  void removeCatalog(String catalogId) => _catalogs?.removeWhere((catalog) => catalog['id'] == catalogId);

  List<Map<String, dynamic>>? getCatalogs() => _catalogs;

  void setCatalogSelected(Map<String, dynamic>? catalog) {
    _catalogSelected = catalog;
    LiteStorage.write('catalog', catalog);
  }

  Map<String, dynamic>? getCatalogSelected() => _catalogSelected;

  void setPaymentInfo(Map<String, dynamic>? paymentInfo) {
    _paymentInfo = paymentInfo;
    LiteStorage.write('info_payment', paymentInfo);
  }

  Map<String, dynamic>? getPaymentInfo() => _paymentInfo;

  void setValidationPasswordsAdmin(List<String>? passwords) {
    _validationPasswordsAdmin = passwords;
    LiteStorage.write('validation_passwords_admin', passwords);
  }

  List<String>? getValidationPasswordsAdmin() => _validationPasswordsAdmin == null ? null : List<String>.from(_validationPasswordsAdmin!);

  void setCarts(List<Map<String, dynamic>>? carts) {
    _carts = carts;
    LiteStorage.write('carts', carts);
  }

  void addToCart(Map<String, dynamic> cartItem) {
    _carts ??= [];

    final existingItemIndex = _carts!.indexWhere((item) => item['name'] == cartItem['name']);
    if (existingItemIndex != -1) {
      _carts![existingItemIndex]['quantity'] += cartItem['quantity'];
      return;
    }

    _carts!.add(cartItem);
    LiteStorage.write('carts', _carts);
  }

  List<Map<String, dynamic>>? getCarts() => _carts == null ? null : List<Map<String, dynamic>>.from(_carts!);
}
