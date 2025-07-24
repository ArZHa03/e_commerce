part of 'setting_controller.dart';

class _SettingService {
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future<List<String>> fetchAdminValidations() async {
    try {
      final snapshot = await firestore.collection('database').doc('validations').get();
      return List<String>.from(snapshot.data()?['data'] ?? []);
    } catch (e) {
      if (kDebugMode) Get.snackbar('Error', 'Failed to fetch admin validations: $e');
      if (kReleaseMode) Get.snackbar('Error', 'Failed to fetch admin validations');
      return [];
    }
  }
}
