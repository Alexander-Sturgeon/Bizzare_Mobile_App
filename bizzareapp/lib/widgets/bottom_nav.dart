import 'package:flutter/material.dart';
import 'package:bizzareapp/core/app_colors.dart';

class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  const BottomNavBar({super.key, required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: currentIndex,
      onTap: (index) => onNavItemTapped(context, currentIndex, index),
      backgroundColor: AppColors.primary,
      selectedItemColor: Colors.white,
      unselectedItemColor: Colors.white70,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
        BottomNavigationBarItem(icon: Icon(Icons.search), label: "Search"),
        BottomNavigationBarItem(icon: Icon(Icons.attach_money), label: "Sell"),
      ],
    );
  }

  void onNavItemTapped(BuildContext context, int selectedIndex, int index) {
    //don't reload it if its already the page you are on.
    if (index == selectedIndex) return;
    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, "/listView");
        break;
      case 1:
        //Search passes the Listview a param instead of opening a new page, just
        //less redundancy that way
        Navigator.pushReplacementNamed(
          context,
          "/listView",
          arguments: {'openSearch': true},
        );
        break;
      case 2:
        Navigator.pushReplacementNamed(context, "/createListing");
        break;
    }
  }
}
