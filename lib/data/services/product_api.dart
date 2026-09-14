import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/product.dart';

class ProductApiService {
  Future<List<Product>> getProducts({int limit = 20, int skip = 0}) async {
    final response = await http.get(
      Uri.parse('https://dummyjson.com/products?limit=$limit&skip=$skip'),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final products = data['products'] as List;

      return products.map((json) => Product.fromJson(json)).toList();
    }

    throw Exception('Failed to load products');
  }

  Future<List<Product>> searchProducts(String query) async {
    final response = await http.get(
      Uri.parse('https://dummyjson.com/products/search?q=$query'),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final products = data['products'] as List;

      return products.map((json) => Product.fromJson(json)).toList();
    }

    throw Exception('Failed to search products');
  }
  Future<Product> getProductById(int id) async {
  final response = await http.get(
    Uri.parse(
      'https://dummyjson.com/products/$id',
    ),
  );

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    return Product.fromJson(data);
  }

  throw Exception('Failed to load product');
}
}
