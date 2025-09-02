class ProductModel {
  final String id;
  final String name;
  final String description;
  final double price;
  final int stock;
  final List<String> imageUrls;
  final CategoryModel category; // instead of just categoryId

  ProductModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.stock,
    required this.imageUrls,
    required this.category,
  });

  factory ProductModel.fromMap(String id, Map<String, dynamic> data) {
    return ProductModel(
      id: id,
      name: data["name"] ?? "Unnamed Product",
      description: data["description"] ?? "No description",
      price: (data["price"] != null)
          ? double.tryParse(data["price"].toString()) ?? 0
          : 0,
      stock: (data["stock"] != null)
          ? int.tryParse(data["stock"].toString()) ?? 0
          : 0,
      imageUrls: (data["imageUrls"] != null && data["imageUrls"] is List)
          ? List<String>.from(data["imageUrls"])
          : [],
      category: data["category"] != null
          ? CategoryModel.fromMap(data["category"])
          : CategoryModel(id: "", name: "Unknown", image: ""),
    );
  }
}

class CategoryModel {
  final String id;
  final String name;
  final String image;

  CategoryModel({required this.id, required this.name, required this.image});

  factory CategoryModel.fromMap(Map<String, dynamic> data) {
    return CategoryModel(
      id: data["id"] ?? "",
      name: data["name"] ?? "Unnamed",
      image: data["image"] ?? "",
    );
  }
}
