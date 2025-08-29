import 'package:animate_do/animate_do.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:social_feed_app/const/color_const.dart';
import 'package:social_feed_app/model/client/product_list.dart';
import 'package:social_feed_app/screens/user/product_details.dart';

class HomeScreen extends StatefulWidget {
  final String profileimage;
  final String username;
  final String email;

  const HomeScreen({
    super.key,
    required this.profileimage,
    required this.username,
    required this.email,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? selectedCategoryId; // null = show all

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConst.primary,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: 10),
              // ---------------- USER ROW ----------------
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundImage: NetworkImage(widget.profileimage),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        widget.username,
                        style: GoogleFonts.namdhinggo(
                          color: ColorConst.secondary,
                          fontSize: 22,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.person),
                      color: ColorConst.secondary,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // ---------------- CATEGORIES LIST ----------------
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection("categories")
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const SizedBox.shrink();
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(
                      child: Text(
                        "No categories found",
                        style: GoogleFonts.namdhinggo(
                          color: ColorConst.secondary,
                          fontSize: 16,
                        ),
                      ),
                    );
                  }

                  final categories = snapshot.data!.docs;

                  return LayoutBuilder(
                    builder: (context, constraints) {
                      double screenWidth = constraints.maxWidth;

                      // Responsive sizes
                      double cardHeight = screenWidth < 600
                          ? 90 // mobile
                          : screenWidth < 1024
                          ? 110 // tablet
                          : 130; // desktop

                      double avatarRadius = screenWidth < 600
                          ? 20
                          : screenWidth < 1024
                          ? 28
                          : 35;

                      double fontSize = screenWidth < 600
                          ? 14
                          : screenWidth < 1024
                          ? 16
                          : 18;

                      return SizedBox(
                        height: cardHeight,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          itemCount: categories.length + 1, // +1 for "All"
                          itemBuilder: (context, index) {
                            if (index == 0) {
                              // ALL Option
                              return FadeInRight(
                                duration: const Duration(milliseconds: 500),
                                child: GestureDetector(
                                  onTap: () =>
                                      setState(() => selectedCategoryId = null),
                                  child: Container(
                                    margin: const EdgeInsets.only(right: 12),
                                    padding: EdgeInsets.symmetric(
                                      horizontal: screenWidth < 600 ? 14 : 20,
                                      vertical: screenWidth < 600 ? 8 : 12,
                                    ),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: selectedCategoryId == null
                                            ? [
                                                Colors.orange,
                                                Colors.deepOrangeAccent,
                                              ]
                                            : [
                                                ColorConst.secondary,
                                                Colors.black87,
                                              ],
                                      ),
                                      borderRadius: BorderRadius.circular(20),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black26,
                                          blurRadius: 6,
                                          offset: const Offset(2, 3),
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      children: [
                                        CircleAvatar(
                                          radius: avatarRadius,
                                          backgroundColor: Colors.white,
                                          child: Icon(
                                            Icons.apps,
                                            color: Colors.orange,
                                            size:
                                                avatarRadius, // scale with radius
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        Text(
                                          "All",
                                          style: TextStyle(
                                            color: ColorConst.primary,
                                            fontWeight: FontWeight.bold,
                                            fontSize: fontSize,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            }

                            final data =
                                categories[index - 1].data()
                                    as Map<String, dynamic>;
                            final id = categories[index - 1].id;
                            final name = data["name"] ?? "Unnamed";
                            final image = data["image"] ?? "";

                            return FadeInRight(
                              duration: const Duration(milliseconds: 400),
                              child: GestureDetector(
                                onTap: () =>
                                    setState(() => selectedCategoryId = id),
                                child: Container(
                                  margin: const EdgeInsets.only(right: 12),
                                  padding: EdgeInsets.symmetric(
                                    horizontal: screenWidth < 600 ? 14 : 20,
                                    vertical: screenWidth < 600 ? 8 : 12,
                                  ),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: selectedCategoryId == id
                                          ? [
                                              Colors.orange,
                                              Colors.deepOrangeAccent,
                                            ]
                                          : [
                                              ColorConst.secondary,
                                              ColorConst.primaryLight70,
                                            ],
                                    ),
                                    borderRadius: BorderRadius.circular(20),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black12,
                                        blurRadius: 5,
                                        offset: const Offset(2, 2),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    children: [
                                      CircleAvatar(
                                        radius: avatarRadius,
                                        backgroundColor: Colors.grey.shade200,
                                        backgroundImage: image.isNotEmpty
                                            ? NetworkImage(image)
                                            : null,
                                        child: image.isEmpty
                                            ? Icon(
                                                Icons.category,
                                                color: Colors.grey,
                                                size: avatarRadius,
                                              )
                                            : null,
                                      ),
                                      const SizedBox(width: 10),
                                      Text(
                                        name,
                                        style: GoogleFonts.namdhinggo(
                                          color: selectedCategoryId == id
                                              ? Colors.white
                                              : ColorConst.primary,
                                          fontSize: fontSize,
                                          fontWeight: FontWeight.w600,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
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
                },
              ),

              // ---------------- PRODUCT LIST ----------------
              StreamBuilder<QuerySnapshot>(
                stream: selectedCategoryId == null
                    ? FirebaseFirestore.instance
                          .collection("products")
                          .snapshots()
                    : FirebaseFirestore.instance
                          .collection("products")
                          .where("category.id", isEqualTo: selectedCategoryId)
                          .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const SizedBox.shrink();
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(
                      child: Text(
                        "No products found",
                        style: TextStyle(color: Colors.white),
                      ),
                    );
                  }

                  final products = snapshot.data!.docs;

                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      final doc = products[index];
                      final data = doc.data() as Map<String, dynamic>;
                      final product = ProductModel.fromMap(doc.id, data);

                      return FadeInUp(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 8,
                            horizontal: 12,
                          ),
                          child: Card(
                            color: ColorConst.secondary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 4,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(16),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        ProductDetailsScreen(product: product),
                                  ),
                                );
                              },
                              child: LayoutBuilder(
                                builder: (context, constraints) {
                                  // Responsive values
                                  double imageSize = constraints.maxWidth < 400
                                      ? 80
                                      : 120;
                                  double fontSize = constraints.maxWidth < 400
                                      ? 14
                                      : 18;

                                  return Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      // Product Image
                                      Padding(
                                        padding: const EdgeInsets.all(12),
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          child: Image.network(
                                            product.imageUrls.isNotEmpty
                                                ? product.imageUrls.first
                                                : "https://via.placeholder.com/150",
                                            height: imageSize,
                                            width: imageSize,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                      // Product Info
                                      Expanded(
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 12,
                                            horizontal: 8,
                                          ),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                product.name,
                                                style: GoogleFonts.namdhinggo(
                                                  color: ColorConst.primary,
                                                  fontSize: fontSize,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              const SizedBox(height: 6),
                                              Text(
                                                product.description,
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                  color:
                                                      ColorConst.primaryLight,
                                                  fontSize: fontSize - 2,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                    ],
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
