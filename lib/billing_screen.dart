import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class BillingScreen extends StatelessWidget {
  final TextEditingController _registrationNumberController = TextEditingController();

  BillingScreen({super.key});

  Future<Map<String, dynamic>> calculateBill(String registrationNumber) async {
    final vehicle = await FirebaseFirestore.instance
        .collection('vehicles_exited')
        .where('registrationNumber', isEqualTo: registrationNumber)
        .get();

    if (vehicle.docs.isEmpty) throw "Vehicle not found.";

    final data = vehicle.docs.first.data();
    final entryTime = (data['entryTime'] as Timestamp).toDate();
    final exitTime = (data['exitTime'] as Timestamp).toDate();
    final duration = exitTime.difference(entryTime).inMinutes;

    return {
      'slot': data['assignedSlot'],
      'entryTime': entryTime,
      'exitTime': exitTime,
      'bill': duration * 2.0, // Example: Rs 2/minute
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Image
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/car.jpg'), // Replace with your background image
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Foreground Content
          Column(
            mainAxisAlignment: MainAxisAlignment.start, // Align widgets at the top
            crossAxisAlignment: CrossAxisAlignment.center, // Center widgets horizontally
            children: [
              const SizedBox(height: 60), // Adjust this for space from the top
              const BouncingTextWidget(
                text: "Billing and Payments",
                textStyle: TextStyle(
                  fontSize: 28,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 30),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: TextField(
                  controller: _registrationNumberController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.black.withOpacity(0.6),
                    hintText: "Enter Registration Number",
                    hintStyle: const TextStyle(color: Colors.white54),
                    prefixIcon: const Icon(Icons.car_repair, color: Colors.white),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: const BorderSide(color: Colors.blue),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: const BorderSide(color: Colors.lightBlueAccent),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.7, // Button occupies 90% width
                child: ElevatedButton(
                  onPressed: () async {
                    try {
                      final details = await calculateBill(_registrationNumberController.text);
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          backgroundColor: Colors.blueGrey,
                          title: const Text(
                            "Calculate Bill",
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Time Span: ${details['entryTime']} - ${details['exitTime']}",
                                style: const TextStyle(color: Colors.white, fontSize: 18),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                "Slot Assigned: ${details['slot']}",
                                style: const TextStyle(color: Colors.white, fontSize: 18),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                "Bill: Rs ${details['bill'].toStringAsFixed(2)}",
                                style: const TextStyle(color: Colors.white, fontSize: 18),
                              ),
                            ],
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: const Text(
                                "OK",
                                style: TextStyle(
                                    color: Colors.blue,
                                  fontSize: 20
                                ),
                              ),
                            ),


                          ],
                        ),
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(e.toString())),
                      );
                    }
                  },

                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.lightBlueAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 15.0),
                    shadowColor: Colors.blue,
                    elevation: 10,
                  ),
                  child: const Text(
                    "Calculate Bill",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class BouncingTextWidget extends StatefulWidget {
  final String text;
  final TextStyle textStyle;

  const BouncingTextWidget({
    super.key,
    required this.text,
    required this.textStyle,
  });

  @override
  State<BouncingTextWidget> createState() => _BouncingTextWidgetState();
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
