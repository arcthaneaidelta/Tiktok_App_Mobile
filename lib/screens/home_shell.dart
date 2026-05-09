import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/user_model.dart';
import '../providers/app_provider.dart';
import '../theme/app_theme.dart';
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

    final navItems = <_NavItem>[
      const _NavItem(icon: Icons.home_outlined, activeIcon: Icons.home_rounded, label: 'Feed'),
      if (isCreator)
        const _NavItem(icon: Icons.add_circle_outline_rounded, activeIcon: Icons.add_circle_rounded, label: 'Upload'),
      const _NavItem(icon: Icons.person_outline_rounded, activeIcon: Icons.person_rounded, label: 'Profile'),
    ];

    return Scaffold(
      backgroundColor: Colors.black,
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      bottomNavigationBar: _GlassNavBar(
        items: navItems,
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  const _NavItem({required this.icon, required this.activeIcon, required this.label});
}

class _GlassNavBar extends StatelessWidget {
  final List<_NavItem> items;
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _GlassNavBar({
    required this.items,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        height: 68,
        decoration: const BoxDecoration(
          color: AppColors.surface,
          border: Border(top: BorderSide(color: AppColors.border)),
        ),
        child: Row(
          children: List.generate(items.length, (i) {
            final item = items[i];
            final selected = i == currentIndex;
            return Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => onTap(i),
                child: Center(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    curve: Curves.easeOut,
                    padding: EdgeInsets.symmetric(
                      horizontal: selected ? 18 : 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      gradient: selected ? AppGradients.pinkPurple : null,
                      borderRadius: BorderRadius.circular(AppRadii.pill),
                      boxShadow: selected ? AppShadows.pinkGlow : null,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          selected ? item.activeIcon : item.icon,
                          color: selected ? Colors.white : AppColors.textDim,
                          size: 24,
                        ),
                        if (selected) ...[
                          const SizedBox(width: 6),
                          Text(
                            item.label,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.4,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
