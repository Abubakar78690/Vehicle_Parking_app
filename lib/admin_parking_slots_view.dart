import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AdminParkingSlotsView extends StatefulWidget {
  @override
  _AdminParkingSlotsViewState createState() => _AdminParkingSlotsViewState();
}

class _AdminParkingSlotsViewState extends State<AdminParkingSlotsView> with SingleTickerProviderStateMixin {
  late Future<List<Map<String, dynamic>>> _parkingSlotsFuture;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _parkingSlotsFuture = fetchParkingSlots();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..repeat(reverse: true);
  }

  Future<List<Map<String, dynamic>>> fetchParkingSlots() async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('slots').get();
      return snapshot.docs.map((doc) {
        return {
          'id': doc.id,
          'status': doc['status'],
          'vehicleId': doc['vehicleId'] ?? '',
        };
      }).toList();
    } catch (e) {
      print("Error fetching parking slots: $e");
      return [];
    }
  }

  Widget buildSlotCard(Map<String, dynamic> slot, int index) {
    bool isOccupied = slot['status'] == 'occupied';
    bool isPreBooked = slot['status'] == 'pre-booked';
    Color slotColor = isOccupied
        ? Colors.redAccent
        : isPreBooked
        ? Colors.yellowAccent
        : Colors.greenAccent;
    String slotText = isOccupied
        ? slot['vehicleId']
        : isPreBooked
        ? "Pre-Booked: ${slot['vehicleId']}"
        : "Available";

    return FadeTransition(
      opacity: _animationController.drive(
        Tween<double>(begin: 0.0, end: 1.0).chain(CurveTween(curve: Interval(0.1 * index, 1.0, curve: Curves.easeIn))),
      ),
      child: Card(
        elevation: 6,
        shadowColor: Colors.black.withOpacity(0.3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isOccupied
                  ? [Colors.redAccent.shade400, Colors.redAccent.shade700]
                  : isPreBooked
                  ? [Colors.yellowAccent.shade400, Colors.yellowAccent.shade700]
                  : [Colors.greenAccent.shade400, Colors.greenAccent.shade700],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              slotText,
              style: const TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    _animationController.forward(); // Trigger the animations

    return Scaffold(
      body: Stack(
        children: [
          // Background Image
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/view.jpg'), // Replace with your background image
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Foreground Content
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40), // Add margin from top
              Center(
                child: BouncingTextWidget(
                  text: "Parking Slots Overview",
                  textStyle: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 20), // Space between title and grid
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: FutureBuilder<List<Map<String, dynamic>>>(
                    future: _parkingSlotsFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(
                            color: Colors.blueAccent,
                          ),
                        );
                      } else if (snapshot.hasError) {
                        return const Center(
                          child: Text(
                            "Error loading slots.",
                            style: TextStyle(fontSize: 16, color: Colors.white),
                          ),
                        );
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Center(
                          child: Text(
                            "No parking slots found.",
                            style: TextStyle(fontSize: 16, color: Colors.white),
                          ),
                        );
                      }

                      final slots = snapshot.data!;
                      return GridView.builder(
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 4, // Adjust the number of slots per row
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                        ),
                        itemCount: slots.length,
                        itemBuilder: (context, index) {
                          return buildSlotCard(slots[index], index);
                        },
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
}

class BouncingTextWidget extends StatefulWidget {
  final String text;
  final TextStyle textStyle;

  const BouncingTextWidget({
    Key? key,
    required this.text,
    required this.textStyle,
  }) : super(key: key);

  @override
  _BouncingTextWidgetState createState() => _BouncingTextWidgetState();
}

class _BouncingTextWidgetState extends State<BouncingTextWidget> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 0, end: 15).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _animation.value),
          child: Text(
            widget.text,
            style: widget.textStyle,
            textAlign: TextAlign.center,
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
