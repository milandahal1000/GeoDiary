import 'package:flutter/material.dart';
import 'package:geodiary/routes/route_names.dart';

/// A placeholder for the map screen.
class MapPage extends StatelessWidget {
  const MapPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Memory Map'), centerTitle: false),
      body: const Center(
        child: Text(
          'Map view will be implemented in Phase 6.',
          style: TextStyle(fontSize: 16),
          textAlign: TextAlign.center,
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(context),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).pushNamed(RouteNames.addMemory);
        },
        icon: const Icon(Icons.add_a_photo_outlined),
        label: const Text('Add memory'),
      ),
    );
  }

  Widget _buildBottomNavigationBar(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: _selectedIndex(context),
      onTap: (index) => _onItemTapped(context, index),
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.list), label: 'Journal'),
        BottomNavigationBarItem(icon: Icon(Icons.map), label: 'Map'),
      ],
    );
  }

  int _selectedIndex(BuildContext context) {
    // Assuming we are in the map page, index 1
    return 1;
  }

  void _onItemTapped(BuildContext context, int index) {
    switch (index) {
      case 0:
        // Journal
        Navigator.of(context).pushNamed(RouteNames.journal);
        break;
      case 1:
        // Map
        if (ModalRoute.of(context)?.settings.name != RouteNames.map) {
          Navigator.of(context).pushReplacementNamed(RouteNames.map);
        }
        break;
    }
  }
}
