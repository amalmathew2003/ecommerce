import 'dart:convert';
import 'dart:io' show File;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:social_feed_app/screens/user/home/home_screen.dart';
import 'package:social_feed_app/services/authservice.dart';

import '../const/color_const.dart';


class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController nameCtrl = TextEditingController();
  final Authservice authservice = Authservice();

  Uint8List? selectedImageBytes;
  String? selectedFileName;
  String? uploadedUrl;
  bool isUploading = false;
  bool isSaving = false;

  String? gender;
  DateTime? dob;

  Future<void> pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      withData: kIsWeb,
      type: FileType.image,
    );

    if (result == null) return;

    setState(() {
      selectedFileName = result.files.single.name;
      if (kIsWeb) {
        selectedImageBytes = result.files.single.bytes;
      }
      uploadedUrl = null;
    });

    // auto upload
    if (selectedFileName != null) {
      await uploadFile();
    }
  }

  Future<void> uploadFile() async {
    if (selectedFileName == null) return;

    const accountId = "223k2MX";
    const apiKey = "public_223k2MX9daNjdoQrytoiTGx4UzRw";

    final uri = Uri.parse(
      "https://api.bytescale.com/v2/accounts/$accountId/uploads/binary?filename=$selectedFileName",
    );

    setState(() => isUploading = true);

    http.Response response;
    if (kIsWeb) {
      if (selectedImageBytes == null) return;
      response = await http.post(
        uri,
        headers: {
          "Authorization": "Bearer $apiKey",
          "Content-Type": "application/octet-stream",
        },
        body: selectedImageBytes,
      );
    } else {
      final result = await FilePicker.platform.pickFiles(type: FileType.image);
      if (result == null || result.files.single.path == null) return;
      final file = File(result.files.single.path!);

      response = await http.post(
        uri,
        headers: {
          "Authorization": "Bearer $apiKey",
          "Content-Type": "application/octet-stream",
        },
        body: await file.readAsBytes(),
      );
    }

    setState(() => isUploading = false);

    if (response.statusCode == 200) {
      final jsonResp = jsonDecode(response.body);
      setState(() {
        uploadedUrl = jsonResp["fileUrl"];
      });
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Upload failed")));
    }
  }

  Future<void> saveUserProfile(String name, String photoUrl) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final docRef = FirebaseFirestore.instance.collection("users").doc(user.uid);

    await docRef.set({
      "uid": user.uid,
      "name": name,
      "email": user.email,
      "photoUrl": photoUrl,
      "gender": gender,
      "dob": dob != null ? dob!.toIso8601String() : null,
      "createdAt": FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    if (uploadedUrl == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select a profile picture")),
      );
      return;
    }
    if (gender == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select your gender")),
      );
      return;
    }
    if (dob == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select your date of birth")),
      );
      return;
    }

    setState(() => isSaving = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await user.updateDisplayName(nameCtrl.text.trim());
        await user.updatePhotoURL(uploadedUrl);

        await saveUserProfile(nameCtrl.text.trim(), uploadedUrl!);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Profile updated successfully")),
        );

        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => 
              HomeScreen(
                profileimage: uploadedUrl!,
                username: nameCtrl.text.trim(),
                email: user.email.toString(), 
              ),
            ),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      setState(() => isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Container(
          width: 360,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: ColorConst.primaryLight.withValues(alpha: .1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: ColorConst.primaryLight.withValues(alpha: .2),
              width: 1.5,
            ),
          ),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Set Up Profile",
                  style: GoogleFonts.namdhinggo(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: ColorConst.primaryLight,
                  ),
                ),
                const SizedBox(height: 20),

                // Circle Avatar (tap to pick photo)
                GestureDetector(
                  onTap: pickFile,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.grey.shade800,
                        backgroundImage: uploadedUrl != null
                            ? NetworkImage(uploadedUrl!)
                            : null,
                        child: uploadedUrl == null
                            ? Icon(
                                Icons.camera_alt,
                                size: 40,
                                color: ColorConst.primaryLight70,
                              )
                            : null,
                      ),
                      if (isUploading)
                        const CircularProgressIndicator(color: Colors.white),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Name
                TextFormField(
                  controller: nameCtrl,
                  style: GoogleFonts.namdhinggo(color: ColorConst.primaryLight),
                  decoration: InputDecoration(
                    hintText: authservice.getUser?.displayName ?? 'Full Name',
                    hintStyle: GoogleFonts.namdhinggo(
                      color: ColorConst.primaryLight70,
                    ),
                    prefixIcon: Icon(
                      Icons.person,
                      color: ColorConst.primaryLight,
                    ),
                    filled: true,
                    fillColor: ColorConst.primaryLight.withValues(alpha: .05),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  validator: (v) => v!.isEmpty ? "Enter your full name" : null,
                ),

                const SizedBox(height: 10),

                // Email (readonly)
                TextFormField(
                  readOnly: true,
                  style: GoogleFonts.namdhinggo(color: ColorConst.primaryLight),
                  decoration: InputDecoration(
                    hintText: authservice.getUser?.email ?? "",
                    hintStyle: GoogleFonts.namdhinggo(
                      color: ColorConst.primaryLight.withValues(alpha: 0.5),
                    ),
                    prefixIcon: Icon(
                      Icons.email,
                      color: ColorConst.primaryLight,
                    ),
                    filled: true,
                    fillColor: ColorConst.primaryLight.withValues(alpha: .05),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                // Gender Dropdown
                // Gender Selection (Vertical Boxes)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Select Gender",
                      style: GoogleFonts.namdhinggo(
                        color: ColorConst.primaryLight70,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Row instead of Column
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: ["Male", "Female", "Other"].map((g) {
                        final isSelected = gender == g;
                        return Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => gender = g),
                            child: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? ColorConst.secondary
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isSelected
                                      ? ColorConst.secondary
                                      : ColorConst.primaryLight70,
                                  width: 1.5,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  g,
                                  style: GoogleFonts.namdhinggo(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: isSelected
                                        ? Colors.white
                                        : ColorConst.primaryLight70,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                // Date of Birth
                Row(
                  children: [
                    // Day Dropdown
                    Expanded(
                      child: DropdownButtonFormField<int>(
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.black, // Dropdown box color
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        dropdownColor: Colors.black, // Dropdown menu background
                        style: const TextStyle(
                          color: Colors.white,
                        ), // Text color inside dropdown
                        iconEnabledColor: Colors.white, // Down arrow color
                        value: dob?.day,
                        hint: Text(
                          "DD",
                          style: GoogleFonts.namdhinggo(color: Colors.white70),
                        ),
                        items: List.generate(31, (index) => index + 1)
                            .map(
                              (day) => DropdownMenuItem(
                                value: day,
                                child: Text(
                                  day.toString(),
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ),
                            )
                            .toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setState(() {
                              dob = DateTime(
                                dob?.year ?? DateTime.now().year,
                                dob?.month ?? DateTime.now().month,
                                val,
                              );
                            });
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 8),

                    // Month Dropdown
                    Expanded(
                      child: DropdownButtonFormField<int>(
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.black,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        dropdownColor: Colors.black,
                        style: const TextStyle(color: Colors.white),
                        iconEnabledColor: Colors.white,
                        value: dob?.month,
                        hint: Text(
                          "MM",
                          style: GoogleFonts.namdhinggo(color: Colors.white70),
                        ),
                        items: List.generate(12, (index) => index + 1)
                            .map(
                              (month) => DropdownMenuItem(
                                value: month,
                                child: Text(
                                  month.toString(),
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ),
                            )
                            .toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setState(() {
                              dob = DateTime(
                                dob?.year ?? DateTime.now().year,
                                val,
                                dob?.day ?? 1,
                              );
                            });
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 8),

                    // Year Dropdown
                    Expanded(
                      child: DropdownButtonFormField<int>(
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.black,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        dropdownColor: Colors.black,
                        style: const TextStyle(color: Colors.white),
                        iconEnabledColor: Colors.white,
                        value: dob?.year,
                        hint: Text(
                          "YYYY",
                          style: GoogleFonts.namdhinggo(color: Colors.white70),
                        ),
                        items:
                            List.generate(
                                  DateTime.now().year - 1899,
                                  (index) => 1900 + index,
                                )
                                .map(
                                  (year) => DropdownMenuItem(
                                    value: year,
                                    child: Text(
                                      year.toString(),
                                      style: const TextStyle(
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                )
                                .toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setState(() {
                              dob = DateTime(
                                val,
                                dob?.month ?? 1,
                                dob?.day ?? 1,
                              );
                            });
                          }
                        },
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ColorConst.secondary,
                    foregroundColor: ColorConst.primaryLight,
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  onPressed: isSaving ? null : saveProfile,
                  child: isSaving
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                          "Save Profile",
                          style: GoogleFonts.namdhinggo(
                            color: ColorConst.primary,
                            fontWeight: FontWeight.w600,
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
}
