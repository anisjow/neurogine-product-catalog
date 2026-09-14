import 'package:flutter/material.dart';
import '../../data/models/product.dart';
import '../../data/services/product_api.dart';
import 'product_detail_screen.dart';
import 'dart:async';

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  final ProductApiService _apiService = ProductApiService();

  List<Product> _products = [];
  bool _isLoading = true;
  String? _errorMessage;

  bool _isLoadingMore = false;
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _loadProducts();

    _scrollController.addListener(() {
      if (_searchController.text.isEmpty &&
          _scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 200) {
        _loadMoreProducts();
      }
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _searchProducts(String query) async {
    if (query.isEmpty) {
      _loadProducts();
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final products = await _apiService.searchProducts(query);

      setState(() {
        _products = products;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to search products';
        _isLoading = false;
      });
    }
  }

  Future<void> _loadMoreProducts() async {
    if (_isLoadingMore) return;

    setState(() {
      _isLoadingMore = true;
    });

    try {
      final newProducts = await _apiService.getProducts(skip: _products.length);

      setState(() {
        _products.addAll(newProducts);
        _isLoadingMore = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingMore = false;
      });
      // Show a SnackBar so the user knows load-more failed silently
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to load more products. Pull to refresh.'),
            duration: Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Future<void> _loadProducts() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _products = [];
    });

    try {
      final products = await _apiService.getProducts();

      setState(() {
        _products = products;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load products';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Product Catalog')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'Search products...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                if (_debounce?.isActive ?? false) {
                  _debounce!.cancel();
                }

                _debounce = Timer(const Duration(milliseconds: 500), () {
                  _searchProducts(value);
                });
              },
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _loadProducts,
              child: _buildBody(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      // Wrapped in a scrollable so RefreshIndicator gesture still works on error
      return LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: SizedBox(
              height: constraints.maxHeight,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 48, color: Colors.red),
                    const SizedBox(height: 12),
                    Text(_errorMessage!),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: _loadProducts,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );
    }

    if (_products.isEmpty) {
      // Wrapped in a scrollable so RefreshIndicator gesture still works when empty
      return LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: SizedBox(
              height: constraints.maxHeight,
              child: const Center(child: Text('No products found')),
            ),
          );
        },
      );
    }

    return ListView.builder(
      itemCount: _products.length + (_isLoadingMore ? 1 : 0),
      controller: _scrollController,
      physics: const AlwaysScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        // Last item → show pagination loading indicator
        if (index == _products.length) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final product = _products[index];

        return ListTile(
          leading: Hero(
            // Hero tag must be unique per item — product.id guarantees that
            tag: 'product-thumbnail-${product.id}',
            child: Image.network(
              product.thumbnail,
              width: 60,
              height: 60,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(Icons.image_not_supported);
              },
            ),
          ),
          title: Text(product.title),
          subtitle: Text('\$${product.price}'),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ProductDetailScreen(product: product),
              ),
            );
          },
        );
      },
    );
  }
}
