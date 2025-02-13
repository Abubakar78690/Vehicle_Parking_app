import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class VehicleEntryExitScreen extends StatefulWidget {
  @override
  _VehicleEntryExitScreenState createState() => _VehicleEntryExitScreenState();
}

class _VehicleEntryExitScreenState extends State<VehicleEntryExitScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _vehicleModelyearController = TextEditingController();
  final TextEditingController _vehicleMakeController = TextEditingController();
  final TextEditingController _vehicleModelController = TextEditingController();
  final TextEditingController _registrationNumberController = TextEditingController();

  late AnimationController _animationController;

  String _selectedVehicleType = 'Sedan'; // Default dropdown value
  final List<String> _vehicleTypes = [
    'Sedan', 'Hatchback', 'SUV', 'Convertible', 'Coupe', 'Pickup', 'Van', 'Bike',
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> logVehicleEntry() async {
    try {
      var slotSnapshot = await FirebaseFirestore.instance
          .collection('slots')
          .where('status', isEqualTo: 'available')
          .limit(1)
          .get();

      if (slotSnapshot.docs.isEmpty) {
        _showAlertDialog('Parking Full', 'No parking slots available. Try again later.');
        return;
      }

      var slotDoc = slotSnapshot.docs.first;
      String assignedSlotId = slotDoc.id;

      await FirebaseFirestore.instance.collection('slots').doc(assignedSlotId).update({
        'status': 'occupied',
        'vehicleId': _registrationNumberController.text.trim(),
      });

      await FirebaseFirestore.instance.collection('vehicles_entered').add({
        'vehicleMake': _vehicleMakeController.text.trim(),
        'vehicleModel': _vehicleModelController.text.trim(),
        'vehicleModelyear': _vehicleModelyearController.text.trim(),
        'registrationNumber': _registrationNumberController.text.trim(),
        'vehicleType': _selectedVehicleType,
        'assignedSlot': assignedSlotId,
        'entryTime': Timestamp.now(),
      });

      _showAlertDialog('Success', 'Vehicle logged successfully! Slot assigned: $assignedSlotId');
      _clearFields();
    } catch (e) {
      _showAlertDialog('Error', 'Failed to log vehicle entry: $e');
    }
  }

  void _showAlertDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title, style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("OK", style: TextStyle(color: Colors.blue)),
          ),
        ],
      ),
    );
  }

  void _clearFields() {
    _vehicleModelyearController.clear();
    _vehicleMakeController.clear();
    _vehicleModelController.clear();
    _registrationNumberController.clear();
    setState(() {
      _selectedVehicleType = 'Sedan';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/night_parking.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Center(
            child: Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedBuilder(
                    animation: _animationController,
                    builder: (context, child) {
                      return Transform.translate(
                        offset: Offset(0, -10 * _animationController.value),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.directions_car, color: Colors.blue, size: 30),
                            const SizedBox(width: 10),
                            Text(
                              "Vehicle Entry",
                              style: TextStyle(
                                fontSize: 30,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: 2.0,
                                fontFamily: 'Roboto',
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 30),
                  buildTextField(_vehicleMakeController, "Vehicle Make", Icons.directions_car),
                  const SizedBox(height: 20),
                  buildTextField(_vehicleModelController, "Model", Icons.drive_eta),
                  const SizedBox(height: 20),
                  buildTextField(_vehicleModelyearController, "Model Year", Icons.calendar_today),
                  const SizedBox(height: 20),
                  buildTextField(
                      _registrationNumberController, "Registration Number", Icons.confirmation_number),
                  const SizedBox(height: 10),
                  buildDropdownButton(),
                  const SizedBox(height: 20),
                  buildLogButton(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildTextField(TextEditingController controller, String label, IconData icon) {
    return TextField(
      controller: controller,
      style: const TextStyle(color: Colors.blueGrey),
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.blueGrey),
        labelText: label,
        labelStyle: const TextStyle(
            color: Colors.blueGrey,
          fontWeight:FontWeight.bold,
          fontSize: 18,

        ),
        enabledBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.blueGrey),
        ),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.blue),
        ),
      ),
    );
  }

  Widget buildDropdownButton() {
    return DropdownButtonFormField<String>(
      value: _selectedVehicleType,
      items: _vehicleTypes.map((type) {
        return DropdownMenuItem(
          value: type,
          child: Text(type, style: const TextStyle(fontWeight:FontWeight.bold,color: Colors.blueGrey)),
        );
      }).toList(),
      onChanged: (value) => setState(() => _selectedVehicleType = value!),
      decoration: const InputDecoration(
        prefixIcon: Icon(Icons.directions_car, color: Colors.blueGrey),
        labelText: "Vehicle Type",
        labelStyle: TextStyle(fontSize:22,fontWeight: FontWeight.bold,color: Colors.blueGrey),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.blueGrey),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.blue),
        ),
      ),
      dropdownColor: Colors.black,
    );
  }

  Widget buildLogButton() {
    return SizedBox(
      width: double.infinity, // Made button take full width
      child: ElevatedButton(
        onPressed: logVehicleEntry,
        child: const Text(
          "Log Vehicle Entry",
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30.0),
          ),
          padding: const EdgeInsets.symmetric(vertical: 15.0),
          shadowColor: Colors.blue.withOpacity(0.5),
          elevation: 10,
        ),
      ),
    );
  }
}
