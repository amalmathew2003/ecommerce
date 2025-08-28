import 'dart:convert';
import 'dart:io' show File; // only used in mobile
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb, Uint8List;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:social_feed_app/const/color_const.dart';

class ProductAddPage extends StatefulWidget {
  const ProductAddPage({super.key});

  @override
  State<ProductAddPage> createState() => _ProductAddPageState();
}

class _ProductAddPageState extends State<ProductAddPage>
    with SingleTickerProviderStateMixin {
  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final priceController = TextEditingController();
  final descController = TextEditingController();
  final stockController = TextEditingController();
  final categoryController = TextEditingController();

  List<String> imageUrls = [];
  List<Map<String, String>> categories = []; // category name + image url
  Uint8List? previewBytes;
  File? previewFile;
  bool isLoading = false;
  String? categoryImageUrl;

  late AnimationController _animController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeInOut,
    );
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  // Upload image to Bytescale
  Future<String?> uploadProductImage({
    File? file,
    Uint8List? bytes,
    required String fileName,
  }) async {
    const accountId = "223k2MX";
    const apiKey = "public_223k2MX9daNjdoQrytoiTGx4UzRw";
    final uri = Uri.parse(
      "https://api.bytescale.com/v2/accounts/$accountId/uploads/form_data",
    );

    try {
      http.Response response;

      if (kIsWeb && bytes != null) {
        final request = http.MultipartRequest("POST", uri)
          ..headers["Authorization"] = "Bearer $apiKey"
          ..files.add(
            http.MultipartFile.fromBytes("file", bytes, filename: fileName),
          );

        final streamedResponse = await request.send();
        response = await http.Response.fromStream(streamedResponse);
      } else if (file != null) {
        final request = http.MultipartRequest("POST", uri)
          ..headers["Authorization"] = "Bearer $apiKey"
          ..files.add(await http.MultipartFile.fromPath("file", file.path));

        final streamedResponse = await request.send();
        response = await http.Response.fromStream(streamedResponse);
      } else {
        debugPrint("⚠️ No file or bytes provided to uploadProductImage");
        return null;
      }

      debugPrint("Upload response: ${response.statusCode} => ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data["files"][0]["fileUrl"];
      } else {
        return null;
      }
    } catch (e) {
      debugPrint("🔥 Upload exception: $e");
      return null;
    }
  }

  Future<void> _pickAndUploadImage() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.image);

    if (result != null) {
      setState(() => isLoading = true);

      String? url;
      if (kIsWeb) {
        url = await uploadProductImage(
          bytes: result.files.single.bytes,
          fileName: result.files.single.name,
        );
      } else if (result.files.single.path != null) {
        url = await uploadProductImage(
          file: File(result.files.single.path!),
          fileName: result.files.single.name,
        );
      }

      if (url != null) {
        setState(() {
          imageUrls.add(url!);
        });
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("❌ Image upload failed")));
      }

      setState(() => isLoading = false);
    }
  }



  Future<void> saveProduct(String imageUrl) async {
    final String name = nameController.text.trim();
    final String price = priceController.text.trim();
    final String description = descController.text.trim();
    final String selectedCategoryId = categoryController.text.trim();

    if (name.isEmpty ||
        price.isEmpty ||
        description.isEmpty ||
        imageUrl.isEmpty ||
        selectedCategoryId.isEmpty) {
      print("Please fill all fields including category and image");
      return;
    }

    setState(() => isLoading = true);

    try {
      // 🔥 fetch category details from Firestore
      final categoryDoc = await FirebaseFirestore.instance
          .collection("categories")
          .doc(selectedCategoryId)
          .get();

      final categoryData = categoryDoc.data();

      await FirebaseFirestore.instance.collection("products").add({
        "name": name,
        "price": price,
        "description": description,
        "stock": stockController.text.trim(),
        "imageUrls": imageUrls,
        "category": {
          "id": selectedCategoryId,
          "name": categoryData?["name"],
          "image": categoryData?["image"],
        },
        "createdAt": FieldValue.serverTimestamp(),
      });

      // ✅ Clear form fields after save
      nameController.clear();
      priceController.clear();
      descController.clear();
      stockController.clear();
      categoryController.clear();

      setState(() {
        imageUrls.clear();
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("✅ Product saved successfully")),
      );

      print("✅ Product saved!");
    } catch (e) {
      setState(() => isLoading = false);
      print("❌ Error saving product: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConst.primary,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.arrow_back, color: ColorConst.secondary),
        ),
        backgroundColor: ColorConst.primary,
        elevation: 0,
        title: Text(
          "Add Product",
          style: GoogleFonts.namdhinggo(
            color: ColorConst.secondary,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(
                    height: 60,
                    width: 60,
                    child: CircularProgressIndicator(
                      strokeWidth: 5,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "Saving Product...",
                    style: GoogleFonts.namdhinggo(
                      color: ColorConst.secondary,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            )
          : FadeTransition(
              opacity: _fadeAnimation,
              child: Form(
                key: formKey,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Card(
                        color: ColorConst.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        elevation: 6,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              //Category sclection
                              Text(
                                "Category",
                                style: GoogleFonts.namdhinggo(
                                  color: ColorConst.secondary,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),

                              StreamBuilder<QuerySnapshot>(
                                stream: FirebaseFirestore.instance
                                    .collection("categories")
                                    .orderBy("createdAt", descending: true)
                                    .snapshots(),
                                builder: (context, snapshot) {
                                  if (!snapshot.hasData) {
                                    return const CircularProgressIndicator();
                                  }

                                  final docs = snapshot.data!.docs;

                                  return Wrap(
                                    spacing: 8,
                                    runSpacing: 8,
                                    children: docs.map((doc) {
                                      final data =
                                          doc.data() as Map<String, dynamic>;
                                      final isSelected =
                                          categoryController.text == doc.id;

                                      return GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            categoryController.text = doc
                                                .id; // save selected category id
                                          });
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 8,
                                          ),
                                          decoration: BoxDecoration(
                                            color: isSelected
                                                ? ColorConst.secondary
                                                : ColorConst.primary,
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                            border: Border.all(
                                              color: isSelected
                                                  ? ColorConst.secondary
                                                  : Colors.grey.shade300,
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black.withValues(
                                                  alpha: .05,
                                                ),
                                                blurRadius: 4,
                                                offset: const Offset(2, 2),
                                              ),
                                            ],
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              if (data["image"] != null)
                                                Container(
                                                  width: 40,
                                                  height: 30,
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          6,
                                                        ), // small rounded corners
                                                    image: DecorationImage(
                                                      image: NetworkImage(
                                                        data['image'],
                                                      ),
                                                      fit: BoxFit.cover,
                                                    ),
                                                  ),
                                                ),
                                              const SizedBox(width: 8),
                                              Text(
                                                data["name"],
                                                style: TextStyle(
                                                  color: isSelected
                                                      ? Colors.white
                                                      : ColorConst.secondary,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                  );
                                },
                              ),

                              const SizedBox(height: 12),

                              _buildTextField(
                                nameController,
                                "Enter Product Name",
                              ),
                              const SizedBox(height: 20),
                              _buildTextField(
                                priceController,
                                "Enter Product Price",
                                keyboard: TextInputType.number,
                              ),
                              const SizedBox(height: 20),
                              _buildTextField(
                                descController,
                                "Enter Description",
                                maxLines: 2,
                              ),
                              const SizedBox(height: 20),
                              _buildTextField(
                                stockController,
                                "Enter Stock",
                                keyboard: TextInputType.number,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // 🔥 Category Section
                      if (imageUrls.isNotEmpty)
                        SizedBox(
                          height: 120,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: imageUrls.length,
                            itemBuilder: (context, index) {
                              return Container(
                                margin: const EdgeInsets.only(right: 10),
                                clipBehavior: Clip.antiAlias,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black26,
                                      blurRadius: 6,
                                      offset: Offset(2, 2),
                                    ),
                                  ],
                                ),
                                child: Image.network(
                                  imageUrls[index],
                                  height: 120,
                                  width: 120,
                                  fit: BoxFit.cover,
                                ),
                              );
                            },
                          ),
                        ),

                      const SizedBox(height: 16),
                      InkWell(
                        onTap: _pickAndUploadImage,
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: 14,
                            horizontal: 20,
                          ),
                          decoration: BoxDecoration(
                            color: ColorConst.primary,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: ColorConst.secondary.withValues(alpha: .4),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.upload_file,
                                color: Colors.white,
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                "Upload Product Image",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),
                      GestureDetector(
                        onTap: () {
                          if (imageUrls.isNotEmpty) {
                            saveProduct(imageUrls.first);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  "⚠️ Please upload at least one image",
                                ),
                              ),
                            );
                          }
                        },
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          decoration: BoxDecoration(
                            color: ColorConst.primary,
                            border: Border.all(color: ColorConst.secondary),
                            borderRadius: BorderRadius.circular(30),
                            boxShadow: [
                              BoxShadow(
                                color: ColorConst.secondary.withValues(alpha: .4),
                                blurRadius: 10,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          alignment: Alignment.center,
                          child: const Text(
                            "Save Product",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildTextField(
    TextEditingController ctrl,
    String hint, {
    int maxLines = 1,
    TextInputType keyboard = TextInputType.text,
  }) {
    return TextFormField(
      controller: ctrl,
      maxLines: maxLines,
      keyboardType: keyboard,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return "Required";
        }
        return null;
      },
      style: GoogleFonts.namdhinggo(
        color: ColorConst.secondary,
        fontSize: 16,
        fontWeight: FontWeight.w500,
      ),
      cursorColor: ColorConst.secondary,
      decoration: InputDecoration(
        filled: true,
        fillColor: ColorConst.secondary.withValues(alpha: 0.1),
        hintText: hint,
        hintStyle: GoogleFonts.namdhinggo(
          color: ColorConst.secondary.withValues(alpha: 0.7),
          fontSize: 15,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: ColorConst.secondary, width: 2),
        ),
      ),
    );
  }
}
