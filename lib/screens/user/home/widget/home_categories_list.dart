import 'package:animate_do/animate_do.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:social_feed_app/const/color_const.dart';

class HomeCategoriesList extends StatefulWidget {
  const HomeCategoriesList({super.key});

  @override
  State<HomeCategoriesList> createState() => _HomeCategoriesListState();
}

class _HomeCategoriesListState extends State<HomeCategoriesList> {
  String? selectedCategoryId;
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection("categories").snapshots(),
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
                        onTap: () => setState(() => selectedCategoryId = null),
                        child: Container(
                          margin: const EdgeInsets.only(right: 12),
                          padding: EdgeInsets.symmetric(
                            horizontal: screenWidth < 600 ? 14 : 20,
                            vertical: screenWidth < 600 ? 8 : 12,
                          ),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: selectedCategoryId == null
                                  ? [Colors.orange, Colors.deepOrangeAccent]
                                  : [ColorConst.secondary, Colors.black87],
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
                                  size: avatarRadius, // scale with radius
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
                      categories[index - 1].data() as Map<String, dynamic>;
                  final id = categories[index - 1].id;
                  final name = data["name"] ?? "Unnamed";
                  final image = data["image"] ?? "";

                  return FadeInRight(
                    duration: const Duration(milliseconds: 400),
                    child: GestureDetector(
                      onTap: () => setState(() => selectedCategoryId = id),
                      child: Container(
                        margin: const EdgeInsets.only(right: 12),
                        padding: EdgeInsets.symmetric(
                          horizontal: screenWidth < 600 ? 14 : 20,
                          vertical: screenWidth < 600 ? 8 : 12,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: selectedCategoryId == id
                                ? [Colors.orange, Colors.deepOrangeAccent]
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
    );
  }
}
