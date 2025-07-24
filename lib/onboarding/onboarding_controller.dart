import 'package:cloud_firestore/cloud_firestore.dart' show FirebaseFirestore;
import 'package:flutter/foundation.dart' show kDebugMode, kReleaseMode;
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '/mediator/i_mediator.dart';

part 'onboarding_service.dart';
part 'onboarding_view.dart';

class OnBoardingController extends GetxController {
  final IMediator _mediator;

  OnBoardingController(this._mediator);

  late final _view = _OnboardingView(this);
  late final _service = _OnboardingService();

  final _name = TextEditingController();
  final _address = TextEditingController();
  final _key = GlobalKey<FormState>();
  final _isLoading = true.obs;

  final List<String> _validationsAdmin = [];

  static const String goToCatalog = '/goToCatalog';

  Widget build() {
    _init();
    return _view;
  }

  void _init() async {
    final user = _mediator.getMediatorData().getUser();
    final role = _mediator.getMediatorData().isAdmin();
    if (user != null || role) return _mediator.notify(goToCatalog);

    _validationsAdmin.assignAll(await _service.fetchAdminValidations());

    _isLoading.value = false;
  }

  void _handleAdminRole(String value) {
    if (_validationsAdmin.contains(value)) {
      _mediator.getMediatorData().setAdminRole();
      Get.snackbar('Berhasil', 'Anda masuk sebagai Admin');
      _mediator.notify(goToCatalog);
    }
  }

  String? _validateName(String? value) {
    if (value == null || value.isEmpty) return 'Nama tidak boleh kosong';
    if (value.length < 3) return 'Nama terlalu pendek';
    if (value.length > 30) return 'Nama terlalu panjang';
    if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(value)) return 'Nama hanya boleh huruf';
    return null;
  }

  String? _validateAddress(String? value) {
    if (value == null || value.isEmpty) return 'Alamat tidak boleh kosong';
    if (value.length < 10) return 'Alamat terlalu pendek';
    if (value.length > 255) return 'Alamat terlalu panjang';
    return null;
  }

  void _saveUserData() {
    if (!_key.currentState!.validate()) return;
    final userData = {'name': _name.text, 'address': _address.text};
    _mediator.getMediatorData().setUser(userData);
    _mediator.notify(goToCatalog);
  }
}
