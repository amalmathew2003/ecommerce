import 'package:animate_do/animate_do.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:social_feed_app/const/color_const.dart';
import 'package:social_feed_app/model/client/product_list.dart';
import 'package:social_feed_app/screens/user/product_details.dart';

class HomeProductList extends StatefulWidget {
  const HomeProductList({super.key});

  @override
  State<HomeProductList> createState() => _HomeProductListState();
}

class _HomeProductListState extends State<HomeProductList> {
  String? selectedCategoryId;
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: selectedCategoryId == null
          ? FirebaseFirestore.instance.collection("products").snapshots()
          : FirebaseFirestore.instance
                .collection("products")
                .where("category.id", isEqualTo: selectedCategoryId)
                .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.transparent),
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
                        double fontSize = constraints.maxWidth < 400 ? 14 : 18;

                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Product Image
                            Padding(
                              padding: const EdgeInsets.all(12),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
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
                                  crossAxisAlignment: CrossAxisAlignment.start,
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
                                      product.description ?? "No description",
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: ColorConst.primaryLight,
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
    );
  }
}
