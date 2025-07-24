import 'package:cloud_firestore/cloud_firestore.dart' show FirebaseFirestore;
import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:currency_text_input_formatter/currency_text_input_formatter.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show FilteringTextInputFormatter;
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:simple_responsive/simple_responsive.dart';

import '/mediator/i_mediator.dart';

part 'admin_panel_service.dart';
part 'admin_panel_view.dart';
part 'catalog_model.dart';

class AdminPanelController extends GetxController {
  final IMediator _mediator;

  AdminPanelController(this._mediator);

  late final _view = _AdminPanelView(this);
  final _service = _AdminPanelService();

  final RxList<XFile> _selectedImages = <XFile>[].obs;
  final catalogs = <_CatalogModel>[].obs;

  final _name = TextEditingController();
  final _description = TextEditingController();
  final _price = TextEditingController();

  final _bankName = TextEditingController();
  final _accountHolderName = TextEditingController();
  final _bankAccountNumber = TextEditingController();
  final _whatsappNumber = TextEditingController();

  final RxList<TextEditingController> _validationPasswordsAdmin = <TextEditingController>[].obs;

  final RxBool _isLoadingFetchCatalogs = true.obs;
  final RxBool _isLoadingImages = false.obs;
  final RxBool _isLoadingPaymentForm = false.obs;
  final RxBool _isLoadingValidationPasswordsAdmin = false.obs;

  static const String goToUnknownRoute = '/goToUnknownRoute';
  static const String backToSetting = '/goToSetting';

  Widget build() {
    _init();
    return _view;
  }

  void _init() async {
    if (_checkCredential()) return;
    await _getCatalogs();
  }

  bool _checkCredential() {
    if (_mediator.getMediatorData().isAdmin()) return false;
    _navigateToUnknownRoute();
    return true;
  }

  String _formatPrice(int price) => price.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.');

  Future<void> _initValuesValidationPasswordsAdmin() async {
    try {
      _isLoadingValidationPasswordsAdmin.value = true;
      _loadingDialog();

      List<String>? validationPasswords = _mediator.getMediatorData().getValidationPasswordsAdmin();
      if (validationPasswords == null || validationPasswords.isEmpty) validationPasswords = await _service.fetchValidationPasswordsAdmin();

      if (validationPasswords.isNotEmpty) {
        _validationPasswordsAdmin.assignAll(validationPasswords.map((password) => TextEditingController(text: password)).toList());
        if (_validationPasswordsAdmin.isEmpty) _validationPasswordsAdmin.add(TextEditingController());
        _mediator.getMediatorData().setValidationPasswordsAdmin(validationPasswords);
        Get.back();
      }
    } catch (e) {
      Get.back();
      Get.snackbar(
        'Gagal',
        'Gagal mengambil daftar password admin${kDebugMode ? ': $e' : ''}',
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade800,
      );
    } finally {
      _isLoadingValidationPasswordsAdmin.value = false;
    }
  }

  bool _allFieldsValidationPasswordsAdminFilled() {
    if (_validationPasswordsAdmin.isEmpty) return false;
    return _validationPasswordsAdmin.every((controller) => controller.text.isNotEmpty);
  }

  void _addValidationPassword() {
    if (_allFieldsValidationPasswordsAdminFilled()) {
      _validationPasswordsAdmin.add(TextEditingController());
      return;
    }
    if (Get.isSnackbarOpen) return;
    Get.snackbar('Gagal', 'Isi semua field terlebih dahulu.', backgroundColor: Colors.red.shade100, colorText: Colors.red.shade800);
  }

  void _removeValidationPassword(int index) {
    if (_validationPasswordsAdmin.length <= 1) return;
    if (index < 0 || index >= _validationPasswordsAdmin.length) return;
    _validationPasswordsAdmin.removeAt(index);
  }

  void _saveValidationPasswordsAdmin() async {
    if (!_allFieldsValidationPasswordsAdminFilled()) {
      Get.snackbar('Gagal', 'Isi semua field terlebih dahulu.', backgroundColor: Colors.red.shade100, colorText: Colors.red.shade800);
      return;
    }

    _loadingDialog();

    final passwords = _validationPasswordsAdmin.map((controller) => controller.text).toList();

    try {
      await _service.updateValidationPasswordsAdmin(passwords);
      _mediator.getMediatorData().setValidationPasswordsAdmin(passwords);
      Get.back();
      Get.back();
      Get.snackbar(
        'Berhasil',
        'Daftar password admin berhasil disimpan.',
        backgroundColor: Colors.green.shade100,
        colorText: Colors.green.shade800,
      );
    } catch (e) {
      Get.back();
      Get.snackbar(
        'Gagal',
        'Gagal menyimpan daftar password admin${kDebugMode ? ': $e' : ''}',
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade800,
      );
    }
  }

  Future<void> _initValuesInfoPaymentForm() async {
    try {
      _isLoadingPaymentForm.value = true;
      _loadingDialog();

      Map<String, dynamic>? infoPayment = _mediator.getMediatorData().getPaymentInfo();
      if (infoPayment == null || infoPayment.isEmpty) infoPayment = await _service.fetchInfoPayment();

      if (infoPayment.isNotEmpty) {
        _bankName.text = infoPayment['bank_name'] ?? '';
        _accountHolderName.text = infoPayment['account_holder_name'] ?? '';
        _bankAccountNumber.text = infoPayment['bank_account_number'] ?? '';
        _whatsappNumber.text = infoPayment['whatsapp_number'] ?? '';
        _mediator.getMediatorData().setPaymentInfo(infoPayment);
        Get.back();
      }
    } catch (e) {
      Get.back();
      Get.snackbar(
        'Gagal',
        'Gagal mengambil informasi pembayaran${kDebugMode ? ': $e' : ''}',
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade800,
      );
    } finally {
      _isLoadingPaymentForm.value = false;
    }
  }

  void _saveInfoPayment() async {
    if (_bankName.text.isEmpty || _accountHolderName.text.isEmpty || _bankAccountNumber.text.isEmpty || _whatsappNumber.text.isEmpty) {
      Get.snackbar('Gagal', 'Isi semua field terlebih dahulu.', backgroundColor: Colors.red.shade100, colorText: Colors.red.shade800);
      return;
    }

    _loadingDialog();

    final infoPayment = {
      'bank_name': _bankName.text,
      'account_holder_name': _accountHolderName.text,
      'bank_account_number': _bankAccountNumber.text,
      'whatsapp_number': _whatsappNumber.text,
    };

    try {
      await _service.updateInfoPayment(infoPayment);
      _mediator.getMediatorData().setPaymentInfo(infoPayment);
      Get.back();
      Get.back();
      Get.snackbar(
        'Berhasil',
        'Informasi pembayaran berhasil disimpan.',
        backgroundColor: Colors.green.shade100,
        colorText: Colors.green.shade800,
      );
    } catch (e) {
      Get.back();
      Get.snackbar(
        'Gagal',
        'Gagal menyimpan informasi pembayaran${kDebugMode ? ': $e' : ''}',
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade800,
      );
    }
  }

  void _defaultValuesCatalogForm() {
    _name.clear();
    _description.clear();
    _price.clear();
    _selectedImages.clear();
  }

  void _removeImage(XFile image) => _selectedImages.remove(image);

  Future<void> _getCatalogs() async {
    _isLoadingFetchCatalogs.value = true;
    try {
      if (_mediator.getMediatorData().getCatalogs()?.isNotEmpty ?? false) {
        catalogs.value = _mediator.getMediatorData().getCatalogs()!.map((e) => _CatalogModel.fromJson(e)).toList();
        return;
      }
      final data = await _service.fetchCatalogs();
      catalogs.value = data.map((e) => _CatalogModel.fromJson(e)).toList();
    } catch (e) {
      Get.snackbar(
        'Gagal',
        'Gagal mengambil katalog${kDebugMode ? ': $e' : ''}',
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade800,
      );
    } finally {
      _isLoadingFetchCatalogs.value = false;
    }
  }

  Future<void> _addCatalog() async {
    if (_selectedImages.isEmpty) {
      Get.snackbar('Gagal', 'Pilih gambar terlebih dahulu.', backgroundColor: Colors.red.shade100, colorText: Colors.red.shade800);
      return;
    }

    if (_name.text.isEmpty || _description.text.isEmpty || _price.text.isEmpty) {
      Get.snackbar('Gagal', 'Isi semua field terlebih dahulu.', backgroundColor: Colors.red.shade100, colorText: Colors.red.shade800);
      return;
    }

    if (catalogs.any((catalog) => catalog.name.trim() == _name.text.trim())) {
      Get.snackbar(
        'Gagal',
        'Katalog dengan nama "${_name.text}" sudah ada.',
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade800,
      );
      return;
    }

    _loadingDialog();

    final imagesUrl = await _uploadImages();
    if (imagesUrl == null) {
      Get.back();
      return;
    }

    final catalog = _CatalogModel(
      name: _name.text,
      imagesUrl: imagesUrl,
      thumbnail: imagesUrl.isNotEmpty ? imagesUrl.first : '',
      description: _description.text,
      price: int.parse(_price.text.replaceAll('.', '')),
    );
    try {
      final newCatalog = await _service.createCatalog(catalog.toJson());
      catalogs.add(_CatalogModel.fromJson(newCatalog));
      _mediator.getMediatorData().addCatalog(newCatalog);
      Get.back();
      Get.back();
      Get.snackbar('Berhasil', 'Katalog berhasil ditambahkan.', backgroundColor: Colors.green.shade100, colorText: Colors.green.shade800);
    } catch (e) {
      Get.back();
      Get.back();
      Get.snackbar(
        'Gagal',
        'Gagal menambahkan katalog${kDebugMode ? ': $e' : ''}',
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade800,
      );
    }
  }

  Future<void> _updateCatalog(_CatalogModel catalog) async {
    if (_selectedImages.isEmpty) {
      Get.snackbar('Gagal', 'Pilih gambar terlebih dahulu.', backgroundColor: Colors.red.shade100, colorText: Colors.red.shade800);
      return;
    }

    if (_name.text.isEmpty || _description.text.isEmpty || _price.text.isEmpty) {
      Get.snackbar('Gagal', 'Isi semua field terlebih dahulu.', backgroundColor: Colors.red.shade100, colorText: Colors.red.shade800);
      return;
    }

    if (catalogs.any((c) => c.name.trim() == _name.text.trim() && c.id != catalog.id)) {
      Get.snackbar(
        'Gagal',
        'Katalog dengan nama "${_name.text}" sudah ada.',
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade800,
      );
      return;
    }

    _loadingDialog();

    final imagesUrl = await _uploadImages();
    if (imagesUrl == null) {
      Get.back();
      return;
    }

    final updatedCatalog = catalog.copyWith(
      name: _name.text,
      description: _description.text,
      price: int.parse(_price.text.replaceAll('.', '')),
      imagesUrl: imagesUrl,
    );

    try {
      await _service.updateCatalog(catalog.id, updatedCatalog.toJson());
      final index = catalogs.indexWhere((c) => c.id == catalog.id);
      if (index != -1) {
        catalogs[index] = updatedCatalog;
        _mediator.getMediatorData().updateCatalog(updatedCatalog.toJson());
      }
      Get.back();
      Get.back();
      Get.snackbar('Berhasil', 'Katalog berhasil diperbarui.', backgroundColor: Colors.green.shade100, colorText: Colors.green.shade800);
    } catch (e) {
      Get.back();
      Get.back();
      Get.snackbar(
        'Gagal',
        'Gagal memperbarui katalog${kDebugMode ? ': $e' : ''}',
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade800,
      );
    }
  }

  Future<void> _deleteCatalog(_CatalogModel catalog) async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Konfirmasi Hapus'),
        content: Text('Apakah Anda yakin ingin menghapus katalog "${catalog.name}"?'),
        actions: [
          TextButton(onPressed: () => Get.back(result: false), child: const Text('Batal')),
          TextButton(onPressed: () => Get.back(result: true), child: const Text('Hapus')),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        _loadingDialog();
        await _service.deleteCatalog(catalog.id);
        catalogs.removeWhere((c) => c.id == catalog.id);
        _mediator.getMediatorData().removeCatalog(catalog.id);
        Get.back();
        Get.back();
        Get.snackbar('Berhasil', 'Katalog berhasil dihapus.', backgroundColor: Colors.green.shade100, colorText: Colors.green.shade800);
      } catch (e) {
        Get.back();
        Get.back();
        Get.snackbar(
          'Gagal',
          'Gagal menghapus katalog${kDebugMode ? ': $e' : ''}',
          backgroundColor: Colors.red.shade100,
          colorText: Colors.red.shade800,
        );
      }
    }
  }

  Future<void> _selectImage() async {
    if (_isLoadingImages.value) return;
    if (_selectedImages.length >= 7) {
      Get.snackbar('Gagal', 'Maksimal 7 gambar yang dapat dipilih.', backgroundColor: Colors.red.shade100, colorText: Colors.red.shade800);
      return;
    }

    _isLoadingImages.value = true;
    final picker = ImagePicker();
    final images = await picker.pickMultiImage(limit: 7, imageQuality: 91, requestFullMetadata: false);

    if (images.isEmpty) {
      _isLoadingImages.value = false;
      return;
    }

    if (images.length > 7 || _selectedImages.length + images.length > 7) {
      Get.snackbar('Gagal', 'Maksimal 7 gambar yang dapat dipilih.', backgroundColor: Colors.red.shade100, colorText: Colors.red.shade800);
      _isLoadingImages.value = false;
      return;
    }

    const maxSizeInBytes = 10 * 1024 * 1024;
    final oversizedImages = <String>[];

    for (final image in images) {
      final length = await image.length();
      if (length > maxSizeInBytes) oversizedImages.add(image.name);
    }

    if (oversizedImages.isNotEmpty) {
      String mentionOverSizedImages = oversizedImages.join(', ');
      mentionOverSizedImages = mentionOverSizedImages.replaceAll('scaled_', '');
      Get.snackbar(
        'Gagal',
        "Gambar '$mentionOverSizedImages' terlalu besar, maksimal 10 MB.",
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade800,
      );
      _isLoadingImages.value = false;
      return;
    }
    _selectedImages.addAll(images);
    _isLoadingImages.value = false;
  }

  Future<List<String>?> _uploadImages() async {
    try {
      return await _service.uploadMultipleImages(_selectedImages);
    } catch (e) {
      Get.snackbar(
        'Gagal',
        'Gagal mengunggah gambar${kDebugMode ? ': $e' : ''}',
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade800,
      );
    }
    return null;
  }

  void _loadingDialog() {
    Get.dialog(const Center(child: CircularProgressIndicator()), barrierDismissible: false, barrierColor: Colors.black54);
  }

  void _navigateBackToSetting() => Get.key.currentState?.canPop() ?? false ? Get.back() : _mediator.notify(backToSetting);
  void _navigateToUnknownRoute() => _mediator.notify(goToUnknownRoute);
}
