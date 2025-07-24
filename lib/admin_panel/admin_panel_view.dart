part of 'admin_panel_controller.dart';

class _AdminPanelView extends StatelessWidget {
  final AdminPanelController _controller;

  const _AdminPanelView(this._controller);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: const Text('Admin Panel'),
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: _controller._navigateBackToSetting),
        actions: [
          IconButton(
            icon: const Icon(Icons.admin_panel_settings_rounded),
            color: Colors.white,
            tooltip: 'Validasi Password Admin',
            onPressed: () async {
              await _controller._initValuesValidationPasswordsAdmin();
              Get.dialog(validationPasswordAdminDialog());
            },
          ),
          IconButton(
            icon: const Icon(Icons.payment_rounded),
            color: Colors.white,
            tooltip: 'Info Pembayaran',
            onPressed: () async {
              await _controller._initValuesInfoPaymentForm();
              Get.dialog(infoPaymentDialog());
            },
          ),
          IconButton(
            icon: const Icon(Icons.post_add_rounded),
            color: Colors.white,
            tooltip: 'Tambah Katalog',
            onPressed: () {
              _controller._defaultValuesCatalogForm();
              Get.dialog(catalogFormDialog());
            },
          ),
        ],
      ),
      body: Obx(() {
        final catalogs = _controller.catalogs;

        if (_controller._isLoadingFetchCatalogs.value) return const Center(child: CircularProgressIndicator());
        if (catalogs.isEmpty) return const Center(child: Text('Belum ada katalog'));

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: catalogs.length,
          itemBuilder: (_, index) {
            final item = catalogs[index];
            return Card(
              elevation: 2,
              margin: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  SizedBox(
                    width: 100,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.network(
                        item.thumbnail,
                        errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image, size: 80),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ListTile(
                      title: Text(item.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      subtitle: Text(item.description, maxLines: 3, overflow: TextOverflow.ellipsis),
                      trailing: SizedBox(
                        width: 150.w,
                        child: Text(
                          'Rp ${_controller._formatPrice(item.price)}',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          softWrap: true,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
                  Column(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () {
                          _controller._name.text = item.name;
                          _controller._description.text = item.description;
                          _controller._price.text = item.price.toString();
                          _controller._selectedImages.value = item.imagesUrl.map((url) => XFile(url)).toList();
                          Get.dialog(catalogFormDialog(catalog: item));
                        },
                      ),
                      IconButton(icon: const Icon(Icons.delete), onPressed: () => _controller._deleteCatalog(item)),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      }),
    );
  }

  Widget catalogFormDialog({_CatalogModel? catalog}) {
    return Center(
      child: AlertDialog(
        title: Center(child: Text('${catalog != null ? 'Perbarui' : 'Tambah'} Katalog')),
        content: SingleChildScrollView(
          child: SizedBox(
            width: 100.wp,
            child: Column(
              children: [
                TextField(
                  decoration: const InputDecoration(labelText: 'Nama Produk', border: OutlineInputBorder()),
                  controller: _controller._name,
                ),
                const SizedBox(height: 12),
                TextField(
                  decoration: const InputDecoration(labelText: 'Deskripsi', border: OutlineInputBorder()),
                  controller: _controller._description,
                  maxLines: 13,
                ),
                const SizedBox(height: 12),
                TextField(
                  decoration: const InputDecoration(labelText: 'Harga (dalam IDR)', border: OutlineInputBorder(), prefixText: 'Rp '),
                  controller: _controller._price,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    CurrencyTextInputFormatter.currency(locale: 'id', decimalDigits: 0, symbol: '', enableNegative: false),
                  ],
                ),
                const SizedBox(height: 24),
                Obx(
                  () => Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children:
                        _controller._selectedImages.isEmpty
                            ? [const Text('Tidak ada gambar yang dipilih')]
                            : _controller._selectedImages.map((image) {
                              return Stack(
                                children: [
                                  Image.network(image.path, width: 100, height: 100, fit: BoxFit.cover),
                                  Positioned(
                                    right: 0,
                                    top: 0,
                                    child: IconButton(
                                      icon: const Icon(Icons.close, color: Colors.red),
                                      onPressed: () => _controller._removeImage(image),
                                    ),
                                  ),
                                ],
                              );
                            }).toList(),
                  ),
                ),
                const SizedBox(height: 12),
                Obx(
                  () => ElevatedButton(
                    onPressed: _controller._selectImage,
                    style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12)),
                    child: _controller._isLoadingImages.value ? const CircularProgressIndicator() : const Text('Tambah Gambar'),
                  ),
                ),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerLeft,
                  child: const Text(
                    'Note:\n• Maksimal 7 gambar. \n• Ukuran maksimal 10 MB per gambar. \n• Gambar pertama akan menjadi thumbnail.',
                    style: TextStyle(fontSize: 14, color: Colors.blueGrey),
                  ),
                ),
              ],
            ),
          ),
        ),
        actionsAlignment: MainAxisAlignment.spaceBetween,
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () => catalog != null ? _controller._updateCatalog(catalog) : _controller._addCatalog(),
            child: Text(catalog != null ? 'Perbarui' : 'Tambah'),
          ),
        ],
      ),
    );
  }

  Widget infoPaymentDialog() {
    return Center(
      child: AlertDialog(
        title: Center(child: const Text('Info Pembayaran')),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: _controller._bankName, decoration: const InputDecoration(labelText: 'Bank Name')),
              TextField(controller: _controller._accountHolderName, decoration: const InputDecoration(labelText: 'Account Holder Name')),
              TextField(
                controller: _controller._bankAccountNumber,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Bank Account Number'),
              ),
              TextField(
                controller: _controller._whatsappNumber,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(labelText: 'WhatsApp Number'),
              ),
            ],
          ),
        ),
        actionsAlignment: MainAxisAlignment.spaceBetween,
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Batal')),
          ElevatedButton(onPressed: _controller._saveInfoPayment, child: const Text('Simpan')),
        ],
      ),
    );
  }

  Widget validationPasswordAdminDialog() {
    return Center(
      child: AlertDialog(
        title: const Text('Daftar Validasi Password Admin'),
        content: SingleChildScrollView(
          child: Obx(
            () => Column(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(_controller._validationPasswordsAdmin.length, (i) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _controller._validationPasswordsAdmin[i],
                          decoration: InputDecoration(labelText: 'Password ${i + 1}', border: const OutlineInputBorder()),
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (_controller._validationPasswordsAdmin.length > 1)
                        IconButton(
                          onPressed: () => _controller._removeValidationPassword(i),
                          icon: const Icon(Icons.delete, color: Colors.red),
                        ),
                    ],
                  ),
                );
              }),
            ),
          ),
        ),
        actionsAlignment: MainAxisAlignment.spaceBetween,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_moderator_rounded, color: Colors.blue),
            onPressed: _controller._addValidationPassword,
            tooltip: 'Tambah Password',
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextButton(onPressed: () => Get.back(), child: const Text('Batal')),
              SizedBox(width: 8),
              ElevatedButton(onPressed: _controller._saveValidationPasswordsAdmin, child: const Text('Simpan')),
            ],
          ),
        ],
      ),
    );
  }
}
