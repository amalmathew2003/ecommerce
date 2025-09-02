import 'package:animate_do/animate_do.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:social_feed_app/const/color_const.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  String searchQuery = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConst.primary,
      appBar: AppBar(
        title: Text(
          "Search",
          style: GoogleFonts.namdhinggo(color: ColorConst.secondary),
        ),
        centerTitle: true,
        backgroundColor: ColorConst.primary,
        elevation: 0,
      ),
      body: Column(
        children: [
          // 🔎 Modern Search Bar
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.grey.shade900,
                hintText: "Search products or categories...",
                hintStyle: const TextStyle(color: Colors.grey),
                prefixIcon: const Icon(Icons.search, color: Colors.white70),
                border: OutlineInputBorder(
                  borderSide: BorderSide.none,
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  searchQuery = value.trim().toLowerCase();
                });
              },
            ),
          ),

          // 🔄 Search Results
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: (searchQuery.isEmpty)
                  ? FirebaseFirestore.instance
                        .collection('products')
                        .snapshots()
                  : FirebaseFirestore.instance
                        .collection('products')
                        .where('keywords', arrayContains: searchQuery)
                        .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text(
                      "No products found",
                      style: TextStyle(color: Colors.white70),
                    ),
                  );
                }

                final docs = snapshot.data!.docs;

                return ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    var data = docs[index].data() as Map<String, dynamic>;

                    // 🎬 Staggered animations for each item
                    return ZoomIn(
                      duration: Duration(milliseconds: 300 + (index * 100)),
                      child: Card(
                        color: Colors.grey.shade900,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        child: ListTile(
                          leading:
                              (data['imageUrls'] != null &&
                                  data['imageUrls'] is List &&
                                  data['imageUrls'].isNotEmpty)
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.network(
                                    data['imageUrls'][0],
                                    width: 60,
                                    height: 60,
                                    fit: BoxFit.cover,
                                  ),
                                )
                              : const Icon(
                                  Icons.image_not_supported,
                                  size: 50,
                                  color: Colors.white70,
                                ),
                          title: Text(
                            data['name'] ?? "No Name",
                            style: TextStyle(
                              color: ColorConst.secondary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Text(
                            "${data['category']?['name'] ?? 'Unknown Category'} • ₹${data['price']?.toString() ?? '0'}",
                            style: const TextStyle(color: Colors.white70),
                          ),
                          trailing: const Icon(
                            Icons.arrow_forward_ios,
                            color: Colors.white54,
                            size: 18,
                          ),
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              "/details",
                              arguments: data,
                            );
                          },
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
