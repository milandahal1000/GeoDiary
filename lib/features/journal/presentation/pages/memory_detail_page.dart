import 'dart:io';

import 'package:flutter/material.dart';
import 'package:geodiary/features/journal/data/memory_repository.dart';
import 'package:geodiary/features/journal/domain/memory.dart';
import 'package:geodiary/features/journal/presentation/pages/add_memory_page.dart';

/// Displays the details of a memory.
class MemoryDetailPage extends StatefulWidget {
  final Memory memory;

  const MemoryDetailPage({super.key, required this.memory});

  @override
  State<MemoryDetailPage> createState() => _MemoryDetailPageState();
}

class _MemoryDetailPageState extends State<MemoryDetailPage> {
  final MemoryRepository _repository = MemoryRepository.instance();

  @override
  void initState() {
    super.initState();
    // No need to load memory as we already have it
  }

  void _refreshMemory() {
    // In a real app, we might reload from database here
    // For now, we'll just rebuild with the current memory object
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Memory Details'),
        actions: [
          IconButton(
            onPressed: _refreshMemory,
            tooltip: 'Refresh',
            icon: const Icon(Icons.refresh),
          ),
          IconButton(
            onPressed: () {
              // Navigate to edit memory screen
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => AddMemoryPage(memory: widget.memory),
                ),
              );
            },
            tooltip: 'Edit',
            icon: const Icon(Icons.edit),
          ),
          IconButton(
            onPressed: () => _showDeleteConfirmation(context),
            tooltip: 'Delete',
            icon: const Icon(Icons.delete),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.memory.title,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            if (widget.memory.description != null &&
                widget.memory.description!.isNotEmpty)
              Text(
                widget.memory.description!,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            const SizedBox(height: 16),
            if (widget.memory.photoPath != null)
              _buildImagePreview(widget.memory.photoPath!),
            const SizedBox(height: 16),
            _buildInfoRow(
              Icons.calendar_today,
              'Date',
              _formatDate(widget.memory.visitDate),
            ),
            const SizedBox(height: 8),
            if (widget.memory.latitude != null &&
                widget.memory.longitude != null)
              _buildInfoRow(
                Icons.location_on,
                'Location',
                '${widget.memory.latitude}, ${widget.memory.longitude}',
              ),
            const SizedBox(height: 8),
            if (widget.memory.address != null &&
                widget.memory.address!.isNotEmpty)
              _buildInfoRow(Icons.map, 'Address', widget.memory.address!),
            const SizedBox(height: 16),
            _buildInfoRow(
              Icons.access_time,
              'Created',
              _formatDateTime(widget.memory.createdAt),
            ),
            if (widget.memory.updatedAt != widget.memory.createdAt)
              _buildInfoRow(
                Icons.access_time,
                'Updated',
                _formatDateTime(widget.memory.updatedAt),
              ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Navigate to add memory screen for editing
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => AddMemoryPage(memory: widget.memory),
            ),
          );
        },
        icon: const Icon(Icons.edit),
        label: const Text('Edit Memory'),
      ),
    );
  }

  Widget _buildImagePreview(String imagePath) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image.file(
        File(imagePath),
        width: double.infinity,
        height: 200,
        fit: BoxFit.cover,
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Expanded(
            child: Text('$label: $value', style: TextStyle(fontSize: 16)),
          ),
        ],
      ),
    );
  }

  String _formatDate(int millisecondsSinceEpoch) {
    final date = DateTime.fromMillisecondsSinceEpoch(millisecondsSinceEpoch);
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  String _formatDateTime(int millisecondsSinceEpoch) {
    final date = DateTime.fromMillisecondsSinceEpoch(millisecondsSinceEpoch);
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')} '
        '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Memory'),
        content: const Text(
          'Are you sure you want to delete this memory? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              try {
                await _repository.deleteMemory(widget.memory.id!);
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Memory deleted successfully')),
                );
                Navigator.of(context).pop(); // Go back to journal
              } catch (e) {
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Failed to delete memory: $e')),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
