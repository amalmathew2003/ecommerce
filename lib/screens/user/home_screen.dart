import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:social_feed_app/const/color_const.dart';
import 'package:social_feed_app/screens/user/home_details.dart';
import 'package:social_feed_app/screens/user/login_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    required String profileimage,
    required String name,
    required String email,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Map<String, String>? selectedCategory; // {name, image}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConst.primary,
      appBar: AppBar(
        backgroundColor: ColorConst.primary,
        title: Text(
          selectedCategory == null
              ? "Categories"
              : selectedCategory!["name"] ?? "Category",
          style: GoogleFonts.namdhinggo(
            color: ColorConst.secondary,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        leading: selectedCategory != null
            ? IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => setState(() => selectedCategory = null),
              )
            : null,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () => userlogout(context),
          ),
        ],
      ),
      body: selectedCategory == null
          ? _buildCategoryList()
          : _buildProductList(selectedCategory!["name"]!),
    );
  }

  /// 🔹 Show Categories (with image + name)
  Widget _buildCategoryList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection("products").snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.white),
          );
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

        final Map<String, String> categoryMap = {}; // {name: image}
        for (var doc in snapshot.data!.docs) {
          final data = doc.data() as Map<String, dynamic>;
          if (data["categories"] != null && data["categories"] is List) {
            for (var cat in data["categories"]) {
              if (cat is Map && cat["name"] != null) {
                final name = cat["name"].toString();
                final image = cat["image"]?.toString() ?? "";
                categoryMap.putIfAbsent(name, () => image);
              }
            }
          }
        }

        final categoryList = categoryMap.entries.toList();

        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: categoryList.length,
          itemBuilder: (context, index) {
            final category = categoryList[index];
            return GestureDetector(
              onTap: () => setState(
                () => selectedCategory = {
                  "name": category.key,
                  "image": category.value,
                },
              ),
              child: Card(
                color: ColorConst.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 4,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: category.value.isNotEmpty
                          ? Image.network(
                              category.value,
                              width: 100,
                              height: 100,
                              fit: BoxFit.cover,
                            )
                          : Container(
                              width: 100,
                              height: 100,
                              color: Colors.grey.shade300,
                              child: const Icon(Icons.category, size: 40),
                            ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      category.key,
                      style: GoogleFonts.namdhinggo(
                        color: ColorConst.secondary,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  /// 🔹 Show Products filtered by category name
  Widget _buildProductList(String categoryName) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection("products").snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.white),
          );
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Text(
              "No products found in $categoryName",
              style: GoogleFonts.namdhinggo(
                color: ColorConst.secondary,
                fontSize: 16,
              ),
            ),
          );
        }

        final products = snapshot.data!.docs.where((doc) {
          final data = doc.data() as Map<String, dynamic>;
          if (data["categories"] != null && data["categories"] is List) {
            for (var cat in data["categories"]) {
              if (cat is Map && cat["name"] == categoryName) return true;
            }
          }
          return false;
        }).toList();

        if (products.isEmpty) {
          return Center(
            child: Text(
              "No products found in $categoryName",
              style: GoogleFonts.namdhinggo(
                color: ColorConst.secondary,
                fontSize: 16,
              ),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: products.length,
          itemBuilder: (context, index) {
            final data = products[index].data() as Map<String, dynamic>;
            return InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProductDetailsScreen(product: data),
                  ),
                );
              },
              child: Card(
                color: ColorConst.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 4,
                margin: const EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child:
                            (data["imageUrls"] != null &&
                                data["imageUrls"] is List &&
                                data["imageUrls"].isNotEmpty)
                            ? Image.network(
                                data["imageUrls"].first.toString(),
                                width: 100,
                                height: 100,
                                fit: BoxFit.cover,
                              )
                            : Container(
                                width: 100,
                                height: 100,
                                color: Colors.grey.shade300,
                                child: const Icon(Icons.image, size: 40),
                              ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              data["name"] ?? "Unnamed Product",
                              style: GoogleFonts.namdhinggo(
                                color: ColorConst.secondary,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              data["description"] ?? "No description",
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.namdhinggo(
                                color: ColorConst.secondary.withOpacity(0.8),
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Text(
                                  "₹${data["price"] ?? "0"}",
                                  style: GoogleFonts.namdhinggo(
                                    color: ColorConst.secondary,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const Spacer(),
                                Text(
                                  "Stock: ${data["stock"] ?? "0"}",
                                  style: GoogleFonts.namdhinggo(
                                    color: ColorConst.secondary,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

Future<void> userlogout(BuildContext context) async {
  await FirebaseAuth.instance.signOut();
  Navigator.of(context).pushAndRemoveUntil(
    PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) =>
          const LoginScreen(),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(opacity: animation, child: child);
      },
      transitionDuration: const Duration(milliseconds: 500),
    ),
    (route) => false,
  );
}
