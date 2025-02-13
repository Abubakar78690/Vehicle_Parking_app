import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class VehicleExitScreen extends StatefulWidget {
  @override
  _VehicleExitScreenState createState() => _VehicleExitScreenState();
}

class _VehicleExitScreenState extends State<VehicleExitScreen> with SingleTickerProviderStateMixin {
  final TextEditingController _registrationNumberController = TextEditingController();
  Map<String, dynamic>? _vehicleDetails;
  AnimationController? _animationController;
  Animation<Offset>? _animationOffset;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 1),
    )..repeat(reverse: true);
    _animationOffset = Tween<Offset>(
      begin: Offset(0.0, -0.5),
      end: Offset(0.0, 0.0),
    ).animate(CurvedAnimation(
      parent: _animationController!,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController?.dispose();
    super.dispose();
  }

  Future<void> fetchVehicleDetails() async {
    String registrationNumber = _registrationNumberController.text.trim();

    if (registrationNumber.isEmpty) {
      _showAlertDialog('Input Error', 'Please enter the Registration Number.');
      return;
    }

    try {
      var vehicleQuery = await FirebaseFirestore.instance
          .collection('vehicles_entered')
          .where('registrationNumber', isEqualTo: registrationNumber)
          .get();

      if (vehicleQuery.docs.isEmpty) {
        _showAlertDialog('Not Found', 'Vehicle not found, try again.');
        setState(() {
          _vehicleDetails = null;
        });
        return;
      }

      setState(() {
        _vehicleDetails = vehicleQuery.docs.first.data();
        _vehicleDetails!['id'] = vehicleQuery.docs.first.id;
      });
    } catch (e) {
      _showAlertDialog('Error', 'Failed to fetch vehicle details: $e');
    }
  }

  Future<void> logVehicleExit() async {
    if (_vehicleDetails == null) {
      _showAlertDialog('Error', 'No vehicle details found to exit.');
      return;
    }

    String registrationNumber = _vehicleDetails!['registrationNumber'];
    String slotId = _vehicleDetails!['assignedSlot'];

    try {
      // Update slot status
      await FirebaseFirestore.instance.collection('slots').doc(slotId).update({
        'status': 'available',
        'vehicleId': null,
      });

      // Log vehicle exit and retain data
      await FirebaseFirestore.instance.collection('vehicles_exited').add({
        ..._vehicleDetails!,
        'exitTime': Timestamp.now(),
      });

      // Remove entry record
      await FirebaseFirestore.instance.collection('vehicles_entered').doc(_vehicleDetails!['id']).delete();

      _showAlertDialog('Success', 'Vehicle exited successfully! Slot $slotId is now free.');
      setState(() {
        _vehicleDetails = null;
        _registrationNumberController.clear();
      });
    } catch (e) {
      _showAlertDialog('Error', 'Failed to log vehicle exit: $e');
    }
  }

  void _showAlertDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title, style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text("OK", style: TextStyle(color: Colors.blue)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background image
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/dark_night.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),

          // Content
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
                  SlideTransition(
                    position: _animationOffset!,
                    child: Text(
                      "Vehicle Exit",
                      style: TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            blurRadius: 10.0,
                            color: Colors.black,
                            offset: Offset(5.0, 5.0),
                          ),
                        ],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizedBox(height: 20),
                  buildTextField(_registrationNumberController, "Enter Registration Number", Icons.confirmation_number),
                  SizedBox(height: 10),
                  buildFetchButton(),
                  SizedBox(height: 30),
                  if (_vehicleDetails != null) ...[
                    Text("Vehicle Details:", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                    SizedBox(height: 10),
                    Card(
                      color: Colors.blueGrey,
                      elevation: 10,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            buildVehicleDetailRow("Vehicle Make", _vehicleDetails!['vehicleMake']),
                            buildVehicleDetailRow("Vehicle Model", _vehicleDetails!['vehicleModel']),
                            buildVehicleDetailRow("Vehicle Type", _vehicleDetails!['vehicleType']),
                            buildVehicleDetailRow("Registration Number", _vehicleDetails!['registrationNumber']),
                            buildVehicleDetailRow("Assigned Slot", _vehicleDetails!['assignedSlot']),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        buildWideButton("Cancel", Colors.grey, () {
                          setState(() {
                            _vehicleDetails = null;
                          });
                        }),
                        buildWideButton("Exit Vehicle", Colors.red, logVehicleExit),
                      ],
                    ),
                  ],
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
      style: TextStyle(color: Colors.white),
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.blueGrey),
        labelText: label,
        labelStyle: TextStyle(color: Colors.blueGrey),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.blueGrey),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.blue),
        ),
      ),
    );
  }

  Widget buildFetchButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: fetchVehicleDetails,
        child: Text(
          "Fetch Vehicle Details",
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30.0),
          ),
          padding: EdgeInsets.symmetric(vertical: 15.0),
          shadowColor: Colors.blue.withOpacity(0.5),
          elevation: 10,
        ),
      ),
    );
  }

  Widget buildVehicleDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Row(
        children: [
          Text("$label: ", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
          Expanded(child: Text(value, style: TextStyle(color: Colors.white))),
        ],
      ),
    );
  }

  Widget buildWideButton(String label, Color color, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      child: Text(
        label,
        style: TextStyle(color: Colors.white, fontSize: 16),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30.0),
        ),
        padding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 30.0),
        shadowColor: color.withOpacity(0.5),
        elevation: 10,
      ),
    );
  }
}
