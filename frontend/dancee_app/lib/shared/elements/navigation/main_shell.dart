import 'package:flutter/material.dart';
import 'app_bottom_nav_bar.dart';

class MainShell extends StatelessWidget {
  final NavTab currentTab;
  final Widget child;

  const MainShell({
    super.key,
    required this.currentTab,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        body: child,
        bottomNavigationBar: AppBottomNavBar(currentTab: currentTab),
      ),
    );
  }
}
