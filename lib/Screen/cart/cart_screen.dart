import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../Model/cart.dart';
import '../../providers/cart_provider.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final Set<int> _selectedIndices = {};
  final Map<String, bool> _expandedCategories = {};

  void _showSuccessAnimation() {
    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierLabel: 'Success',
      transitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (_, __, ___) => const SizedBox.shrink(),
      transitionBuilder: (_, animation, __, ___) {
        return Center(
          child: AnimatedBuilder(
            animation: animation,
            builder: (_, __) {
              return Opacity(
                opacity: animation.value,
                child: Transform.scale(
                  scale: animation.value,
                  child: AlertDialog(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 30,
                    ),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.check_circle,
                          color: Colors.green,
                          size: 80,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Checkout Successful!',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Your order has been successfully placed.',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor:  Colors.green.shade800,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: () => Navigator.pop(context),
                          child: const Text('OK'),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  void _confirmDeleteItem(BuildContext context, int index, int productId) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Remove Item'),
            content: const Text(
              'Are you sure you want to remove this item from the cart?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  final cart = Provider.of<CartProvider>(
                    context,
                    listen: false,
                  );
                  setState(() {
                    cart.removeItem(productId);
                    _selectedIndices.remove(index);
                  });
                  Navigator.pop(context);
                },
                child: const Text('OK', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
    );
  }

  Map<String, List<int>> _groupCartItemsByCategory(List<CartItem> items) {
    Map<String, List<int>> grouped = {};
    for (int i = 0; i < items.length; i++) {
      final name = items[i].product.name;
      String category = 'Others';
      if (name.contains("iPhone") ||
          name.contains("Samsung") ||
          name.contains("Xiaomi") ||
          name.contains("Google") ||
          name.contains("Sony") ||
          name.contains("Oppo") ||
          name.contains("Realme") ||
          name.contains("ASUS")) {
        category = 'Phone';
      } else if (name.contains("iPad")) {
        category = 'IPad';
      } else if (name.contains("MacBook") ||
          name.contains("Lenovo") ||
          name.contains("Dell") ||
          name.contains("HP")) {
        category = 'Laptop';
      } else if (name.contains("iMac")) {
        category = 'Desktop';
      }

      grouped.putIfAbsent(category, () => []);
      grouped[category]!.add(i);
    }
    return grouped;
  }

  String _getCategoryIcon(String category) {
    switch (category) {
      case 'Phone':
        return '📱';
      case 'IPad':
        return '📲';
      case 'Laptop':
        return '💻';
      case 'Desktop':
        return '🖥️';
      default:
        return '📦';
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);
    final selectedTotal = _selectedIndices.fold<double>(
      0,
      (sum, index) => sum + cart.items[index].totalPrice,
    );
    final groupedItems = _groupCartItemsByCategory(cart.items);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.white,
        backgroundColor:  Colors.brown.shade800,
        title: const Text('Your Cart'),
        actions: [
          if (_selectedIndices.isNotEmpty)
            TextButton(
              onPressed: () => setState(() => _selectedIndices.clear()),
              child: const Text(
                'Clear Selection',
                style: TextStyle(color: Colors.white),
              ),
            ),
          IconButton(
            icon: const Icon(Icons.delete_sweep, color: Colors.white),
            onPressed: () {
              showDialog(
                context: context,
                builder:
                    (context) => AlertDialog(
                      title: const Text('Clear Cart'),
                      content: const Text(
                        'Are you sure you want to clear your cart?',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () {
                            cart.clearCart();
                            setState(() {
                              _selectedIndices.clear();
                              _expandedCategories.clear();
                            });
                            Navigator.pop(context);
                          },
                          child: const Text(
                            'Clear',
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
                    ),
              );
            },
          ),
        ],
      ),
      body:
          cart.items.isEmpty
              ? const Center(child: Text('Your cart is empty'))
              : ListView.builder(
                itemCount: groupedItems.length,
                itemBuilder: (context, groupIndex) {
                  String category = groupedItems.keys.elementAt(groupIndex);
                  List<int> itemIndices = groupedItems[category]!;
                  final isExpanded = _expandedCategories[category] ?? true;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ListTile(
                        tileColor:
                            isDark ? Colors.grey[800] : Colors.grey.shade300,
                        title: Text(
                          '${_getCategoryIcon(category)} $category (${itemIndices.length})',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        trailing: IconButton(
                          icon: Icon(
                            isExpanded ? Icons.expand_less : Icons.expand_more,
                          ),
                          onPressed: () {
                            setState(() {
                              _expandedCategories[category] = !isExpanded;
                            });
                          },
                        ),
                      ),
                      if (isExpanded)
                        ...itemIndices.map((index) {
                          final item = cart.items[index];
                          final isSelected = _selectedIndices.contains(index);
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                if (isSelected) {
                                  _selectedIndices.remove(index);
                                } else {
                                  _selectedIndices.add(index);
                                }
                              });
                            },
                            child: Card(
                              margin: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              color:
                                  isSelected
                                      ? Colors.deepPurple.withOpacity(0.2)
                                      : Theme.of(context).cardColor,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  children: [
                                    Checkbox(
                                      value: isSelected,
                                      onChanged: (_) {
                                        setState(() {
                                          if (isSelected) {
                                            _selectedIndices.remove(index);
                                          } else {
                                            _selectedIndices.add(index);
                                          }
                                        });
                                      },
                                    ),
                                    const SizedBox(width: 8),
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child:
                                          item.product.imagePath != null
                                              ? Image.network(
                                                item.product.imagePath!,
                                                width: 60,
                                                height: 60,
                                                fit: BoxFit.cover,
                                                errorBuilder:
                                                    (context, error, _) =>
                                                        const Icon(
                                                          Icons.broken_image,
                                                          size: 60,
                                                        ),
                                              )
                                              : const Icon(
                                                Icons.shopping_cart,
                                                size: 60,
                                              ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            item.product.name,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            '\$${item.product.price.toStringAsFixed(2)} each',
                                            style: TextStyle(
                                              color:
                                                  Theme.of(
                                                    context,
                                                  ).textTheme.bodySmall?.color,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Row(
                                            children: [
                                              IconButton(
                                                icon: const Icon(Icons.remove),
                                                onPressed: () {
                                                  setState(() {
                                                    cart.decreaseQuantity(
                                                      item.product.id,
                                                    );
                                                    if (item.quantity == 0)
                                                      _selectedIndices.remove(
                                                        index,
                                                      );
                                                  });
                                                },
                                              ),
                                              Text('${item.quantity}'),
                                              IconButton(
                                                icon: const Icon(Icons.add),
                                                onPressed:
                                                    () => setState(
                                                      () =>
                                                          cart.increaseQuantity(
                                                            item.product.id,
                                                          ),
                                                    ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    Column(
                                      children: [
                                        Text(
                                          '\$${item.totalPrice.toStringAsFixed(2)}',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                        IconButton(
                                          icon: const Icon(
                                            Icons.delete,
                                            color: Colors.red,
                                          ),
                                          onPressed:
                                              () => _confirmDeleteItem(
                                                context,
                                                index,
                                                item.product.id,
                                              ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }),
                    ],
                  );
                },
              ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).bottomAppBarTheme.color,
          border: Border(
            top: BorderSide(color: Theme.of(context).dividerColor),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _selectedIndices.isEmpty ? 'Total:' : 'Selected Total:',
                  style: const TextStyle(fontSize: 18),
                ),
                Text(
                  '\$${_selectedIndices.isEmpty ? cart.totalAmount.toStringAsFixed(2) : selectedTotal.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed: () {
                  if (cart.items.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Your cart is empty')),
                    );
                    return;
                  }

                  if (_selectedIndices.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please select items to checkout'),
                      ),
                    );
                    return;
                  }

                  _showSuccessAnimation();

                  final itemsToRemove =
                      _selectedIndices
                          .map((index) => cart.items[index].product.id)
                          .toList();
                  for (var id in itemsToRemove) {
                    cart.removeItem(id);
                  }
                  setState(() => _selectedIndices.clear());
                },
                child: const Text(
                  'CHECKOUT',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
