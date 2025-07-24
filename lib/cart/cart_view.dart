part of 'cart_controller.dart';

class _CartView extends StatelessWidget {
  final CartController controller;

  const _CartView(this.controller);

  Widget paymentDialog() {
    return PopScope(
      canPop: false,
      child: AlertDialog(
        title: Center(child: Text('Pembayaran')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Silakan transfer ke:'),
            SizedBox(height: 8),
            Text(
              '${controller._paymentInfo['bank_name']} - ${controller._paymentInfo['account_holder_name']}',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Row(
              children: [
                Expanded(
                  child: SelectableText('${controller._paymentInfo['bank_account_number']}', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                IconButton(
                  icon: Icon(Icons.copy),
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: controller._paymentInfo['bank_account_number'] ?? ''));
                    Get.snackbar('Disalin', 'Nomor rekening disalin');
                  },
                ),
              ],
            ),
            SizedBox(height: 4),
            Row(
              children: [
                Expanded(
                  child: SelectableText(
                    'Total: Rp ${controller._formatPrice(controller._totalPrice.value)}',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.copy),
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: controller._formatPrice(controller._totalPrice.value)));
                    Get.snackbar('Disalin', 'Total harga disalin');
                  },
                ),
              ],
            ),
            SizedBox(height: 12),
            Center(child: Text('Setelah membayar, hubungi admin:')),
            SizedBox(height: 8),
            Center(
              child: ElevatedButton.icon(
                onPressed: controller._contactWhatsapp,
                icon: Icon(Icons.chat),
                label: Text('Hubungi Admin via WhatsApp'),
              ),
            ),
          ],
        ),
        actions: [TextButton(onPressed: controller._askClosePayment, child: Text('Tutup'))],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Daftar Keranjang'),
        backgroundColor: Colors.blue.shade600,
        leading: IconButton(icon: Icon(Icons.arrow_back), onPressed: controller._navigateBackToCatalog),
      ),
      body: Obx(() {
        final chart = controller._carts;

        if (chart.isEmpty) return Center(child: Text('Keranjang kosong'));

        return Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: chart.length,
                itemBuilder: (_, i) {
                  _CartModel item = chart[i];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Image.network(item.thumbnail, width: 60, height: 60, fit: BoxFit.cover),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(item.name, style: TextStyle(fontWeight: FontWeight.bold)),
                                const SizedBox(height: 2),
                                Text(item.description, maxLines: 2, overflow: TextOverflow.ellipsis),
                                const SizedBox(height: 4),
                                Text('Rp ${controller._formatPrice(item.price)}', style: TextStyle(color: Colors.green.shade700)),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    IconButton(icon: Icon(Icons.remove_circle_outline), onPressed: () => controller._decreaseQuantity(i)),
                                    Text('${item.quantity}', style: TextStyle(fontSize: 16)),
                                    IconButton(icon: Icon(Icons.add_circle_outline), onPressed: () => controller._increaseQuantity(i)),
                                    const Spacer(),
                                    IconButton(
                                      icon: Icon(Icons.delete, color: Colors.redAccent),
                                      onPressed: () => controller._removeItem(i),
                                    ),
                                  ],
                                ),
                                Align(
                                  alignment: Alignment.bottomRight,
                                  child: Text(
                                    'Total: Rp ${controller._formatPrice(item.price * item.quantity)}',
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Obx(
                    () => Text(
                      'Total Semua: Rp ${controller._formatPrice(controller._totalPrice.value)}',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  SizedBox(height: 8),
                  ElevatedButton(
                    child: Text('Bayar Sekarang'),
                    onPressed: () async {
                      await controller._getUserData();
                      await controller._getDataPaymentInfo();
                      Get.dialog(paymentDialog(), barrierDismissible: false);
                    },
                  ),
                ],
              ),
            ),
          ],
        );
      }),
    );
  }
}
