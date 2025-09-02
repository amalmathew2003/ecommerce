import 'package:animate_do/animate_do.dart';
import 'package:carousel_slider/carousel_options.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:social_feed_app/const/color_const.dart';
import 'package:social_feed_app/model/client/product_list.dart';
import 'package:social_feed_app/screens/user/login_screen.dart';
import 'package:social_feed_app/screens/user/product_details.dart';
import 'package:social_feed_app/services/authservice.dart';
import 'package:waterfall_flow/waterfall_flow.dart';

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
  final Authservice authservice = Authservice();
  String? selectedCategoryId;
  // null = show all
  Future<void> userlogout() async {
    await authservice.logOut();
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const LoginScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

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
                      onPressed: () {
                        userlogout();
                      },
                      icon: const Icon(Icons.person),
                      color: ColorConst.secondary,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),
              // ---------------- NEW ARRIVALS CAROUSEL ----------------
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection("products")
                    .orderBy(
                      "createdAt",
                      descending: true,
                    ) // make sure you save `createdAt` when adding product
                    .limit(5) // only latest 5
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const SizedBox.shrink();
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const SizedBox.shrink(); // hide if no new arrivals
                  }

                  final newArrivals = snapshot.data!.docs;

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          child: Text(
                            "New Arrivals",
                            style: GoogleFonts.namdhinggo(
                              color: ColorConst.secondary,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        CarouselSlider.builder(
                          itemCount: newArrivals.length,
                          itemBuilder: (context, index, realIndex) {
                            final doc = newArrivals[index];
                            final data = doc.data() as Map<String, dynamic>;
                            final product = ProductModel.fromMap(doc.id, data);

                            return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        ProductDetailsScreen(product: product),
                                  ),
                                );
                              },
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(20),
                                child: Stack(
                                  children: [
                                    Image.network(
                                      product.imageUrls.isNotEmpty
                                          ? product.imageUrls.first
                                          : "https://via.placeholder.com/400x200",
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                    ),
                                    Container(
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            Colors.black.withOpacity(0.5),
                                            Colors.transparent,
                                          ],
                                          begin: Alignment.bottomCenter,
                                          end: Alignment.topCenter,
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      bottom: 12,
                                      left: 12,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            product.name,
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Text(
                                            "\$${product.price}",
                                            style: const TextStyle(
                                              color: Colors.white70,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                          options: CarouselOptions(
                            height: 200,
                            autoPlay: true,
                            enlargeCenterPage: true,
                            viewportFraction: 0.85,
                            autoPlayInterval: const Duration(seconds: 4),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),

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
                                            color: ColorConst.secondary,
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
                                              ColorConst.primary.withValues(
                                                alpha: 02,
                                              ),
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
                                              : ColorConst.secondary,
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

                  return WaterfallFlow.builder(
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
                            color:
                                ColorConst.secondary, // Use white for clean UI
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            elevation: 6,
                            shadowColor: ColorConst.secondary.withOpacity(0.4),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(20),
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
                                  double imageSize = constraints.maxWidth < 400
                                      ? 100
                                      : 140;
                                  double fontSize = constraints.maxWidth < 400
                                      ? 14
                                      : 18;

                                  return Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // 🔹 Product Image with Hero & Gradient Overlay
                                      Stack(
                                        children: [
                                          ClipRRect(
                                            borderRadius:
                                                const BorderRadius.vertical(
                                                  top: Radius.circular(20),
                                                ),
                                            child: Image.network(
                                              product.imageUrls.isNotEmpty
                                                  ? product.imageUrls.first
                                                  : "https://via.placeholder.com/150",
                                              height: imageSize + 60,
                                              width: double.infinity,
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                          Container(
                                            height: imageSize + 60,
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  const BorderRadius.vertical(
                                                    top: Radius.circular(20),
                                                  ),
                                              gradient: LinearGradient(
                                                colors: [
                                                  Colors.black.withOpacity(0.6),
                                                  Colors.transparent,
                                                ],
                                                begin: Alignment.bottomCenter,
                                                end: Alignment.topCenter,
                                              ),
                                            ),
                                          ),
                                          Positioned(
                                            bottom: 8,
                                            left: 12,
                                            child: Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 10,
                                                    vertical: 4,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: ColorConst.secondary,
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              child: Text(
                                                "\$${product.price}", // if you have price
                                                style: TextStyle(
                                                  color: ColorConst.primary,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: fontSize - 2,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      // 🔹 Product Info Section
                                      Padding(
                                        padding: const EdgeInsets.all(12),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              product.name,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
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
                                                color: Colors.grey.shade600,
                                                fontSize: fontSize - 2,
                                                height: 1.3,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                    gridDelegate:
                        SliverWaterfallFlowDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                        ),
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
