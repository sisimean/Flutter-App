class Product {
  final int id;
  final String name;
  final String description;
  final double price;
  int stock; // ✅ Mutable stock
  final String? imagePath; // ✅ Only using image_path
  final DateTime createdAt;
  final DateTime updatedAt;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.stock,
    this.imagePath,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      price: double.parse(json['price'].toString()),
      stock: json['stock'],
      imagePath: json['image_path'], // ✅ load image_path
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'price': price,
      'stock': stock,
      'image_path': imagePath, // ✅ save image_path
    };
  }
}
