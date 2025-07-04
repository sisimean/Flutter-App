// cart_provider.dart
import 'package:flutter/material.dart';
import '../Model/cart.dart';
import '../Model/product.dart';

class CartProvider with ChangeNotifier {
  final List<CartItem> _items = [];

  List<CartItem> get items => _items;

  void addToCart(Product product, int quantity, int customerId) {
    final existingIndex = _items.indexWhere(
      (item) => item.product.id == product.id,
    );

    if (existingIndex >= 0) {
      // Item already exists in cart - update quantity
      _items[existingIndex] = CartItem(
        product: product,
        quantity: _items[existingIndex].quantity + quantity,
        customerId: customerId,
      );
    } else {
      // New item - add to cart
      _items.add(
        CartItem(product: product, quantity: quantity, customerId: customerId),
      );
    }
    notifyListeners();
  }

  void increaseQuantity(int productId) {
    final index = _items.indexWhere((item) => item.product.id == productId);
    if (index >= 0) {
      _items[index] = CartItem(
        product: _items[index].product,
        quantity: _items[index].quantity + 1,
        customerId: _items[index].customerId,
      );
      notifyListeners();
    }
  }

  void decreaseQuantity(int productId) {
    final index = _items.indexWhere((item) => item.product.id == productId);
    if (index >= 0) {
      if (_items[index].quantity > 1) {
        _items[index] = CartItem(
          product: _items[index].product,
          quantity: _items[index].quantity - 1,
          customerId: _items[index].customerId,
        );
      } else {
        _items.removeAt(index);
      }
      notifyListeners();
    }
  }

  void removeItem(int productId) {
    _items.removeWhere((item) => item.product.id == productId);
    notifyListeners();
  }

  void clearCart() {
    _items.clear();
    notifyListeners();
  }

  double get totalAmount {
    return _items.fold(
      0,
      (sum, item) => sum + (item.product.price * item.quantity),
    );
  }

  // Helper method to get quantity of a specific product
  int getProductQuantity(int productId) {
    final index = _items.indexWhere((item) => item.product.id == productId);
    return index >= 0 ? _items[index].quantity : 0;
  }
}
