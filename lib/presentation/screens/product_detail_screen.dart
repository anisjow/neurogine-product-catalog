import 'package:flutter/material.dart';
import '../../data/models/product.dart';
import '../../data/services/product_api.dart';

// 1. Changed from StatelessWidget to StatefulWidget
class ProductDetailScreen extends StatefulWidget {
  final Product product; // 2. Kept the existing product parameter

  const ProductDetailScreen({
    super.key,
    required this.product,
  });

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  final ProductApiService _apiService = ProductApiService();

  // 3. Three state variables to track loading / error / fetched data
  bool _isLoading = true;
  String? _errorMessage;
  Product? _fetchedProduct;

  @override
  void initState() {
    super.initState();
    // 4. Call getProductById when the screen first opens
    _loadProduct();
  }

  Future<void> _loadProduct() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final product = await _apiService.getProductById(widget.product.id);
      setState(() {
        _fetchedProduct = product;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load product details';
        _isLoading = false;
      });
    }
  }

  // Builds a row of up to 5 star icons based on a 0–5 rating value
  Widget _buildStarRating(double rating) {
    const int maxStars = 5;
    final int fullStars = rating.floor();
    final bool hasHalf = (rating - fullStars) >= 0.5;

    return Row(
      children: [
        for (int i = 0; i < maxStars; i++)
          Icon(
            i < fullStars
                ? Icons.star
                : (i == fullStars && hasHalf)
                    ? Icons.star_half
                    : Icons.star_border,
            color: Colors.amber,
            size: 22,
          ),
        const SizedBox(width: 6),
        Text(
          rating.toStringAsFixed(1),
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // Use fetched product if available, otherwise fall back to the passed product
    final product = _fetchedProduct ?? widget.product;

    return Scaffold(
      appBar: AppBar(
        title: Text(product.title),
      ),
      // 5. Show loading spinner while the API request is in progress
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          // 6. Show error message if the request failed
          : _errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline,
                          size: 48, color: Colors.red),
                      const SizedBox(height: 12),
                      Text(_errorMessage!),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: _loadProduct,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              // 7. Show the existing detail UI with the fetched product data
              : Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 8. Existing horizontal image list — unchanged
                      SizedBox(
                        height: 250,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: product.images.length,
                          itemBuilder: (context, index) {
                            final imageWidget = Image.network(
                              product.images[index],
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) {
                                return const Icon(
                                  Icons.image_not_supported,
                                  size: 100,
                                );
                              },
                            );

                            return SizedBox(
                              width: 350,
                              // Hero on the first image only — matches the list thumbnail tag
                              child: index == 0
                                  ? Hero(
                                      tag: 'product-thumbnail-${product.id}',
                                      child: imageWidget,
                                    )
                                  : imageWidget,
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        product.title,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '\$${product.price}',
                        style: const TextStyle(fontSize: 20),
                      ),
                      const SizedBox(height: 8),
                      _buildStarRating(product.rating),
                      const SizedBox(height: 16),
                      Text(product.description),
                    ],
                  ),
                ),
    );
  }
}