part of 'cart_controller.dart';

class _CartService {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  Future<Map<String, dynamic>> fetchPaymentInfo() async {
    try {
      final snapshot = await firestore.collection('database').doc('payment').get();
      return snapshot.data()?['data'] ?? {};
    } catch (e) {
      return {};
    }
  }
}
