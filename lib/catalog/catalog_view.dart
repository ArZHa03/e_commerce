part of 'catalog_controller.dart';

class _CatalogView extends StatelessWidget {
  final CatalogController _controller;

  const _CatalogView(this._controller);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Catalog"),
        backgroundColor: Colors.blue.shade600,
        actions: [
          IconButton(icon: const Icon(Icons.shopping_cart_checkout_rounded), onPressed: _controller._navigateToCart),
          IconButton(icon: const Icon(Icons.settings_rounded), onPressed: _controller._navigateToSettings),
        ],
      ),
      backgroundColor: Colors.white,
      body: Obx(() {
        final products = _controller._catalogs;

        if (_controller._isLoading.value) return const Center(child: CircularProgressIndicator());
        if (products.isEmpty) return const Center(child: Text("Belum ada produk."));

        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: products.length,
          itemBuilder: (context, index) {
            final product = products[index];
            return GestureDetector(
              onTap: () => _controller._navigateToDetail(product),
              child: Card(
                margin: const EdgeInsets.only(bottom: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 3,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(
                          product.thumbnail,
                          width: 120,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image, size: 120, color: Colors.grey),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(product.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 4),
                            Text(
                              "Rp ${_controller._formatPrice(product.price)}",
                              style: TextStyle(color: Colors.green.shade700, fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              product.description,
                              style: const TextStyle(fontSize: 13, color: Colors.black87),
                              maxLines: 7,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      }),
    );
  }
}
