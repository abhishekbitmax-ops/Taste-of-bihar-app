import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:restro_app/Modules/Dashboard/view/dsahboard.dart';
import 'package:restro_app/Modules/Dashboard/view/menuscreen.dart';
import 'package:restro_app/Modules/Navbar/cartcontroller.dart';
import 'package:restro_app/Modules/ProfileSection/view/Profile.dart';
import 'package:restro_app/widgets/Comingsoon.dart';

class BottomNavBar extends StatefulWidget {
  final int initialIndex; // ✔ initial index support

  const BottomNavBar({super.key, this.initialIndex = 0}); // default

  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  late int selectedIndex;
  

  final List<Widget> screens = [
    const FoodHomeScreen(),
    const ComingSoonScreen(),
    MenuScreen(),
    ProfileHomeScreen(),
  ];

  @override
  void initState() {
    super.initState();
    Get.find<CartController>().fetchCartApi();
    selectedIndex = widget.initialIndex; //  apply initial index
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (selectedIndex != 0) {
          setState(() {
            selectedIndex = 0; // Pehle Home par lao
          });
          return false;
        } else {
          return await showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text(
                "Exit App?",
                style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
              ),
              content: Text(
                "Do you want to exit the application?",
                style: GoogleFonts.poppins(),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text(
                    "No",
                    style: GoogleFonts.poppins(color: Colors.black54),
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: Text(
                    "Yes",
                    style: GoogleFonts.poppins(color: const Color(0xFF8B0000)),
                  ),
                ),
              ],
            ),
          );
        }
      },
      child: Scaffold(
        body: screens[selectedIndex],
        bottomNavigationBar: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                blurRadius: 10,
                offset: Offset(0, -2),
                color: Colors.black12,
              ),
            ],
          ),
          child: BottomNavigationBar(
            currentIndex: selectedIndex,
            onTap: (index) {
              setState(() {
                selectedIndex = index;
              });
            },
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.white,
            selectedItemColor: const Color(0xFF8B0000),
            unselectedItemColor: Colors.black54,
            selectedLabelStyle: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
            unselectedLabelStyle: GoogleFonts.poppins(
              fontWeight: FontWeight.w500,
              fontSize: 11,
            ),
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home, size: 26),
                label: "Home",
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.local_offer, size: 26),
                label: "Dine -In",
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.shopping_cart, size: 26),
                label: "Menu",
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person, size: 26),
                label: "Profile",
              ),
            ],
          ),
        ),
      ),
    );
  }
}
