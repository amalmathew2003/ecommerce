import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:social_feed_app/const/color_const.dart';
import 'package:social_feed_app/screens/profile_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController nameCtrl = TextEditingController();
  final TextEditingController emailCtrl = TextEditingController();
  final TextEditingController passCtrl = TextEditingController();
  final TextEditingController confirmPassCtrl = TextEditingController();

  bool isLoading = false;

  // 👇 States for password visibility
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  Future<void> _signUp() async {
    if (!_formKey.currentState!.validate()) return;

    if (passCtrl.text.trim() != confirmPassCtrl.text.trim()) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Passwords do not match")));
      return;
    }

    try {
      setState(() => isLoading = true);

      // inside _signUp()

      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
            email: emailCtrl.text.trim(),
            password: passCtrl.text.trim(),
          );

      // Update display name
      await userCredential.user?.updateDisplayName(nameCtrl.text.trim());

      // 👇 Save user to Firestore with default role
      await FirebaseFirestore.instance
          .collection("users")
          .doc(userCredential.user!.uid)
          .set({
            "name": nameCtrl.text.trim(),
            "email": emailCtrl.text.trim(),
            "role": "user", // default
            "imageUrl": "", // optional for later
          });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Account created successfully")),
      );

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (BuildContext context) {
            return ProfileSetupScreen();
          },
        ),
      );
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.message ?? "Signup failed")));
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // match login theme
      body: Center(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
            child: Container(
              width: 340,
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
                      "Sign Up",
                      style: GoogleFonts.namdhinggo(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: ColorConst.primaryLight,
                      ),
                    ),
                    const SizedBox(height: 20),

                    _buildTextField(
                      Icons.person,
                      "Full Name",
                      controller: nameCtrl,
                      validator: (v) =>
                          v!.isEmpty ? "Enter your full name" : null,
                    ),
                    const SizedBox(height: 15),

                    _buildTextField(
                      Icons.email,
                      "Email",
                      controller: emailCtrl,
                      validator: (v) => v!.isEmpty ? "Enter your email" : null,
                    ),
                    const SizedBox(height: 15),

                    _buildTextField(
                      Icons.lock,
                      "Password",
                      controller: passCtrl,
                      isPassword: true,
                      isVisible: _isPasswordVisible,
                      onToggle: () => setState(
                        () => _isPasswordVisible = !_isPasswordVisible,
                      ),
                      validator: (v) => v!.length < 6
                          ? "Password must be at least 6 chars"
                          : null,
                    ),
                    const SizedBox(height: 15),

                    _buildTextField(
                      Icons.lock_outline,
                      "Confirm Password",
                      controller: confirmPassCtrl,
                      isPassword: true,
                      isVisible: _isConfirmPasswordVisible,
                      onToggle: () => setState(
                        () => _isConfirmPasswordVisible =
                            !_isConfirmPasswordVisible,
                      ),
                      validator: (v) =>
                          v!.isEmpty ? "Confirm your password" : null,
                    ),
                    const SizedBox(height: 20),

                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ColorConst.secondary,
                        foregroundColor: ColorConst.primaryLight,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        minimumSize: const Size(double.infinity, 50),
                      ),
                      onPressed: isLoading ? null : _signUp,
                      child: isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : Text(
                              "Sign Up",
                              style: GoogleFonts.namdhinggo(
                                color: ColorConst.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                    const SizedBox(height: 10),

                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        "Already have an account? Login",
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

  Widget _buildTextField(
    IconData icon,
    String hint, {
    bool isPassword = false,
    bool isVisible = false,
    VoidCallback? onToggle,
    TextEditingController? controller,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword ? !isVisible : false,
      style: GoogleFonts.namdhinggo(color: ColorConst.primaryLight),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.namdhinggo(color: ColorConst.primaryLight70),
        prefixIcon: Icon(icon, color: ColorConst.primaryLight),
        suffixIcon: isPassword
            ? IconButton(
                onPressed: onToggle,
                icon: Icon(
                  isVisible ? Icons.visibility : Icons.visibility_off,
                  color: ColorConst.primaryLight,
                ),
              )
            : null,
        filled: true,
        fillColor: ColorConst.primaryLight.withValues(alpha: .05),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
      validator: validator,
    );
  }
}
