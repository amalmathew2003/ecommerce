import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:social_feed_app/model/profile_model.dart';

class ProfileService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static const String accountId = "223k2MX";
  static const String apiKey = "public_223k2MX9daNjdoQrytoiTGx4UzRw";

  /// Pick file from device
  Future<Uint8List?> pickFileBytes() async {
    final result = await FilePicker.platform.pickFiles(
      withData: kIsWeb,
      type: FileType.image,
    );
    return result?.files.single.bytes;
  }

  /// Upload file to Bytescale
  Future<String?> uploadFile(Uint8List fileBytes, String fileName) async {
    final uri = Uri.parse(
      "https://api.bytescale.com/v2/accounts/$accountId/uploads/binary?filename=$fileName",
    );

    final response = await http.post(
      uri,
      headers: {
        "Authorization": "Bearer $apiKey",
        "Content-Type": "application/octet-stream",
      },
      body: fileBytes,
    );

    if (response.statusCode == 200) {
      final jsonResp = jsonDecode(response.body);
      return jsonResp["fileUrl"];
    } else {
      return null;
    }
  }

  /// Save user profile to Firestore
  Future<void> saveUserProfile(UserProfile profile) async {
    await _firestore
        .collection("users")
        .doc(profile.uid)
        .set(profile.toMap(), SetOptions(merge: true));
  }

  /// Update FirebaseAuth user (display name + photo)
  Future<void> updateAuthProfile(String name, String photoUrl) async {
    final user = _auth.currentUser;
    if (user != null) {
      await user.updateDisplayName(name);
      await user.updatePhotoURL(photoUrl);
    }
  }
}
