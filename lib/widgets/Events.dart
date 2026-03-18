import 'package:flutter/material.dart';

class PartyItemsScreen extends StatelessWidget {
  final String partyType;

  const PartyItemsScreen({super.key, required this.partyType});

  List<Map<String, dynamic>> getItems() {

    if (partyType == "Birthday Party") {
      return [
        {"name": "Birthday Cake", "price": 799},
        {"name": "Balloon Decoration", "price": 999},
        {"name": "DJ Music", "price": 2000},
        {"name": "Veg Food Package", "price": 499},
      ];
    }

    if (partyType == "Kitti Party") {
      return [
        {"name": "Snacks Platter", "price": 599},
        {"name": "Mocktail Drinks", "price": 399},
        {"name": "Group Seating Setup", "price": 999},
        {"name": "Ladies Special Menu", "price": 699},
      ];
    }

    if (partyType == "Anniversary Party") {
      return [
        {"name": "Couple Cake", "price": 999},
        {"name": "Candle Light Setup", "price": 1999},
        {"name": "Romantic Decoration", "price": 2499},
        {"name": "Special Dinner", "price": 799},
      ];
    }

    return [];
  }

  @override
  Widget build(BuildContext context) {

    final items = getItems();

    return Scaffold(
      appBar: AppBar(
        title: Text(partyType),
      ),
      body: ListView.builder(
        itemCount: items.length,
        itemBuilder: (context, index) {

          final item = items[index];

          return ListTile(
            title: Text(item["name"]),
            trailing: Text("₹${item["price"]}"),
          );
        },
      ),
    );
  }
}