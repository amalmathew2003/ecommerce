import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:social_feed_app/const/color_const.dart';
import 'package:social_feed_app/screens/user/home/home_screen.dart';
import 'package:social_feed_app/screens/user/login_screen.dart';
import 'package:social_feed_app/screens/user/search_screen.dart';

class MainFloatingNav extends StatefulWidget {
  final String profileimage;
  final String username;
  final String email;

  const MainFloatingNav({
    super.key,
    required this.profileimage,
    required this.username,
    required this.email,
  });

  @override
  State<MainFloatingNav> createState() => _MainFloatingNavState();
}

class _MainFloatingNavState extends State<MainFloatingNav> {
  int _currentIndex = 0;

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      HomeScreen(
        profileimage: widget.profileimage,
        username: widget.username,
        email: widget.email,
      ),
      const SearchScreen(), // Search
      const Placeholder(color: Colors.green), // Notifications
      const LoginScreen(), // Profile
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true, // important to float over body
      body: Stack(
        children: [
          IndexedStack(index: _currentIndex, children: _screens),

          // floating nav bar
          Positioned(
            left: 20,
            right: 20,
            bottom: 20,
            child: _buildFloatingNav(),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingNav() {
    final items = [
      {"icon": Icons.home, "label": "Home"},
      {"icon": Icons.search, "label": "Search"},
      {"icon": Icons.notifications, "label": "Alerts"},
      {"icon": Icons.person, "label": "Profile"},
    ];

    return ClipRRect(
      borderRadius: BorderRadius.circular(30),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          height: 70,
          decoration: BoxDecoration(
            color: ColorConst.primary,
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 20,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(items.length, (index) {
              final selected = _currentIndex == index;
              final item = items[index];
              return GestureDetector(
                onTap: () => setState(() => _currentIndex = index),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: selected
                        ? Colors.orange.withOpacity(0.15)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        item["icon"] as IconData,
                        size: 26,
                        color: selected ? Colors.orange : Colors.grey.shade600,
                      ),
                      if (selected) ...[
                        const SizedBox(width: 6),
                        Text(
                          item["label"] as String,
                          style: TextStyle(
                            color: Colors.orange,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
