import 'dart:convert';
import 'dart:io' show File;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb, Uint8List;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class CategoryAddPage extends StatefulWidget {
  const CategoryAddPage({super.key});

  @override
  State<CategoryAddPage> createState() => _CategoryAddPageState();
}

class _CategoryAddPageState extends State<CategoryAddPage> {
  final TextEditingController categoryController = TextEditingController();
  bool isLoading = false;
  String? imageUrl;

  Future<String?> uploadCategoryImage({
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

        final streamed = await request.send();
        response = await http.Response.fromStream(streamed);
      } else if (file != null) {
        final request = http.MultipartRequest("POST", uri)
          ..headers["Authorization"] = "Bearer $apiKey"
          ..files.add(await http.MultipartFile.fromPath("file", file.path));

        final streamed = await request.send();
        response = await http.Response.fromStream(streamed);
      } else {
        return null;
      }

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data["files"][0]["fileUrl"];
      }
      return null;
    } catch (e) {
      debugPrint("Upload Error: $e");
      return null;
    }
  }

  Future<void> pickAndUploadImage() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.image);

    if (result != null) {
      setState(() => isLoading = true);
      String? url;

      if (kIsWeb) {
        url = await uploadCategoryImage(
          bytes: result.files.single.bytes,
          fileName: result.files.single.name,
        );
      } else if (result.files.single.path != null) {
        url = await uploadCategoryImage(
          file: File(result.files.single.path!),
          fileName: result.files.single.name,
        );
      }

      if (url != null) {
        setState(() => imageUrl = url);
      }

      setState(() => isLoading = false);
    }
  }

  Future<void> saveCategory() async {
    final name = categoryController.text.trim();
    if (name.isEmpty || imageUrl == null) return;

    setState(() => isLoading = true);

    await FirebaseFirestore.instance.collection("categories").add({
      "name": name,
      "image": imageUrl,
      "createdAt": FieldValue.serverTimestamp(),
    });

    setState(() {
      categoryController.clear();
      imageUrl = null;
      isLoading = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("✅ Category added successfully")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add Category")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: categoryController,
              decoration: const InputDecoration(labelText: "Category Name"),
            ),
            const SizedBox(height: 16),
            imageUrl != null
                ? Image.network(imageUrl!, height: 100)
                : const Text("No Image Selected"),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: pickAndUploadImage,
              child: const Text("Pick Image"),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: isLoading ? null : saveCategory,
              child: isLoading
                  ? const CircularProgressIndicator()
                  : const Text("Save Category"),
            ),
          ],
        ),
      ),
    );
  }
}
