import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:geodiary/features/journal/data/memory_repository.dart';
import 'package:geodiary/features/journal/domain/memory.dart';
import 'package:geolocator/geolocator.dart';

/// The Add Memory screen allows users to create a new memory or edit an existing one.
class AddMemoryPage extends StatefulWidget {
  final Memory? memory;

  const AddMemoryPage({super.key, this.memory});

  @override
  State<AddMemoryPage> createState() => _AddMemoryPageState();
}

class _AddMemoryPageState extends State<AddMemoryPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  DateTime? _visitDate;
  File? _imageFile; // Temporary file from image picker
  double? _latitude;
  double? _longitude;
  String? _address;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    if (widget.memory != null) {
      _isEditing = true;
      final memory = widget.memory!;
      _titleController.text = memory.title;
      _descriptionController.text = memory.description ?? '';
      _visitDate = DateTime.fromMillisecondsSinceEpoch(memory.visitDate);
      _latitude = memory.latitude;
      _longitude = memory.longitude;
      _address = memory.address;

      // If there's an existing photo, we'd need to load it
      // For now, we'll leave _imageFile as null and allow user to change it
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final pickedFile = await ImagePicker().pickImage(source: source);
      if (pickedFile != null) {
        setState(() {
          _imageFile = File(pickedFile.path);
        });
      }
    } on PlatformException catch (e) {
      // Handle errors (e.g., camera not available)
      debugPrint('Error picking image: $e');
      // Optionally show a snackbar
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Failed to pick image.')));
      }
    }
  }

  Future<void> _removeImage() async {
    setState(() {
      _imageFile = null;
    });
  }

  Future<void> _saveMemory() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    String? imagePath;
    if (_imageFile != null) {
      try {
        final directory = await getApplicationDocumentsDirectory();
        final String timestamp = DateTime.now().millisecondsSinceEpoch
            .toString();
        final String filename = 'memory_$timestamp.jpg';
        final File savedImage = await _imageFile!.copy(
          '${directory.path}/$filename',
        );
        imagePath = savedImage.path;
      } catch (e) {
        debugPrint('Error saving image: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to save image.')),
          );
        }
        return;
      }
    }

    // Determine visitDate: use picked date or now
    final visitDate =
        _visitDate?.millisecondsSinceEpoch ??
        DateTime.now().millisecondsSinceEpoch;

    // Create the memory object
    final memory = Memory(
      title: _titleController.text,
      description: _descriptionController.text.isEmpty
          ? null
          : _descriptionController.text,
      visitDate: visitDate,
      photoPath: imagePath,
      latitude: _latitude,
      longitude: _longitude,
      address: _address,
      createdAt: _isEditing
          ? widget.memory!.createdAt
          : DateTime.now().millisecondsSinceEpoch,
      updatedAt: DateTime.now().millisecondsSinceEpoch,
    );

    try {
      final repository = MemoryRepository.instance();
      if (_isEditing) {
        await repository.updateMemory(memory);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Memory updated successfully!')),
          );
          Navigator.of(context).pop();
        }
      } else {
        await repository.insertMemory(memory);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Memory saved successfully!')),
          );
          Navigator.of(context).pop();
        }
      }
    } catch (e) {
      debugPrint('Error saving memory: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Failed to save memory.')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Memory' : 'New memory'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          TextButton(onPressed: _saveMemory, child: const Text('Save')),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Image preview and selection
                Center(
                  child: Stack(
                    alignment: Alignment.bottomCenter,
                    children: [
                      _imageFile != null
                          ? Image.file(
                              _imageFile!,
                              width: 200,
                              height: 200,
                              fit: BoxFit.cover,
                            )
                          : Container(
                              width: 200,
                              height: 200,
                              color: Colors.grey[300],
                              child: const Icon(
                                Icons.image,
                                size: 50,
                                color: Colors.grey,
                              ),
                            ),
                      Positioned(
                        right: 0,
                        child: Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.camera_alt),
                              onPressed: () => _pickImage(ImageSource.camera),
                            ),
                            IconButton(
                              icon: const Icon(Icons.photo_library),
                              onPressed: () => _pickImage(ImageSource.gallery),
                            ),
                            if (_imageFile != null)
                              IconButton(
                                icon: const Icon(Icons.close),
                                onPressed: _removeImage,
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                // Title field
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Title *',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a title';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                // Description field
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                // Visit date field
                TextFormField(
                  decoration: InputDecoration(
                    labelText: _visitDate == null
                        ? 'Visit date'
                        : 'Visit date: ${_visitDate!.toLocal()}'.split(' ')[0],
                    border: OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.calendar_today),
                      onPressed: _pickVisitDate,
                    ),
                  ),
                  readOnly: true,
                  onTap: _pickVisitDate,
                ),
                const SizedBox(height: 24),
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.location_on),
                    title: const Text('Location'),
                    subtitle: Text(_address ?? 'Not added'),
                    trailing: IconButton(
                      icon: const Icon(Icons.add_location),
                      onPressed: _getCurrentLocation,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                // Save button (already in app bar)
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _pickVisitDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _visitDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != _visitDate) {
      setState(() {
        _visitDate = picked;
      });
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      // Request location permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Location permissions are denied')),
            );
          }
          return;
        }
      }

      // Get current position
      Position position = await Geolocator.getCurrentPosition(
        // ignore: deprecated_member_use
        desiredAccuracy: LocationAccuracy.high,
      );

      // Use coordinates as address (geocoding temporarily disabled due to import issues)
      String address = '${position.latitude}, ${position.longitude}';

      // Update state
      if (mounted) {
        setState(() {
          _latitude = position.latitude;
          _longitude = position.longitude;
          _address = address;
        });
      }
    } catch (e) {
      debugPrint('Error getting location: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to get location: $e')));
      }
    }
  }
}
