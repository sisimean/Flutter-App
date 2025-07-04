import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../Model/appointment.dart';
import '../../Model/product.dart';
import '../../Widget/Product Card.dart';
import '../../services/api_service.dart';
import '../Appointment.dart';
import '../Appointment/AppointmentDetailScreen.dart';
import '../Order.dart';
import '../cart/cart_screen.dart';
import '../login_screen.dart';
import '../profile_screen.dart';
import '../theme_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late Future<List<Product>> futureProducts;
  List<Appointment> appointments = [];

  String? profileUrl;
  String? email;
  String? name;

  String _selectedCategory = 'All';

  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    futureProducts = _fetchProducts();
    _loadUserInfo();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _loadUserInfo() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final profile = prefs.getString('profile');
      final mail = prefs.getString('email');
      final userName = prefs.getString('name');

      setState(() {
        profileUrl = profile ?? '';
        email = mail ?? '';
        name = userName ?? '';
      });
    } catch (e) {
      debugPrint('Failed to load profile or email from SharedPreferences: $e');
    }
  }

  Future<List<Product>> _fetchProducts() async {
    final data = await ApiService().fetchProducts();
    return data.map((json) => Product.fromJson(json)).toList();
  }

  void _refreshProducts() {
    setState(() {
      futureProducts = _fetchProducts();
    });
  }

  // Paste this inside your _HomeScreenState class

  Future<void> _showFullProfile() async {
    if (profileUrl == null || profileUrl!.isEmpty) return;

    await showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: "Profile Image",
      barrierColor: Colors.black.withOpacity(0.9),
      transitionDuration: const Duration(milliseconds: 500),
      pageBuilder: (context, anim1, anim2) {
        return SafeArea(
          child: Scaffold(
            backgroundColor: Colors.brown.shade800,
            body: Stack(
              children: [
                Center(
                  child: InteractiveViewer(
                    panEnabled: true,
                    minScale: 0.5,
                    maxScale: 4.0,
                    child: Hero(
                      tag: 'profile-image-hero',
                      child: Image.network(
                        profileUrl!,
                        errorBuilder:
                            (context, error, stackTrace) => Container(
                              color: Colors.grey[200],
                              child: const Center(
                                child: Icon(
                                  Icons.broken_image,
                                  size: 50,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 20,
                  right: 20,
                  child: IconButton(
                    icon: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 30,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ],
            ),
          ),
        );
      },
      transitionBuilder: (context, anim1, anim2, child) {
        return FadeTransition(
          opacity: CurvedAnimation(parent: anim1, curve: Curves.easeOut),
          child: ScaleTransition(
            scale: CurvedAnimation(parent: anim1, curve: Curves.easeOutBack),
            child: child,
          ),
        );
      },
    );
  }

  Future<void> _navigateToAppointmentScreen(Product product) async {
    final result = await Navigator.push<Appointment>(
      context,
      MaterialPageRoute(
        builder: (context) => AppointmentScreen(product: product),
      ),
    );

    if (result != null) {
      setState(() {
        appointments.add(result);
      });
    }
  }

  List<Product> _filterProducts(List<Product> products) {
    switch (_selectedCategory) {
      case 'Monitor':
        return products
            .where(
              (p) =>
          p.name.contains("Monitor") ||
              p.name.contains("Display") ||
              p.name.contains("Screen"),
        )
            .toList();
      case 'Watch':
        return products
            .where(
              (p) => p.name.contains("Watch"),
        )
            .toList();
      case 'AirPods':
        return products
            .where(
              (p) => p.name.contains("AirPods"),
        )
            .toList();
      default:
        return products;
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(color: Colors.brown),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: _showFullProfile,
                    child: CircleAvatar(
                      radius: 40,
                      backgroundImage:
                          profileUrl != null && profileUrl!.isNotEmpty
                              ? NetworkImage(profileUrl!)
                              : const AssetImage(
                                    'assets/images/default_avatar.png',
                                  )
                                  as ImageProvider,
                    ),
                  ),
                  const SizedBox(height: 10),
                  if (name != null && name!.isNotEmpty)
                    Text(
                      name!,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  if (email != null && email!.isNotEmpty)
                    Text(
                      email!,
                      style: const TextStyle(
                        color: Colors.white60,
                        fontSize: 14,
                      ),
                    ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.person, color: Colors.black),
              title: const Text('Profile'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ProfileScreen()),
                );
              },
            ),
            Consumer<ThemeProvider>(
              builder: (context, themeProvider, child) {
                return SwitchListTile(
                  secondary: const Icon(
                    Icons.brightness_6,
                    color: Colors.black,
                  ),
                  title: const Text('Dark Mode'),
                  value: themeProvider.isDarkMode,
                  onChanged: (value) {
                    themeProvider.toggleTheme(value);
                  },
                );
              },
            ),

            ListTile(
              leading: const Icon(Icons.logout, color: Colors.black),
              title: const Text('Logout'),
              onTap: () async {
                Navigator.pop(context);
                final shouldLogout = await showDialog<bool>(
                  context: context,
                  builder:
                      (context) => AlertDialog(
                        title: const Text('Confirm Logout'),
                        content: const Text('Are you sure you want to logout?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: const Text('Logout'),
                          ),
                        ],
                      ),
                );

                if (shouldLogout == true) {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                    (route) => false,
                  );
                }
              },
            ),
          ],
        ),
      ),
      appBar: AppBar(
        backgroundColor: Colors.brown.shade800,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Customer System',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
            color: Colors.white,
            icon: const Icon(Icons.calendar_today),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (context) => AppointmentDetailScreen(
                        initialAppointments: appointments,
                        onRemove: (id) {
                          setState(() {
                            appointments.removeWhere((appt) => appt.id == id);
                          });
                        },
                      ),
                ),
              );
            },
          ),
          IconButton(
            color: Colors.white,
            icon: const Icon(Icons.shopping_cart),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CartScreen()),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children:
                ['All', 'Monitor', 'Watch', 'AirPods'].map((
                    category,
                    ) {
                      final isSelected = _selectedCategory == category;
                      final isDark =
                          Theme.of(context).brightness == Brightness.dark;

                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: ChoiceChip(
                          label: Text(category),
                          selected: isSelected,
                          onSelected: (selected) {
                            if (selected) {
                              setState(() {
                                _selectedCategory = category;
                              });
                            }
                          },
                          checkmarkColor: Colors.white,
                          selectedColor:  Colors.grey.shade800,
                          backgroundColor:
                              isDark ? Colors.grey[800] : Colors.grey[200],
                          labelStyle: TextStyle(
                            color:
                                isSelected
                                    ? Colors.white
                                    : isDark
                                    ? Colors.white70
                                    : Colors.black,
                          ),
                        ),
                      );
                    }).toList(),
              ),
            ),
          ),

          Expanded(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: FutureBuilder<List<Product>>(
                future: futureProducts,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('No products available'));
                  }

                  final filteredProducts = _filterProducts(snapshot.data!);

                  return RefreshIndicator(
                    onRefresh: () async {
                      _refreshProducts();
                      await futureProducts;
                    },
                    child: GridView.builder(
                      padding: const EdgeInsets.all(16),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            childAspectRatio: 0.8,
                          ),
                      itemCount: filteredProducts.length,
                      itemBuilder: (context, index) {
                        final product = filteredProducts[index];
                        return ProductCard(
                          product: product,
                          onOrderPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) => OrderScreen(product: product),
                              ),
                            );
                          },
                          onAppointmentPressed: () {
                            _navigateToAppointmentScreen(product);
                          },
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
