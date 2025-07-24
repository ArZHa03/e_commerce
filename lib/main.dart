import 'package:firebase_core/firebase_core.dart' show Firebase;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lite_storage/lite_storage.dart' show LiteStorage;
import 'package:simple_responsive/simple_responsive.dart';

import 'firebase_options.dart';
import 'mediator/mediator.dart';

void main() async {
  await LiteStorage.init();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(_ECommerceApp());
}

class _ECommerceApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SimpleResponsive.init(context);
    return GetMaterialApp(
      title: 'E-Commerce App',
      initialRoute: Mediator.initialRoute,
      getPages: Mediator.routes,
      unknownRoute: Mediator.unknownRoute,
      debugShowCheckedModeBanner: false,
    );
  }
}
