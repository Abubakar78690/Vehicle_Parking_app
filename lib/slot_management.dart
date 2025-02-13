import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class SlotManagementScreen extends StatelessWidget {
  final TextEditingController _slotIdController = TextEditingController();

  SlotManagementScreen({super.key});

  Future<void> addSlot(BuildContext context) async {
    if (_slotIdController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Slot ID cannot be empty")),
      );
      return;
    }

    final slotId = _slotIdController.text.trim();

    try {
      await FirebaseFirestore.instance.collection('slots').doc(slotId).set({
        'status': 'available',
        'vehicleId': null,
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Slot '$slotId' added successfully")),
      );
      _slotIdController.clear();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to add slot: $e")),
      );
    }
  }

  Future<void> removeSlot(BuildContext context) async {
    if (_slotIdController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Slot ID cannot be empty")),
      );
      return;
    }

    final slotId = _slotIdController.text.trim();

    try {
      await FirebaseFirestore.instance.collection('slots').doc(slotId).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Slot '$slotId' removed successfully")),
      );
      _slotIdController.clear();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to remove slot: $e")),
      );
    }
  }

  Stream<QuerySnapshot> getSlots() {
    return FirebaseFirestore.instance.collection('slots').snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/parking_slots.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Column(
            children: [
              AppBar(
                backgroundColor: Colors.blue,
                elevation: 5,
                centerTitle: true,
                title: const Text(
                  "Slot Management",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 27,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2.0,
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      _buildDecoratedContainer(
                        child: TextField(
                          controller: _slotIdController,
                          style: const TextStyle(color: Colors.black),
                          decoration: InputDecoration(
                            labelText: "Enter Slot ID",
                            labelStyle: TextStyle(color: Colors.grey.shade700),
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.grey.shade400),
                            ),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.teal),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildActionButton(
                            label: "Add Slot",
                            onTap: () => addSlot(context),
                            color: Colors.green,
                          ),
                          _buildActionButton(
                            label: "Remove Slot",
                            onTap: () => removeSlot(context),
                            color: Colors.red,
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Expanded(
                        child: _buildDecoratedContainer(
                          child: StreamBuilder<QuerySnapshot>(
                            stream: getSlots(),
                            builder: (context, snapshot) {
                              if (!snapshot.hasData) {
                                return const Center(
                                  child: CircularProgressIndicator(color: Colors.teal),
                                );
                              }
                              final slots = snapshot.data!.docs;

                              if (slots.isEmpty) {
                                return const Center(
                                  child: Text(
                                    "No slots available.",
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 16,
                                    ),
                                  ),
                                );
                              }

                              return ListView.builder(
                                itemCount: slots.length,
                                itemBuilder: (context, index) {
                                  final slot = slots[index];
                                  final isPreBooked = slot['status'] == 'pre-booked';

                                  return Card(
                                    elevation: 5,
                                    color: isPreBooked ? Colors.yellow.withOpacity(0.8) : Colors.blueGrey.withOpacity(0.8),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: ListTile(
                                      tileColor: Colors.white.withOpacity(0.9),
                                      title: Text(
                                        "Slot ID: ${slot.id}",
                                        style: const TextStyle(color: Colors.black87),
                                      ),
                                      subtitle: Text(
                                        "Status: ${isPreBooked ? 'Pre-Booked' : slot['status']}",
                                        style: const TextStyle(color: Colors.grey),
                                      ),
                                      trailing: Text(
                                        isPreBooked
                                            ? "Pre-Booked"
                                            : slot['vehicleId'] != null
                                            ? "Occupied"
                                            : "Available",
                                        style: TextStyle(
                                          color: isPreBooked
                                              ? Colors.orange
                                              : slot['vehicleId'] != null
                                              ? Colors.red
                                              : Colors.green,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    )

                                  );
                                },
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDecoratedContainer({required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.85),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: child,
      ),
    );
  }

  Widget _buildActionButton({
    required String label,
    required VoidCallback onTap,
    required Color color,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.4),
              blurRadius: 15,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
