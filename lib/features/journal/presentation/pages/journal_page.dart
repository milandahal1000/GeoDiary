import 'package:flutter/material.dart';
import 'package:geodiary/features/journal/data/memory_repository.dart';
import 'package:geodiary/features/journal/domain/memory.dart';
import 'package:geodiary/features/journal/presentation/pages/add_memory_page.dart';
import 'package:geodiary/features/journal/presentation/pages/memory_detail_page.dart';
import 'package:geodiary/routes/route_names.dart';

/// The journal/home screen displays a list of memories.
class JournalPage extends StatefulWidget {
  const JournalPage({super.key});

  @override
  State<JournalPage> createState() => _JournalPageState();
}

class _JournalPageState extends State<JournalPage> {
  late Future<List<Memory>> _memoriesFuture;
  final MemoryRepository _repository = MemoryRepository.instance();

  @override
  void initState() {
    super.initState();
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
            onPressed: _refreshMemories,
            tooltip: 'Refresh',
            icon: const Icon(Icons.refresh),
          ),
          IconButton(
            onPressed: () {},
            tooltip: 'Settings',
            icon: const Icon(Icons.settings_outlined),
          ),
        ],
      ),
      body: SafeArea(
        child: FutureBuilder<List<Memory>>(
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

            if (memories.isEmpty) {
              return _buildEmptyState();
            }

            return ListView.builder(
              itemCount: memories.length,
              itemBuilder: (context, index) {
                final memory = memories[index];
                return _buildMemoryCard(context, memory);
              },
            );
          },
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
    );
  }

  Widget _buildMemoryCard(BuildContext context, Memory memory) {
    final visitDate = DateTime.fromMillisecondsSinceEpoch(memory.visitDate);
    final formattedDate =
        '${visitDate.year}-${visitDate.month.toString().padLeft(2, '0')}-${visitDate.day.toString().padLeft(2, '0')}';

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () {
          // Navigate to memory details page
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => MemoryDetailPage(
                memory: memory,
              ),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      memory.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  if (memory.latitude != null && memory.longitude != null)
                    Icon(
                      Icons.location_on,
                      size: 16,
                      color: Colors.grey[600],
                    ),
                ],
              ),
              const SizedBox(height: 8),
              if (memory.description != null &&
                  memory.description!.isNotEmpty)
                Text(
                  memory.description!,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.calendar_today, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        formattedDate,
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        tooltip: 'Edit memory',
                        onPressed: () {
                          // Navigate to edit memory screen
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => AddMemoryPage(
                                // TODO: Pass memory for editing
                              ),
                            ),
                          );
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        tooltip: 'Delete memory',
                        onPressed: () {
                          _showDeleteConfirmation(context, memory.id!);
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, int memoryId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Memory'),
        content: const Text('Are you sure you want to delete this memory? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              try {
                final repository = MemoryRepository.instance();
                await repository.deleteMemory(memoryId);
                final isMounted = mounted;
                if (isMounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Memory deleted successfully')),
                  );
                  _refreshMemories();
                } else {
                  return;
                }
              } catch (e) {
                final isMounted = mounted;
                if (isMounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to delete memory: $e')),
                  );
                } else {
                  return;
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Delete'),
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
