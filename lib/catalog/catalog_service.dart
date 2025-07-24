part of 'catalog_controller.dart';

class _CatalogService {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future<List<Map<String, dynamic>>> fetchCatalogs() async {
    try {
      final snapshot = await firestore.collection('catalogs').get();

      if (snapshot.docs.isEmpty) {
        if (kDebugMode) Get.snackbar('Info', 'No catalogs found');
        return [];
      }
      final catalogs = snapshot.docs.map((doc) => doc.data()).toList();

      return catalogs;
    } catch (e) {
      if (kDebugMode) Get.snackbar('Error', 'Failed to fetch catalogs: $e');
      if (kReleaseMode) Get.snackbar('Error', 'Failed to fetch catalogs');
      return [];
    }
  }
}
