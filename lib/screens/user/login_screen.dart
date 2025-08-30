import 'dart:math';
import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:social_feed_app/const/color_const.dart';
import 'package:social_feed_app/screens/admin/admin_screen.dart';
import 'package:social_feed_app/screens/user/home/home_screen.dart';

import 'package:social_feed_app/screens/profile_screen.dart';
import 'package:social_feed_app/screens/signup_screen.dart';
import 'package:social_feed_app/services/authservice.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController emailCrl = TextEditingController();
  final TextEditingController passwordCrl = TextEditingController();
  final Authservice authservice = Authservice();

  bool isLoading = false;

  Future<void> _checkLoginOrNot() async {
    if (_formKey.currentState!.validate()) {
      setState(() => isLoading = true);
      try {
        final user = await authservice.login(
          emailCrl.text.trim(),
          passwordCrl.text.trim(),
        );

        if (user != null) {
          if (!mounted) return;

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Welcome back, ${user.email}!")),
          );

          // Get user data from Firestore
          final snapshot = await FirebaseFirestore.instance
              .collection("users")
              .doc(user.uid)
              .get();

          if (snapshot.exists) {
            final data = snapshot.data()!;
            final role = data['role'] ?? 'user';
            final name = data['name'];
            final photoUrl = data['photoUrl'];
            final email = data['email'];

            // If either name or photoUrl is missing, go to ProfileSetupScreen
            final isProfileIncomplete =
                name == null ||
                name.toString().isEmpty ||
                photoUrl == null ||
                photoUrl.toString().isEmpty;

            if (isProfileIncomplete) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => ProfileSetupScreen()),
              );
            } else if (role == "admin") {
              // Admin dashboard
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      AdminScreen(profileimage: photoUrl, name: name),
                ),
              );
            } else {
              // Normal user with completed profile
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => HomeScreen(
                    profileimage: photoUrl,
                    username: name,
                    email: email,
                  ),
                  // HomeScreen(
                  //   profileimage: photoUrl,
                  //   name: name,
                  //   email: email,
                  // ),
                ),
              );
            }
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(e.toString())));
        }
      } finally {
        setState(() => isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // black theme background
      body: Center(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15), // blur effect
            child: Container(
              width: 320,
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
                      "Login",
                      style: GoogleFonts.namdhinggo(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: ColorConst.primaryLight,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Email field
                    TextFormField(
                      controller: emailCrl,
                      style: GoogleFonts.namdhinggo(
                        color: ColorConst.primaryLight,
                      ),
                      decoration: InputDecoration(
                        hintText: "Email",
                        hintStyle: GoogleFonts.namdhinggo(
                          color: ColorConst.primaryLight70,
                        ),
                        prefixIcon: Icon(
                          Icons.email,
                          color: ColorConst.primaryLight,
                        ),
                        filled: true,
                        fillColor: ColorConst.primaryLight.withValues(
                          alpha: .05,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      validator: (value) =>
                          value!.isEmpty ? "Enter your email" : null,
                    ),
                    const SizedBox(height: 15),

                    // Password field
                    TextFormField(
                      onFieldSubmitted: (value) {
                        _checkLoginOrNot();
                      },
                      controller: passwordCrl,

                      obscureText: true,
                      style: GoogleFonts.namdhinggo(
                        color: ColorConst.primaryLight,
                      ),

                      decoration: InputDecoration(
                        hintText: "Password",
                        hintStyle: GoogleFonts.namdhinggo(
                          color: ColorConst.primaryLight70,
                        ),
                        prefixIcon: Icon(
                          Icons.lock,
                          color: ColorConst.primaryLight,
                        ),
                        filled: true,
                        fillColor: ColorConst.primaryLight.withValues(
                          alpha: .05,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      validator: (value) =>
                          value!.isEmpty ? "Enter your password" : null,
                    ),
                    const SizedBox(height: 20),

                    // Login button
                    isLoading
                        ? const CircularProgressIndicator()
                        : ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: ColorConst.secondary,
                              foregroundColor: ColorConst.primaryLight,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              minimumSize: const Size(double.infinity, 50),
                            ),
                            onPressed: _checkLoginOrNot,
                            child: Text(
                              "Login",
                              style: GoogleFonts.namdhinggo(
                                color: ColorConst.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                    const SizedBox(height: 10),

                    // Signup redirect
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          PageRouteBuilder(
                            pageBuilder:
                                (context, animation, secondaryAnimation) =>
                                    const SignupScreen(),
                            transitionsBuilder:
                                (
                                  context,
                                  animation,
                                  secondaryAnimation,
                                  child,
                                ) {
                                  return FadeTransition(
                                    opacity: animation,
                                    child: child,
                                  );
                                },
                            transitionDuration: const Duration(
                              milliseconds: 500,
                            ),
                          ),
                        );
                      },
                      child: Text(
                        "Don't have an account? Register",
                        style: GoogleFonts.namdhinggo(
                          color: ColorConst.secondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
