import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:social_feed_app/const/color_const.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

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
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              decoration: InputDecoration(
                filled: true,
                fillColor: ColorConst.primary,
                hintText: "Search products or categories...",
                prefixIcon: const Icon(Icons.search),

                border: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: ColorConst.secondary,
                    width: 10,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  searchQuery = value.trim();
                });
              },
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: (searchQuery.isEmpty)
                  ? FirebaseFirestore.instance
                        .collection('products')
                        .snapshots()
                  : FirebaseFirestore.instance
                        .collection('products')
                        .where(
                          'keywords',
                          arrayContains: searchQuery.toString().toLowerCase(),
                        )
                        .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text("No products found"));
                }

                return ListView.builder(
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    var data =
                        snapshot.data!.docs[index].data()
                            as Map<String, dynamic>;

                    return ListTile(
                      leading:
                          (data['imageUrls'] != null &&
                              data['imageUrls'] is List &&
                              data['imageUrls'].isNotEmpty)
                          ? Image.network(
                              data['imageUrls'][0],
                              width: 50,
                              height: 50,
                              fit: BoxFit.cover,
                            )
                          : const Icon(Icons.image_not_supported, size: 50),
                      title: Text(data['name'] ?? "No Name"),
                      subtitle: Text(
                        "${data['category']?['name'] ?? 'Unknown Category'} • ₹${data['price']?.toString() ?? '0'}",
                      ),
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          "/details",
                          arguments: data,
                        );
                      },
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
