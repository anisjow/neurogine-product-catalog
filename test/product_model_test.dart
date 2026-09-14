import 'package:flutter_test/flutter_test.dart';
import 'package:neurogine_product_catalog/data/models/product.dart';

void main() {
  // ─── Sample JSON that mirrors the real DummyJSON API response ───────────────
  final Map<String, dynamic> sampleJson = {
    'id': 1,
    'title': 'Essence Mascara Lash Princess',
    'description': 'A popular mascara for dramatic lashes.',
    'price': 9.99,
    'rating': 4.94,
    'thumbnail': 'https://cdn.dummyjson.com/products/images/beauty/1/thumbnail.png',
    'images': [
      'https://cdn.dummyjson.com/products/images/beauty/1/1.png',
      'https://cdn.dummyjson.com/products/images/beauty/1/2.png',
    ],
  };

  group('Product.fromJson', () {
    // ── 1. Happy path ──────────────────────────────────────────────────────────
    test('parses all fields correctly from a valid JSON map', () {
      final product = Product.fromJson(sampleJson);

      expect(product.id, 1);
      expect(product.title, 'Essence Mascara Lash Princess');
      expect(product.description, 'A popular mascara for dramatic lashes.');
      expect(product.price, 9.99);
      expect(product.rating, 4.94);
      expect(product.thumbnail,
          'https://cdn.dummyjson.com/products/images/beauty/1/thumbnail.png');
      expect(product.images, [
        'https://cdn.dummyjson.com/products/images/beauty/1/1.png',
        'https://cdn.dummyjson.com/products/images/beauty/1/2.png',
      ]);
    });

    // ── 2. price arrives as int from the API (e.g. 10 instead of 10.0) ────────
    test('converts price from int JSON value to double', () {
      final json = Map<String, dynamic>.from(sampleJson);
      json['price'] = 10; // int, not double

      final product = Product.fromJson(json);

      expect(product.price, isA<double>());
      expect(product.price, 10.0);
    });

    // ── 3. rating arrives as int ───────────────────────────────────────────────
    test('converts rating from int JSON value to double', () {
      final json = Map<String, dynamic>.from(sampleJson);
      json['rating'] = 5; // int, not double

      final product = Product.fromJson(json);

      expect(product.rating, isA<double>());
      expect(product.rating, 5.0);
    });

    // ── 4. images list can be empty ────────────────────────────────────────────
    test('parses an empty images list without error', () {
      final json = Map<String, dynamic>.from(sampleJson);
      json['images'] = <String>[];

      final product = Product.fromJson(json);

      expect(product.images, isEmpty);
    });

    // ── 5. images list with a single item ─────────────────────────────────────
    test('parses a single-item images list correctly', () {
      final json = Map<String, dynamic>.from(sampleJson);
      json['images'] = ['https://example.com/image.png'];

      final product = Product.fromJson(json);

      expect(product.images.length, 1);
      expect(product.images.first, 'https://example.com/image.png');
    });

    // ── 6. Fields retain correct types ────────────────────────────────────────
    test('id is an int, price and rating are doubles, images is List<String>', () {
      final product = Product.fromJson(sampleJson);

      expect(product.id, isA<int>());
      expect(product.price, isA<double>());
      expect(product.rating, isA<double>());
      expect(product.images, isA<List<String>>());
    });
  });
}
