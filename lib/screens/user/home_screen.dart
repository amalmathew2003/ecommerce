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

              const SizedBox(height: 24),

              // ---------------- CATEGORIES LIST ----------------
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection("categories")
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: CircularProgressIndicator(
                        color: ColorConst.primaryLight,
                      ),
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

                  final categories = snapshot.data!.docs;

                  return SizedBox(
                    height: 90, // fixed height for horizontal list
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
                          return BounceInUp(
                            duration: const Duration(milliseconds: 500),
                            child: GestureDetector(
                              onTap: () =>
                                  setState(() => selectedCategoryId = null),
                              child: Container(
                                margin: const EdgeInsets.only(right: 12),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 10,
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
                                  children: const [
                                    CircleAvatar(
                                      backgroundColor: Colors.white,
                                      child: Icon(
                                        Icons.apps,
                                        color: Colors.orange,
                                      ),
                                    ),
                                    SizedBox(width: 10),
                                    Text(
                                      "All",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
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

                        return ZoomIn(
                          duration: const Duration(milliseconds: 400),
                          child: GestureDetector(
                            onTap: () =>
                                setState(() => selectedCategoryId = id),
                            child: Container(
                              margin: const EdgeInsets.only(right: 12),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: selectedCategoryId == id
                                      ? [Colors.orange, Colors.deepOrangeAccent]
                                      : [Colors.white, Colors.grey.shade200],
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
                                    radius: 25,
                                    backgroundColor: Colors.grey.shade200,
                                    backgroundImage: image.isNotEmpty
                                        ? NetworkImage(image)
                                        : null,
                                    child: image.isEmpty
                                        ? const Icon(
                                            Icons.category,
                                            color: Colors.grey,
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
                                      fontSize: 16,
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
              ),

              // ---------------- PRODUCT LIST ----------------
              StreamBuilder<QuerySnapshot>(
                stream: selectedCategoryId == null
                    ? FirebaseFirestore.instance
                          .collection("products")
                          .snapshots()
                    : FirebaseFirestore.instance
                          .collection("products")
                          .where(
                            "category.id",
                            isEqualTo: selectedCategoryId,
                          ) // ✅ correct
                          .snapshots(),

                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    );
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

                  return GridView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    padding: const EdgeInsets.all(12),
                    itemCount: products.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: MediaQuery.of(context).size.width < 600
                          ? 2
                          : MediaQuery.of(context).size.width < 900
                          ? 3
                          : 5,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 3 / 4,
                    ),
                    itemBuilder: (context, index) {
                      final doc = products[index]; // Firestore doc
                      final data = doc.data() as Map<String, dynamic>;

                      final product = ProductModel.fromMap(doc.id, data);

                      return Card(
                        color: ColorConst.secondary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ProductDetailsScreen(
                                  product: product,
                                ), // ✅ pass model
                              ),
                            );
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  product.imageUrls.isNotEmpty
                                      ? product.imageUrls.first
                                      : "https://via.placeholder.com/150",
                                  height: 100,
                                  width: 100,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                product.name,
                                textAlign: TextAlign.center,
                                style: GoogleFonts.namdhinggo(
                                  color: ColorConst.primary,
                                  fontSize: 14,
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}
