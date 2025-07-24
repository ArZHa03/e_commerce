import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '/admin_panel/admin_panel_controller.dart';
import '/catalog/catalog_controller.dart';
import '/setting/setting_controller.dart';
import '../cart/cart_controller.dart';
import '../onboarding/onboarding_controller.dart';
import 'i_mediator.dart';
import 'mediator_data.dart';

class Mediator implements IMediator {
  Mediator._();

  static final Mediator _instance = Mediator._();

  factory Mediator() => _instance;

  static OnBoardingController? _onBoardingController;
  static CatalogController? _catalogController;
  static SettingController? _settingController;
  static AdminPanelController? _catalogPanelController;
  static CartController? _cartController;

  @override
  MediatorData getMediatorData() => MediatorData();

  @override
  Future<void> notify(String event) async {
    if (event == OnBoardingController.goToCatalog) return await Get.offAllNamed(_catalog);
    if (event == CatalogController.goToDetail) return await Get.toNamed(_catalogDetail);
    if (event == CatalogController.backToCatalog) return await Get.offNamed(_catalog);
    if (event == CatalogController.gotoCart) return await Get.toNamed(_cart);
    if (event == CatalogController.gotoSettings) return await Get.toNamed(_setting);
    if (event == SettingController.goToCatalogPanel) return await Get.toNamed(_panel);
    if (event == SettingController.backToCatalog) return await Get.offNamed(_catalog);
    if (event == AdminPanelController.goToUnknownRoute) return await Get.offAllNamed(_notFound);
    if (event == AdminPanelController.backToSetting) return await Get.offNamed(_setting);
    return;
  }

  static OnBoardingController _createOnBoardingController() => _onBoardingController ??= OnBoardingController(_instance);
  static CatalogController _createCatalogController() => _catalogController ??= CatalogController(_instance);
  static SettingController _createSettingController() => _settingController ??= SettingController(_instance);
  static AdminPanelController _createCatalogPanelController() => _catalogPanelController ??= AdminPanelController(_instance);
  static CartController _createCartController() => _cartController ??= CartController(_instance);

  static const _onBoarding = '/onboarding';
  static const _catalog = '/catalog';
  static const _catalogDetail = '/catalog/detail';
  static const _setting = '/setting';
  static const _panel = '/panel';
  static const _notFound = '/not-found';
  static const _cart = '/cart';

  static final routes = [
    GetPage(name: _onBoarding, page: () => _createOnBoardingController().build()),
    GetPage(name: _catalog, page: () => _createCatalogController().build()),
    GetPage(name: _setting, page: () => _createSettingController().build()),
    GetPage(name: _panel, page: () => _createCatalogPanelController().build()),
    GetPage(name: _catalogDetail, page: () => _createCatalogController().detailBuild()),
    GetPage(name: _cart, page: () => _createCartController().build()),
  ];

  static final unknownRoute = GetPage(name: _notFound, page: () => Scaffold(body: Center(child: Text('Halaman tidak ditemukan'))));

  static const String initialRoute = _onBoarding;
}
