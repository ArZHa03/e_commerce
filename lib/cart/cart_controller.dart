import 'package:cloud_firestore/cloud_firestore.dart' show FirebaseFirestore;
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show Clipboard, ClipboardData;
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart' show launchUrl;

import '../mediator/i_mediator.dart';

part 'cart_model.dart';
part 'cart_service.dart';
part 'cart_view.dart';

class CartController extends GetxController {
  final IMediator _mediator;

  CartController(this._mediator);

  static const String backToCatalog = '/backToCatalog';

  late final _view = _CartView(this);
  late final _service = _CartService();

  final RxList<_CartModel> _carts = <_CartModel>[].obs;
  final RxInt _totalPrice = 0.obs;
  final RxMap<String, dynamic> _paymentInfo = <String, dynamic>{}.obs;
  final RxMap<String, dynamic> _user = <String, dynamic>{}.obs;

  Widget build() {
    _initDataCharts();
    return _view;
  }

  void _decreaseQuantity(int index) {
    if (_carts[index].quantity > 1) _carts[index].quantity--;
    _carts.refresh();
    _mediator.getMediatorData().setCarts(_carts.map((e) => e.toJson()).toList());
  }

  void _increaseQuantity(int index) {
    _carts[index].quantity++;
    _carts.refresh();
    _mediator.getMediatorData().setCarts(_carts.map((e) => e.toJson()).toList());
  }

  void _removeItem(int index) {
    _carts.removeAt(index);
    _mediator.getMediatorData().setCarts(_carts.map((e) => e.toJson()).toList());
  }

  Future<void> _getUserData() async {
    final userData = _mediator.getMediatorData().getUser();
    if (userData != null) _user.assignAll(userData);

    if (_user.isEmpty) {
      await Get.dialog(
        barrierDismissible: false,
        PopScope(
          canPop: false,
          child: Center(
            child: AlertDialog(
              title: Center(child: Text('Masukkan Data Diri')),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(decoration: InputDecoration(labelText: 'Nama'), onChanged: (value) => _user['name'] = value),
                  TextField(
                    decoration: InputDecoration(labelText: 'Alamat'),
                    onChanged: (value) => _user['address'] = value,
                    maxLines: 3,
                    maxLength: 255,
                  ),
                ],
              ),
              actions: [
                ElevatedButton(
                  onPressed: () {
                    if (_user['name'] != null && _user['address'] != null) {
                      _mediator.getMediatorData().setUser(_user);
                      Get.back();
                    } else {
                      Get.snackbar('Error', 'Nama dan alamat harus diisi');
                    }
                  },
                  child: Text('Simpan'),
                ),
              ],
            ),
          ),
        ),
      );
    }
  }

  Future<void> _getDataPaymentInfo() async {
    try {
      _loadingDialog();
      if (_mediator.getMediatorData().getPaymentInfo() != null) {
        _paymentInfo.assignAll(_mediator.getMediatorData().getPaymentInfo()!);
        return;
      }
      final paymentInfo = await _service.fetchPaymentInfo();
      _paymentInfo.assignAll(paymentInfo);
      _mediator.getMediatorData().setPaymentInfo(paymentInfo);
      Get.back();
    } catch (e) {
      Get.back();
      Get.snackbar(
        'Gagal',
        'Gagal memuat informasi pembayaran${kDebugMode ? ': $e' : ''}',
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade800,
      );
    }
  }

  void _initDataCharts() {
    void calculateTotalPrice() => _totalPrice.value = _carts.fold(0, (sum, item) => sum + (item.price * item.quantity));

    final chartData = _mediator.getMediatorData().getCarts();
    if (chartData != null) {
      _carts.assignAll(chartData.map((e) => _CartModel.fromJson(e)).toList());
      calculateTotalPrice();
    }
  }

  void _contactWhatsapp() {
    final msgBuffer =
        StringBuffer()
          ..writeln('*Pemesanan dari:*')
          ..writeln('*Nama:* ${_user['name']}')
          ..writeln('*Alamat:* ${_user['address']}\n')
          ..writeln('*Rincian:*')
          ..writeAll(_carts.map((c) => '- ${c.name} x${c.quantity} (Rp ${_formatPrice(c.price * c.quantity)})\n'))
          ..writeln('\n*Total:* Rp ${_formatPrice(_totalPrice.value)}');

    final message = Uri.encodeComponent(msgBuffer.toString());
    final url = 'https://wa.me/${_paymentInfo['whatsapp_number']}?text=$message';

    launchUrl(Uri.parse(url));
  }

  void _askClosePayment() {
    Get.defaultDialog(
      title: 'Konfirmasi',
      content: Text('Apakah Anda yakin ingin menutup pembayaran? Semua data keranjang akan dihapus.'),
      actions: [
        TextButton(
          onPressed: () {
            _carts.clear();
            _totalPrice.value = 0;
            _mediator.getMediatorData().setCarts([]);
            Get.back(closeOverlays: true);
            Get.snackbar('Berhasil', 'Keranjang telah dibersihkan');
          },
          child: Text('Ya'),
        ),
        TextButton(onPressed: Get.back, child: Text('Tidak')),
      ],
    );
  }

  String _formatPrice(int price) => price.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.');

  void _loadingDialog() => Get.dialog(Center(child: CircularProgressIndicator()), barrierDismissible: false, barrierColor: Colors.black54);

  void _navigateBackToCatalog() => Get.key.currentState?.canPop() ?? false ? Get.back() : _mediator.notify(backToCatalog);
}
