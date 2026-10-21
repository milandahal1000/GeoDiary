import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geodiary/features/journal/data/memory_repository.dart';
import 'package:geodiary/features/journal/domain/memory.dart';
import 'package:geodiary/routes/route_names.dart';
import 'package:latlong2/latlong.dart';

/// Displays memories on an interactive map using OpenStreetMap.
class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  late final MemoryRepository _repository;
  late Future<List<Memory>> _memoriesFuture;
  final List<Marker> _markers = [];

  @override
  void initState() {
    super.initState();
    _repository = context.read<MemoryRepository>();
    _loadMemories();
  }

  void _loadMemories() {
    setState(() {
      _memoriesFuture = _repository.getAllMemories();
    });
  }

  void _refreshMemories() {
    _loadMemories();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Memory Map'),
        actions: [
          IconButton(
            onPressed: _refreshMemories,
            tooltip: 'Refresh',
            icon: const Icon(Icons.refresh),
          ),
          IconButton(
            onPressed: () {
              Navigator.of(context).pushNamed(RouteNames.settings);
            },
            tooltip: 'Settings',
            icon: const Icon(Icons.settings_outlined),
          ),
        ],
      ),
      body: FutureBuilder<List<Memory>>(
        future: _memoriesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Error loading memories: ${snapshot.error}'),
            );
          }

          final memories = snapshot.data ?? [];
          _updateMarkers(memories);

          if (memories.isEmpty) {
            return _buildEmptyState();
          }

          return FlutterMap(
            options: MapOptions(
              initialCenter: _getInitialCenter(memories),
              initialZoom: 13.0,
              interactionOptions: const InteractionOptions(
                flags: InteractiveFlag.all,
              ),
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'dev.fleaflet.flutter_map',
              ),
              MarkerLayer(markers: _markers),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).pushNamed(RouteNames.addMemory);
        },
        icon: const Icon(Icons.add_a_photo_outlined),
        label: const Text('Add memory'),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(context),
    );
  }

  void _updateMarkers(List<Memory> memories) {
    _markers.clear();
    for (final memory in memories) {
      if (memory.latitude != null && memory.longitude != null) {
        final marker = Marker(
          point: LatLng(memory.latitude!, memory.longitude!),
          width: 40.0,
          height: 40.0,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.red.withValues(alpha: 0.7),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.location_on,
              color: Colors.white,
              size: 28.0,
            ),
          ),
        );
        _markers.add(marker);
      }
    }
  }

  LatLng _getInitialCenter(List<Memory> memories) {
    // Find first memory with coordinates, or default to a reasonable location
    for (final memory in memories) {
      if (memory.latitude != null && memory.longitude != null) {
        return LatLng(memory.latitude!, memory.longitude!);
      }
    }
    // Default to a reasonable location (using a visible location)
    return const LatLng(0.0, 0.0);
  }

  Widget _buildEmptyState() {
    return Padding(
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
                Icon(Icons.map_outlined, size: 40, color: Color(0xFF287D65)),
                SizedBox(height: 14),
                Text(
                  'Memories on the map',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text(
                  'Add memories with locations to see them appear here.',
                  style: TextStyle(fontSize: 14, height: 1.5),
                ),
                SizedBox(height: 12),
                Text(
                  'Your memories will appear on this map.',
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
            'Your memories',
            style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 14),
          Expanded(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.map_outlined,
                    size: 66,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'No memories with location yet',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Add memories with location to see them on the map.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
          ),
        ],
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
