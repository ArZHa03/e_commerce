part of 'catalog_controller.dart';

class _CatalogDetailView extends StatelessWidget {
  final CatalogController _controller;
  const _CatalogDetailView(this._controller);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_controller._catalogSelected.value?.name ?? ''),
        backgroundColor: Colors.blue.shade600,
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: _controller._navigateBackToCatalog),
        actions: [IconButton(icon: const Icon(Icons.shopping_cart_checkout_rounded), onPressed: _controller._navigateToCart)],
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FlutterCarousel(
              items:
                  _controller._catalogSelected.value?.imagesUrl
                      .map(
                        (item) => Image.network(
                          item,
                          errorBuilder: (context, error, stackTrace) => Icon(Icons.broken_image, size: 64),
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Center(child: CircularProgressIndicator());
                          },
                        ),
                      )
                      .toList(),
              options: FlutterCarouselOptions(
                height: 70.hp,
                enableInfiniteScroll: true,
                autoPlay: true,
                autoPlayInterval: const Duration(seconds: 7),
                enlargeCenterPage: true,
                viewportFraction: 1,
                slideIndicator: CircularSlideIndicator(
                  slideIndicatorOptions: const SlideIndicatorOptions(
                    indicatorBackgroundColor: Colors.white,
                    indicatorBorderColor: Colors.blue,
                    indicatorBorderWidth: 1.5,
                    currentIndicatorColor: Colors.blue,
                  ),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                _controller._catalogSelected.value?.name ?? '',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, fontSize: 20),
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
              child: Text(
                "Rp ${_controller._formatPrice(_controller._catalogSelected.value?.price ?? 0)}",
                style: Theme.of(context).textTheme.labelLarge?.copyWith(color: Colors.green.shade700),
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4),
              child: Text(
                _controller._catalogSelected.value?.description ?? '',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey.shade700, height: 1.4),
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16),
              child: Row(
                children: [
                  const Text("Quantity:", style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(width: 16),
                  _quantitySelector(),
                ],
              ),
            ),

            const SizedBox(height: 80),
          ],
        ),
      ),

      bottomNavigationBar: Container(
        color: Colors.blueAccent.withAlpha(7),
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        child: ElevatedButton.icon(
          icon: const Icon(Icons.shopping_cart_outlined),
          label: const Text("+ Keranjang"),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green.shade700,
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 48),
          ),
          onPressed: _controller._addCatalogToCart,
        ),
      ),
    );
  }

  Row _quantitySelector() {
    return Row(
      children: [
        Obx(
          () => IconButton(
            icon: const Icon(Icons.remove_circle_outline),
            onPressed: _controller._quantity.value > 1 ? () => _controller._quantity.value-- : null,
          ),
        ),
        Obx(() => Text(_controller._quantity.toString(), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold))),
        IconButton(icon: const Icon(Icons.add_circle_outline), onPressed: () => _controller._quantity.value++),
      ],
    );
  }
}
