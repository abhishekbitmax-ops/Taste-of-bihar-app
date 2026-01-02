import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:restro_app/Modules/Navbar/cartcontroller.dart';
import 'package:restro_app/Modules/Navbar/navbar.dart';
import 'package:restro_app/widgets/Addtocartbottom.dart';
import 'package:restro_app/widgets/Viewcartbar.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  String foodFilter = "all"; // all, veg, nonveg
  String selectedCategory = "Celebration";

  final List<Map<String, String>> categories = [
    {"name": "Celebration", "image": "assets/images/popular.png"},
    {"name": "Burgers", "image": "assets/images/popular.png"},
    {"name": "Korean", "image": "assets/images/popular.png"},
    {"name": "Cafe", "image": "assets/images/popular.png"},
    {"name": "Deals", "image": "assets/images/popular.png"},
  ];

  final Map<String, List<Map<String, String>>> products = {
    "Celebration": [
      {
        "name": "Classic Chicken Meal For 2",
        "desc": "2 BK Chicken + 2 Coca Cola\nMedium + Saucy Fries + 2 Showing",
        "cut_price": "₹671",
        "price": "₹399",
        "image": "assets/images/popular.png",
        "type": "nonveg",
      },
    ],
    "Burgers": [
      {
        "name": "Paneer Whopper Meal For 2",
        "desc": "Qty: 838 Gms, 600 ML\nKcal: 2108",
        "cut_price": "₹731",
        "price": "₹499",
        "image": "assets/images/popular.png",
        "type": "veg",
      },
      {
        "name": "Korean Spicy Paneer Meal For 1",
        "desc": "Qty: 500 Gms, 300 ML\nKcal: 1500",
        "cut_price": "₹484",
        "price": "₹299",
        "image": "assets/images/popular.png",
        "type": "veg",
      },
    ],
    "Korean": [
      {
        "name": "Korean Spicy Chicken Meal For 2",
        "desc": "Qty: 838 Gms, 600 ML\nKcal: 2108",
        "cut_price": "₹989",
        "price": "₹699",
        "image": "assets/images/popular.png",
        "type": "nonveg",
      },
    ],
    "Cafe": [
      {
        "name": "BK Cafe Special",
        "desc": "Hot Coffee + Choco Lava",
        "cut_price": "₹350",
        "price": "₹199",
        "image": "assets/images/popular.png",
        "type": "veg",
      },
    ],
    "Deals": [
      {
        "name": "Korean Spicy Paneer Meal For 1",
        "desc": "Paneer Burger + French Fries",
        "cut_price": "₹450",
        "price": "₹299",
        "image": "assets/images/popular.png",
        "type": "veg",
      },
    ],
  };

  @override
  Widget build(BuildContext context) {
    final productList = products[selectedCategory] ?? [];

    final filtered = foodFilter == "all"
        ? productList
        : productList.where((p) => p["type"] == foodFilter).toList();

    return Scaffold(
      bottomNavigationBar: ZomatoCartBar(),
      backgroundColor: const Color(0xFF8B0000),
      appBar: AppBar(
        backgroundColor: const Color(0xFF8B0000),
        title: const Text("Our Menu", style: TextStyle(color: Colors.white)),
        actions: const [
          Icon(Icons.search, color: Colors.white),
          SizedBox(width: 12),
        ],
      ),
      body: SafeArea(
        child: Row(
          children: [
            // LEFT CATEGORY MENU
            Container(
              width: 110,
              color: Colors.white,
              child: ListView.builder(
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final category = categories[index];
                  bool isSelected = selectedCategory == category["name"];
                  return InkWell(
                    onTap: () {
                      setState(() => selectedCategory = category["name"]!);
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(
                        vertical: 6,
                        horizontal: 6,
                      ),
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFF8B0000)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Column(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.asset(
                              category["image"]!,
                              height: 40,
                              width: 40,
                              fit: BoxFit.cover,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            category["name"]!,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: isSelected
                                  ? Colors.white
                                  : const Color(0xFF8B0000),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            // RIGHT PRODUCT LIST + FILTER BUTTONS
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(10),
                color: Colors.white,
                child: Column(
                  children: [
                    // FILTER BUTTONS
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Row(
                        children: [
                          _filterButton("All", "all"),
                          const SizedBox(width: 8),
                          _filterButton("Veg", "veg"),
                          const SizedBox(width: 8),
                          _filterButton("Non-Veg", "nonveg"),
                        ],
                      ),
                    ),

                    // PRODUCT LIST
                    Expanded(
                      child: ListView.builder(
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          final product = filtered[index];
                          return Container(
                            margin: const EdgeInsets.only(bottom: 16),
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(18),
                              boxShadow: [
                                BoxShadow(
                                  blurRadius: 6,
                                  spreadRadius: 1,
                                  offset: const Offset(0, 3),
                                  color: Colors.black.withOpacity(0.15),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(14),
                                  child: Image.asset(
                                    product["image"]!,
                                    height: 140,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  product["name"]!,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  product["desc"]!,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.black54,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          product["cut_price"]!,
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Colors.red,
                                            decoration:
                                                TextDecoration.lineThrough,
                                          ),
                                        ),
                                        Text(
                                          product["price"]!,
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            color: Color(0xFF8B0000),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 7,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF8B0000),
                                        borderRadius: BorderRadius.circular(30),
                                      ),
                                      child: InkWell(
                                        onTap: () => openProductBottomSheet(
                                          context,
                                          product,
                                        ),
                                        child: const Text(
                                          "Add +",
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // FILTER BUTTON WIDGET
  Widget _filterButton(String label, String value) {
    bool isActive = foodFilter == value;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => foodFilter = value),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isActive ? const Color(0xFF8B0000) : Colors.grey.shade200,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: isActive ? Colors.white : Colors.black,
            ),
          ),
        ),
      ),
    );
  }
}
