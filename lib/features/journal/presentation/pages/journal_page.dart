import 'package:flutter/material.dart';
import 'package:geodiary/routes/route_names.dart';

/// The journal/home screen displays a list of memories.
class JournalPage extends StatelessWidget {
  const JournalPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'GeoDiary',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
            ),
            Text('Your memories, mapped.', style: TextStyle(fontSize: 13)),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {},
            tooltip: 'Settings',
            icon: const Icon(Icons.settings_outlined),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: const Color(0xFFE1EEE7),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.landscape_outlined,
                      size: 40,
                      color: Color(0xFF287D65),
                    ),
                    SizedBox(height: 14),
                    Text(
                      'Every place has a story.',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Capture a moment, save its location, '
                      'and keep your memories close.',
                      style: TextStyle(fontSize: 14, height: 1.5),
                    ),
                    SizedBox(height: 12),
                    Text(
                      'Your next adventure starts here.',
                      style: TextStyle(
                        color: Color(0xFF287D65),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              const Text(
                'Your journal',
                style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 14),
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.photo_library_outlined,
                        size: 66,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 14),
                      const Text(
                        'No memories yet',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Your favorite moments will appear here.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Navigate to add memory screen
          Navigator.of(context).pushNamed(RouteNames.addMemory);
        },
        icon: const Icon(Icons.add_a_photo_outlined),
        label: const Text('Add memory'),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(context),
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
    // Assuming we are in the journal page, index 0
    return 0;
  }

  void _onItemTapped(BuildContext context, int index) {
    switch (index) {
      case 0:
        // Journal
        if (ModalRoute.of(context)?.settings.name != RouteNames.journal) {
          Navigator.of(context).pushReplacementNamed(RouteNames.journal);
        }
        break;
      case 1:
        // Map
        Navigator.of(context).pushNamed(RouteNames.map);
        break;
    }
  }
}
