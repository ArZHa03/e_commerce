part of 'admin_panel_controller.dart';

class _AdminPanelService {
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
      return [];
    }
  }

  Future<Map<String, dynamic>> createCatalog(Map<String, dynamic> catalogData) async {
    try {
      final docRef = await firestore.collection('catalogs').add(catalogData);

      final docId = docRef.id;
      await docRef.update({'id': docId});

      final catalog = await docRef.get();
      return catalog.data()!;
    } catch (e) {
      return {};
    }
  }

  Future<Map<String, dynamic>> updateCatalog(String catalogId, Map<String, dynamic> catalogData) async {
    try {
      final docRef = firestore.collection('catalogs').doc(catalogId);
      await docRef.update(catalogData);

      final updatedCatalog = await docRef.get();
      return updatedCatalog.data()!;
    } catch (e) {
      return {};
    }
  }

  Future<bool> deleteCatalog(String catalogId) async {
    try {
      await firestore.collection('catalogs').doc(catalogId).delete();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<List<String>> uploadMultipleImages(List<XFile> images) async {
    if (images.isEmpty) return [];

    final cloudinary = CloudinaryPublic('deqdgzmwr', 'e-commerce', cache: true);

    final uploads =
        images.map((image) async {
          final response = await cloudinary.uploadFile(CloudinaryFile.fromFile(image.path, resourceType: CloudinaryResourceType.Image));
          return response.secureUrl;
        }).toList();

    final results = await Future.wait(uploads);
    return results.whereType<String>().toList();
  }

  Future<Map<String, dynamic>> fetchInfoPayment() async {
    try {
      final snapshot = await firestore.collection('database').doc('payment').get();
      return snapshot.data()?['data'] ?? {};
    } catch (e) {
      return {};
    }
  }

  Future<bool> updateInfoPayment(Map<String, dynamic> paymentData) async {
    try {
      await firestore.collection('database').doc('payment').update({'data': paymentData});
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<List<String>> fetchValidationPasswordsAdmin() async {
    try {
      final snapshot = await firestore.collection('database').doc('validations').get();
      return List<String>.from(snapshot.data()?['data'] ?? []);
    } catch (e) {
      return [];
    }
  }

  Future<bool> updateValidationPasswordsAdmin(List<String> passwords) async {
    try {
      await firestore.collection('database').doc('validations').update({'data': passwords});
      return true;
    } catch (e) {
      return false;
    }
  }
}
