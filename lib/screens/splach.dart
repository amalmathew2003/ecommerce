import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:social_feed_app/screens/admin/admin_screen.dart';
import 'package:social_feed_app/screens/user/dashboard_screen.dart';
import 'package:social_feed_app/screens/user/home_screen.dart';
import 'package:social_feed_app/screens/user/login_screen.dart';

class Splach extends StatefulWidget {
  const Splach({super.key});

  @override
  State<Splach> createState() => _SplachState();
}

class _SplachState extends State<Splach> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 1), _checkLoginOrNot);
  }

  Future<void> _checkLoginOrNot() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      // get user role from Firestore
      final snapshot = await FirebaseFirestore.instance
          .collection("users")
          .doc(user.uid)
          .get();

      if (snapshot.exists) {
        final role = snapshot.data()?['role'] ?? 'user';

        if (role == 'admin') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => AdminScreen(
                profileimage: user.photoURL ?? "",
                name: user.displayName ?? "",
              ), // your admin dashboard
            ),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => HomeScreen(
                profileimage: user.photoURL ?? "",
                name: user.displayName ?? "",
                email: user.email ?? "",
              ),
            ),
          );
          // Navigator.pushReplacement(
          //   context,
          //   MaterialPageRoute(
          //     builder: (_) =>
          //         DashboardScreen(profileimage: user.photoURL ?? ""),
          //   ),
          // );
        }
      }
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Container(
          height: 500,
          width: 500,
          child: Image.asset('assets/Fauget (3).gif', width: 150, height: 150),
        ),
      ),
    );
  }
}
