import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

class PreBookParkingSlotScreen extends StatefulWidget {
  const PreBookParkingSlotScreen({super.key});

  @override
  State<PreBookParkingSlotScreen> createState() =>
      _PreBookParkingSlotScreenState();
}

class _PreBookParkingSlotScreenState extends State<PreBookParkingSlotScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 0.8, end: 1.2).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<List<Map<String, dynamic>>> fetchAvailableSlots() async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('slots')
          .where('status', isEqualTo: 'available')
          .get();
      return snapshot.docs.map((doc) {
        return {
          'id': doc.id,
          'status': doc['status'],
        };
      }).toList();
    } catch (e) {
      print("Error fetching available slots: $e");
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/night_thunder.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Column(
            children: [
              const SizedBox(height: 80),
              AnimatedBuilder(
                animation: _animation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _animation.value,
                    child: const Center(
                      child: Text(
                        "Available Slots",
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 30),
              Expanded(
                child: FutureBuilder<List<Map<String, dynamic>>>(
                  future: fetchAvailableSlots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return const Center(child: Text("Error loading slots."));
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(
                          child: Text("No available slots for pre-booking."));
                    }

                    final availableSlots = snapshot.data!;
                    return ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: availableSlots.length,
                      itemBuilder: (context, index) {
                        final slot = availableSlots[index];
                        return Card(
                          elevation: 4,
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          color: Colors.blueGrey.shade100,
                          child: ListTile(
                            title: Text("Slot ID: ${slot['id']}"),
                            trailing: ElevatedButton(
                              onPressed: () async {
                                final result = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        VehicleEntryScreen(slotId: slot['id']),
                                  ),
                                );
                                if (result == true) {
                                  setState(() {}); // Refresh the page
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blueAccent,
                              ),
                              child: const Text(
                                "Select",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class VehicleEntryScreen extends StatefulWidget {
  final String slotId;

  const VehicleEntryScreen({required this.slotId, super.key});

  @override
  State<VehicleEntryScreen> createState() => _VehicleEntryScreenState();
}

class _VehicleEntryScreenState extends State<VehicleEntryScreen> {
  final TextEditingController makeController = TextEditingController();
  final TextEditingController modelController = TextEditingController();
  final TextEditingController modelYearController = TextEditingController();
  final TextEditingController registrationNumberController =
  TextEditingController();
  String? selectedVehicleType;

  Future<void> saveVehicleDetails(BuildContext context) async {
    try {
      await FirebaseFirestore.instance.collection('prebooked_slots').add({
        'slotId': widget.slotId,
        'make': makeController.text,
        'model': modelController.text,
        'modelYear': modelYearController.text,
        'vehicleType': selectedVehicleType,
        'registrationNumber': registrationNumberController.text,
      });

      await FirebaseFirestore.instance
          .collection('slots')
          .doc(widget.slotId)
          .update({'status': 'pre-booked'});

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text("Slot ${widget.slotId} pre-booked successfully!")),
      );
      Navigator.pop(context, true);
    } catch (e) {
      print("Error saving vehicle details: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to pre-book slot. Please try again.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/parking.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: ListView(
              children: [
                const SizedBox(height: 50),
                buildWhiteTextField(makeController, "Make"),
                const SizedBox(height: 16),
                buildWhiteTextField(modelController, "Model"),
                const SizedBox(height: 16),
                buildWhiteTextField(modelYearController, "Model Year"),
                const SizedBox(height: 16),
                buildWhiteTextField(
                    registrationNumberController, "Vehicle Registration Number"),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedVehicleType,
                  decoration: const InputDecoration(
                    labelText: "Vehicle Type",
                    labelStyle: TextStyle(color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 17,
                    ),
                    filled: true,
                    fillColor: Colors.white12,
                    border: OutlineInputBorder(),
                  ),
                  dropdownColor: Colors.blueGrey,
                  items: [
                    'Sedan',
                    'Hatchback',
                    'SUV',
                    'Crossover',
                    'Sports',
                    'Convertible',
                    'Coupe',
                    'Pickup',
                    'Van',
                    'Bike',
                  ]
                      .map((type) => DropdownMenuItem(
                    value: type,
                    child: Text(type,
                    style: TextStyle(color: Colors.white,fontSize: 17,fontWeight: FontWeight.bold),
                    ),
                  ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedVehicleType = value;
                    });
                  },
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    saveVehicleDetails(context);
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    "Save and Book Slot",
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  TextField buildWhiteTextField(
      TextEditingController controller, String label) {
    return TextField(
      controller: controller,
      style: const TextStyle(
          color: Colors.white,
        fontWeight: FontWeight.bold,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white,
          fontWeight: FontWeight.bold,),
        hintStyle: const TextStyle(color: Colors.white70,
          fontWeight: FontWeight.bold,),
        filled: true,
        fillColor: Colors.white12,
        border: const OutlineInputBorder(),
      ),
    );
  }
}
