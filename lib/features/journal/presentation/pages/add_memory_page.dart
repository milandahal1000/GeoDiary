import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
  final _visitDateController = TextEditingController();
  DateTime? _visitDate;
  File? _imageFile; // Temporary file from image picker
  double? _latitude;
  double? _longitude;
  String? _address;
  bool _isEditing = false;
  bool _removeExistingPhoto = false;
  bool _isGettingLocation = false;
  String? _existingPhotoPath;
  late final MemoryRepository _repository;

  @override
  void initState() {
    super.initState();
    _repository = context.read<MemoryRepository>();
    if (widget.memory != null) {
      _isEditing = true;
      final memory = widget.memory!;
      _titleController.text = memory.title;
      _descriptionController.text = memory.description ?? '';
      _visitDate = DateTime.fromMillisecondsSinceEpoch(memory.visitDate);
      _visitDateController.text = _formatVisitDate(_visitDate!);
      _latitude = memory.latitude;
      _longitude = memory.longitude;
      _address = memory.address;
      _existingPhotoPath = memory.photoPath;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _visitDateController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final pickedFile = await ImagePicker().pickImage(source: source);
      if (pickedFile != null) {
        setState(() {
          _imageFile = File(pickedFile.path);
          _removeExistingPhoto = false;
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
      _removeExistingPhoto = true;
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
    } else if (!_removeExistingPhoto) {
      imagePath = _existingPhotoPath;
    }

    // Determine visitDate: use picked date or now
    final visitDate =
        _visitDate?.millisecondsSinceEpoch ??
        DateTime.now().millisecondsSinceEpoch;

    // Create the memory object
    final memory = Memory(
      id: _isEditing ? widget.memory!.id : null,
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
      if (_isEditing) {
        await _repository.updateMemory(memory);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Memory updated successfully!')),
          );
          Navigator.of(context).pop();
        }
      } else {
        await _repository.insertMemory(memory);
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
                      _buildImagePreview(),
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
                            if (_imageFile != null ||
                                (_existingPhotoPath != null &&
                                    !_removeExistingPhoto))
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
                  controller: _visitDateController,
                  decoration: const InputDecoration(
                    labelText: 'Visit date',
                    hintText: 'Select a date',
                    border: OutlineInputBorder(),
                    suffixIcon: Icon(Icons.calendar_today),
                  ),
                  readOnly: true,
                  onTap: _pickVisitDate,
                ),
                const SizedBox(height: 24),
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.location_on),
                    title: const Text('Location'),
                    subtitle: Text(
                      _isGettingLocation
                          ? 'Getting an accurate location...'
                          : _address ?? 'Not added',
                    ),
                    trailing: _isGettingLocation
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : IconButton(
                            icon: const Icon(Icons.add_location),
                            tooltip: 'Add current location',
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

  Widget _buildImagePreview() {
    if (_imageFile != null) {
      return Image.file(
        _imageFile!,
        width: 200,
        height: 200,
        fit: BoxFit.cover,
      );
    }
    if (_existingPhotoPath != null && !_removeExistingPhoto) {
      return Image.file(
        File(_existingPhotoPath!),
        width: 200,
        height: 200,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => _buildImagePlaceholder(),
      );
    }
    return _buildImagePlaceholder();
  }

  Widget _buildImagePlaceholder() {
    return Container(
      width: 200,
      height: 200,
      color: Colors.grey[300],
      child: const Icon(Icons.image, size: 50, color: Colors.grey),
    );
  }

  Future<void> _pickVisitDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _visitDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _visitDate = picked;
        _visitDateController.text = _formatVisitDate(picked);
      });
    }
  }

  String _formatVisitDate(DateTime date) {
    final localDate = date.toLocal();
    return '${localDate.day.toString().padLeft(2, '0')}/'
        '${localDate.month.toString().padLeft(2, '0')}/'
        '${localDate.year}';
  }

  Future<void> _getCurrentLocation() async {
    if (_isGettingLocation) {
      return;
    }
    setState(() => _isGettingLocation = true);

    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        if (mounted) {
          _showLocationMessage(
            'Location services are turned off. Turn them on to add a location.',
            onSettings: () => Geolocator.openLocationSettings(),
          );
        }
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied) {
        if (mounted) {
          _showLocationMessage('Location permission was denied.');
        }
        return;
      }

      if (permission == LocationPermission.deniedForever) {
        if (mounted) {
          _showLocationMessage(
            'Location permission is blocked. Enable it in app settings.',
            onSettings: () => Geolocator.openAppSettings(),
          );
        }
        return;
      }

      if (!kIsWeb) {
        final accuracyStatus = await Geolocator.getLocationAccuracy();
        if (accuracyStatus == LocationAccuracyStatus.reduced) {
          if (mounted) {
            _showLocationMessage(
              'Approximate location is enabled. Choose "Precise" for GeoDiary '
              'in app settings, then try again.',
              onSettings: () => Geolocator.openAppSettings(),
            );
          }
          return;
        }
      }

      final Position position = await _getAccuratePosition();
      final String accuracyLabel = position.accuracy > 0
          ? ' (±${position.accuracy.toStringAsFixed(0)} m)'
          : '';

      if (mounted) {
        setState(() {
          _latitude = position.latitude;
          _longitude = position.longitude;
          _address =
              '${position.latitude.toStringAsFixed(6)}, '
              '${position.longitude.toStringAsFixed(6)}';
        });
        _showLocationMessage('Location captured$accuracyLabel.');
      }
    } on TimeoutException {
      if (mounted) {
        _showLocationMessage(
          'Location request timed out. Move to an open area and try again.',
        );
      }
    } on LocationServiceDisabledException {
      if (mounted) {
        _showLocationMessage(
          'Location services are turned off. Turn them on to add a location.',
          onSettings: () => Geolocator.openLocationSettings(),
        );
      }
    } catch (e) {
      debugPrint('Error getting location: $e');
      if (mounted) {
        _showLocationMessage('Failed to get location: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isGettingLocation = false);
      }
    }
  }

  /// Gets a fresh high-accuracy fix. If the first fix is imprecise, listens
  /// briefly for a better one instead of saving a cached/network location.
  Future<Position> _getAccuratePosition() async {
    Position best = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.best,
        timeLimit: Duration(seconds: 20),
      ),
    );

    if (best.accuracy <= 0 || best.accuracy <= 30) {
      return best;
    }

    final completer = Completer<Position>();
    late StreamSubscription<Position> subscription;
    Timer? timer;

    subscription =
        Geolocator.getPositionStream(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.best,
            distanceFilter: 0,
          ),
        ).listen(
          (position) {
            if (position.accuracy > 0 && position.accuracy < best.accuracy) {
              best = position;
            }
            if (position.accuracy > 0 && position.accuracy <= 20) {
              best = position;
              if (!completer.isCompleted) {
                completer.complete(best);
              }
              timer?.cancel();
              subscription.cancel();
            }
          },
          onError: (Object error, StackTrace stackTrace) {
            if (!completer.isCompleted) {
              completer.complete(best);
            }
            timer?.cancel();
            subscription.cancel();
          },
        );

    timer = Timer(const Duration(seconds: 15), () {
      if (!completer.isCompleted) {
        completer.complete(best);
      }
      subscription.cancel();
    });

    return completer.future;
  }

  void _showLocationMessage(String message, {VoidCallback? onSettings}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        action: onSettings == null
            ? null
            : SnackBarAction(label: 'Settings', onPressed: onSettings),
      ),
    );
  }
}
