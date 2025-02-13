import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'slot_management.dart';
import 'billing_screen.dart';
import 'admin_parking_slots_view.dart';
import 'vehicle_exit_screen.dart';
import 'vehicle_entry_exit.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  _AdminDashboardState createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _bouncingAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize the AnimationController and Animation
    _animationController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..repeat(reverse: true); // Bounce effect

    _bouncingAnimation = Tween<double>(begin: 0, end: 10).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    // Dispose of the controller to free up resources
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background image
          Image.asset(
            'assets/images/parking_lot.jpg', // Replace with your background image path
            fit: BoxFit.cover,
          ),
          // Overlay
          Container(
            color: Colors.black.withOpacity(0.5),
          ),
          // Content
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Bouncing "Park Ease" Title
              AnimatedBuilder(
                animation: _bouncingAnimation,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(0, _bouncingAnimation.value),
                    child: child,
                  );
                },
                child: const Text(
                  "Park Ease",
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 8), // Space between titles
              // Bouncing "Admin Dashboard" Subtitle
              AnimatedBuilder(
                animation: _bouncingAnimation,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(0, _bouncingAnimation.value),
                    child: child,
                  );
                },
                child: const Text(
                  "Admin Dashboard",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white70,
                  ),
                ),
              ),
              const SizedBox(height: 30),
              // Animated Card for Dashboard
              FadeInUp(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Card(
                    color: Colors.white,
                    elevation: 15,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 16.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _buildDashboardButton(
                                context,
                                icon: Icons.local_parking,
                                label: "Slot Management",
                                color: Colors.blue,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => SlotManagementScreen(),
                                    ),
                                  );
                                },
                              ),
                              _buildDashboardButton(
                                context,
                                icon: Icons.directions_car,
                                label: "Vehicle Entry",
                                color: Colors.teal,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => VehicleEntryExitScreen(),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _buildDashboardButton(
                                context,
                                icon: Icons.exit_to_app,
                                label: "Vehicle Exit",
                                color: Colors.orange,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => VehicleExitScreen(),
                                    ),
                                  );
                                },
                              ),
                              _buildDashboardButton(
                                context,
                                icon: Icons.attach_money,
                                label: "Billing & Payments",
                                color: Colors.green,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => BillingScreen(),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          _buildDashboardButton(
                            context,
                            icon: Icons.view_in_ar,
                            label: "3D View of Parking Slots",
                            color: Colors.red,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => AdminParkingSlotsView(),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Helper method to build individual buttons with animation
  Widget _buildDashboardButton(
      BuildContext context, {
        required IconData icon,
        required String label,
        required Color color,
        required VoidCallback onTap,
      }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 150,
        height: 130,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 5,
              offset: const Offset(3, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 50, color: Colors.white),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
