import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:social_feed_app/const/color_const.dart';

class AdminNewArrivalsScreen extends StatelessWidget {
  const AdminNewArrivalsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConst.primary,
      appBar: AppBar(
        backgroundColor: ColorConst.primary,
        title: Text(
          "Manage New Arrivals",
          style: GoogleFonts.namdhinggo(
            color: ColorConst.secondary,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: StreamBuilder<QuerySnapshot>(
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
                "No products found",
                style: GoogleFonts.namdhinggo(
                  color: ColorConst.secondary,
                  fontSize: 16,
                ),
              ),
            );
          }

          final products = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: products.length,
            itemBuilder: (context, index) {
              final data = products[index].data() as Map<String, dynamic>;
              final productId = products[index].id;
              final imageUrl = (data["imageUrls"] != null &&
                      data["imageUrls"] is List &&
                      data["imageUrls"].isNotEmpty)
                  ? data["imageUrls"].first.toString()
                  : null;

              final isNewArrival = data["isNewArrival"] ?? false;

              return Card(
                color: ColorConst.secondary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 4,
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(12),
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: imageUrl != null
                        ? Image.network(
                            imageUrl,
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,
                          )
                        : Container(
                            width: 80,
                            height: 80,
                            color: Colors.grey.shade300,
                            child: const Icon(Icons.image, size: 40),
                          ),
                  ),
                  title: Text(
                    data["name"] ?? "Unnamed Product",
                    style: GoogleFonts.namdhinggo(
                      color: ColorConst.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(
                    "Price: ₹${data["price"] ?? "0"} | Stock: ${data["stock"] ?? "0"}",
                    style: GoogleFonts.namdhinggo(
                      color: ColorConst.primary.withOpacity(0.8),
                    ),
                  ),
                  trailing: Switch(
                    value: isNewArrival,
                    activeColor: ColorConst.secondary,
                    onChanged: (val) {
                      // 🔹 Update isNewArrival field in Firestore
                      FirebaseFirestore.instance
                          .collection("products")
                          .doc(productId)
                          .update({"isNewArrival": val});
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
