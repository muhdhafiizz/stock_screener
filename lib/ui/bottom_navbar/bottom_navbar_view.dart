import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stock_screener/ui/bottom_navbar/bottom_navbar_controller.dart';
import 'package:stock_screener/ui/home_page/home_page.dart';
import 'package:stock_screener/ui/profile_page/profile_page_view.dart';



class BottomNavView extends StatelessWidget {
  BottomNavView({super.key});

  final List<Widget> _screens = [
    const HomePage(),
    const ProfileView(),
  ];

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<BottomNavController>(context);

    return Scaffold(
      body: _screens[controller.selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: controller.selectedIndex,
        onTap: controller.changeTab,
        selectedItemColor: Colors.green[500],
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }
}
