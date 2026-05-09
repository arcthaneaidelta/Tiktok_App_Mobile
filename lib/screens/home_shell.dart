import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/user_model.dart';
import '../providers/app_provider.dart';
import 'feed/video_feed_screen.dart';
import 'upload/upload_screen.dart';
import 'profile/profile_screen.dart';
import 'admin/admin_dashboard.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final user = provider.currentUser;
    if (user == null) return const SizedBox();

    // Super Admin goes straight to dashboard
    if (user.role == UserRole.superAdmin) {
      return const AdminDashboard();
    }

    final isCreator = user.role == UserRole.contentCreator;

    final screens = <Widget>[
      VideoFeedScreen(isScreenActive: _currentIndex == 0),
      if (isCreator) const UploadScreen(),
      const ProfileScreen(),
    ];

    final navItems = <BottomNavigationBarItem>[
      const BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Feed'),
      if (isCreator)
        const BottomNavigationBarItem(icon: Icon(Icons.add_circle_outline), label: 'Upload'),
      const BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
    ];

    return Scaffold(
      backgroundColor: Colors.black,
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      bottomNavigationBar: Theme(
        data: Theme.of(context).copyWith(
          canvasColor: const Color(0xFF1a1a2e),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (i) => setState(() => _currentIndex = i),
          selectedItemColor: Colors.pinkAccent,
          unselectedItemColor: Colors.white54,
          items: navItems,
        ),
      ),
    );
  }
}
