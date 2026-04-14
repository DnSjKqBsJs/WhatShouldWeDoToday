import 'package:flutter/material.dart';
import 'package:japan_app/screens/map/map_screen.dart';
import 'package:japan_app/screens/profile/profile_screen.dart';
import 'package:japan_app/screens/trip/trips_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});
  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: [
          TripsScreen(onTripSelected: () => setState(() => _currentIndex = 1)),
          MapScreen(),
          ProfileScreen(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.flight), label: 'Trips'),
          BottomNavigationBarItem(icon: Icon(Icons.map), label: 'Map'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'profile'),
        ],
        onTap: (value) {
          _currentIndex = value;
          setState(() {});
        },
      ),
    );
  }
}
