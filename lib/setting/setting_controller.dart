import 'package:cloud_firestore/cloud_firestore.dart' show FirebaseFirestore;
import 'package:flutter/foundation.dart' show kDebugMode, kReleaseMode;
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '/mediator/i_mediator.dart';

part 'setting_service.dart';
part 'setting_view.dart';

class SettingController extends GetxController {
  final IMediator _mediator;

  SettingController(this._mediator);

  late final _view = _SettingView(this);
  late final _service = _SettingService();

  final _name = TextEditingController();
  final _address = TextEditingController();
  final _password = TextEditingController();

  final _isAdmin = false.obs;
  final _isLoading = false.obs;

  static const String goToCatalogPanel = '/goToCatalogPanel';
  static const String backToCatalog = '/goToCatalog';

  Widget build() {
    _init();
    return _view;
  }

  void _init() {
    final user = _mediator.getMediatorData().getUser();
    _name.text = user?['name'] ?? '';
    _address.text = user?['address'] ?? '';
    _isAdmin.value = _mediator.getMediatorData().isAdmin();
  }

  void _save() {
    final user = {'name': _name.text, 'address': _address.text};
    _mediator.getMediatorData().setUser(user);
    Get.snackbar('Berhasil', 'Data berhasil disimpan');
  }

  void _confirmPassword() async {
    _isLoading.value = true;
    final validationsAdmin = await _service.fetchAdminValidations();
    if (validationsAdmin.contains(_password.text)) {
      _mediator.getMediatorData().setAdminRole();
      _isAdmin.value = true;
      Get.snackbar('Berhasil', 'Anda menjadi Admin');
    }
    _isLoading.value = false;
  }

  void _navigateToCatalog() => _mediator.notify(goToCatalogPanel);
  void _navigateBackToCatalogPanel() => Get.key.currentState?.canPop() ?? false ? Get.back() : _mediator.notify(backToCatalog);
}
