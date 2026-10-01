import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/theme/app_colors.dart';

class CameraPrototypeScreen extends StatefulWidget {
  const CameraPrototypeScreen({super.key});

  @override
  State<CameraPrototypeScreen> createState() => _CameraPrototypeScreenState();
}

class _CameraPrototypeScreenState extends State<CameraPrototypeScreen> {
  String? _error;

  @override
  void initState() {
    super.initState();
    _capture();
  }

  Future<void> _capture() async {
    try {
      final photo = await ImagePicker().pickImage(
        source: ImageSource.camera,
        maxWidth: 1600,
        imageQuality: 85,
      );
      if (!mounted) return;
      Navigator.pop(context, photo);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Could not open the camera: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: _error != null
            ? Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(_error!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.white)),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Close'),
                    ),
                  ],
                ),
              )
            : const CircularProgressIndicator(color: AppColors.sellerGreen),
      ),
    );
  }
}
