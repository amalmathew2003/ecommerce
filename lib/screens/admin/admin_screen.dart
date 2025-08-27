import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:social_feed_app/screens/admin/product_add_page.dart';
import 'package:social_feed_app/screens/user/login_screen.dart';
import 'package:social_feed_app/services/authservice.dart';

class AdminScreen extends StatefulWidget {
  final String profileimage;
  final String name;
  const AdminScreen({
    super.key,
    required this.profileimage,
    required this.name,
  });

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  final Authservice authservice = Authservice();

  Future<void> userlogout() async {
    await authservice.logOut();
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const LoginScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Center(
            child: SizedBox(
              height: 100,
              width: 100,
              child: Image(image: NetworkImage(widget.profileimage)),
            ),
          ),
          Text(
            widget.name,
            style: GoogleFonts.namdhinggo(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          FloatingActionButton(
            splashColor: Colors.amberAccent,
            onPressed: userlogout,
            child: Text("logout"),
          ),
          FloatingActionButton(
            splashColor: Colors.amberAccent,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (BuildContext context) {
                    return ProductAddPage();
                  },
                ),
              );
            },
            child: Text("ADD product"),
          ),
        ],
      ),
    );
  }
}
