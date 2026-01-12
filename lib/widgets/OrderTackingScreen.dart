import 'package:flutter/material.dart';

class TrackingScreen extends StatelessWidget {
  const TrackingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5F7FB),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Bar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const BackButton(),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.settings),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              const Text(
                "Tracking",
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 16),

              _trackingCard(),

              const SizedBox(height: 16),

              _timelineCard(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _trackingCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text("492K1LAP2", style: TextStyle(color: Colors.grey)),
              Icon(Icons.keyboard_arrow_down),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            "Macbook Pro 2018 - 15\"",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [Text("01 Jan, '20"), Text("07 Jan, '20")],
          ),
          const SizedBox(height: 8),

          Row(
            children: [
              const Text("İzmir", style: TextStyle(color: Colors.blue)),
              Expanded(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    const Divider(thickness: 1),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: Colors.deepPurple,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.local_shipping,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ],
                ),
              ),
              const Text("NYC", style: TextStyle(color: Colors.blue)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _timelineCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          _timelineItem(
            date: "01 Jan, '20",
            time: "10:20 AM",
            title: "Pick-up",
            location: "Izmir, Turkey",
            isActive: true,
          ),
          _timelineItem(
            date: "04 Jan, '20",
            time: "08:00 AM",
            title: "Dispatched",
            location: "Istanbul, Turkey",
          ),
          _timelineItem(
            date: "07 Jan, '20",
            time: "08:00 AM",
            title: "Arrived to USA",
            location: "NYC, USA",
          ),
          _timelineItem(
            date: "09 Jan, '20",
            time: "04:20 PM",
            title: "In Transit",
            location: "NYC, USA",
            isCompleted: true,
          ),
        ],
      ),
    );
  }

  Widget _timelineItem({
    required String date,
    required String time,
    required String title,
    required String location,
    bool isActive = false,
    bool isCompleted = false,
  }) {
    Color dotColor = isCompleted
        ? Colors.green
        : isActive
        ? Colors.deepPurple
        : Colors.grey;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: dotColor,
                shape: BoxShape.circle,
              ),
            ),
            Container(width: 2, height: 50, color: Colors.grey.shade300),
          ],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "$date  $time",
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
              const SizedBox(height: 4),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              Text(location, style: const TextStyle(color: Colors.grey)),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ],
    );
  }
}
