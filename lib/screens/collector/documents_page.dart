import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/theme/app_colors.dart';
import '../../core/file_type_utils.dart';
import '../../core/verification_docs.dart';
import '../../services/auth_state.dart';
import '../../services/firestore_service.dart';

enum _DocSource { camera, gallery, file }

class DocumentsPage extends StatefulWidget {
  const DocumentsPage({super.key});

  @override
  State<DocumentsPage> createState() => _DocumentsPageState();
}

class _DocumentsPageState extends State<DocumentsPage> {
  final _svc = FirestoreService();
  String? _uploadingType;

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'verified':
        return AppColors.success;
      case 'rejected':
        return AppColors.error;
      default:
        return AppColors.warning;
    }
  }

  String _statusLabel(String status) {
    if (status.isEmpty) return 'Pending';
    return status[0].toUpperCase() + status.substring(1).toLowerCase();
  }

  Future<void> _capture(String docType) async {
    final choice = await showModalBottomSheet<_DocSource>(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => SafeArea(
        child: Wrap(children: [
          ListTile(
            leading: const Icon(Icons.camera_alt_outlined),
            title: const Text('Take Photo'),
            onTap: () => Navigator.pop(context, _DocSource.camera),
          ),
          ListTile(
            leading: const Icon(Icons.photo_library_outlined),
            title: const Text('Choose from Gallery'),
            onTap: () => Navigator.pop(context, _DocSource.gallery),
          ),
          ListTile(
            leading: const Icon(Icons.insert_drive_file_outlined),
            title: const Text('Upload File (PDF, DOC)'),
            onTap: () => Navigator.pop(context, _DocSource.file),
          ),
        ]),
      ),
    );
    if (choice == null) return;

    File? picked;
    if (choice == _DocSource.file) {
      final files = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx'],
      );
      final path = files.isEmpty ? null : files.first.path;
      if (path == null) return;
      picked = File(path);
    } else {
      final photo = await ImagePicker().pickImage(
          source: choice == _DocSource.camera
              ? ImageSource.camera
              : ImageSource.gallery,
          maxWidth: 1600,
          imageQuality: 80);
      if (photo == null) return;
      picked = File(photo.path);
    }

    await _upload(docType, picked);
  }

  Future<void> _upload(String docType, File file) async {
    final uid = AuthState.instance.uid;
    if (uid == null || !mounted) return;
    setState(() => _uploadingType = docType);
    try {
      final url = await _svc.uploadVerificationDoc(file);
      await _svc.setVerificationDocUrl(uid, docType, url);
      final updated = List<Map<String, dynamic>>.from(
          AuthState.instance.verificationDocs);
      final i = updated.indexWhere((d) => d['type'] == docType);
      final entry = {'type': docType, 'url': url, 'status': 'pending'};
      if (i >= 0) {
        updated[i] = entry;
      } else {
        updated.add(entry);
      }
      AuthState.instance.updateVerificationDocs(updated);
      // A new clearance needs a new review (see setVerificationDocUrl).
      if (docType == barangayClearanceDocType) {
        AuthState.instance.setBarangayCleared(false);
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Uploaded — pending admin review.')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('$e'), backgroundColor: AppColors.error));
    } finally {
      if (mounted) setState(() => _uploadingType = null);
    }
  }

  Future<void> _view(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    final docs = AuthState.instance.verificationDocs;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('Verification Documents',
            style: TextStyle(
                color: AppColors.textPrimary, fontWeight: FontWeight.w700)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        children: [
          const SizedBox(height: 12),
          const Text(
            'Take a photo or upload a PDF/DOC of each document. The system '
            'administrator reviews these before you can receive bookings. '
            'The Barangay Clearance is optional: if it is approved, you get '
            'a "Barangay Cleared" badge that households see. Max 5MB per file.',
            style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 20),
          if (docs.isEmpty)
            const Text('No verification documents on file yet.',
                style: TextStyle(color: AppColors.textSecondary))
          else
            ...docs.map((d) {
              final type = d['type'] as String? ?? 'Document';
              final status = (d['status'] as String? ?? 'pending');
              final url = d['url'] as String? ?? '';
              return _DocCard(
                title: isOptionalVerificationDoc(type)
                    ? '$type (optional)'
                    : type,
                status: _statusLabel(status),
                statusColor: _statusColor(status),
                thumbnailUrl: url,
                uploading: _uploadingType == type,
                onTap: () => _capture(type),
                onView: url.isEmpty ? null : () => _view(url),
              );
            }),
        ],
      ),
    );
  }
}

class _DocCard extends StatelessWidget {
  final String title;
  final String status;
  final Color statusColor;
  final String thumbnailUrl;
  final bool uploading;
  final VoidCallback onTap;
  final VoidCallback? onView;

  const _DocCard({
    required this.title,
    required this.status,
    required this.statusColor,
    required this.thumbnailUrl,
    required this.uploading,
    required this.onTap,
    this.onView,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFF5F5F5),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: uploading ? null : onTap,
        child: Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: SizedBox(
                width: 44,
                height: 44,
                child: uploading
                    ? const Center(
                        child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2)))
                    : thumbnailUrl.isEmpty
                        ? Container(
                            color: const Color(0xFFE5E7EB),
                            child: const Icon(Icons.add_a_photo_outlined,
                                size: 18, color: AppColors.textSecondary))
                        : isImageUrl(thumbnailUrl)
                            ? Image.network(thumbnailUrl, fit: BoxFit.cover)
                            : Container(
                                color: const Color(0xFFE5E7EB),
                                child: Center(
                                    child: Text(fileExtensionLabel(thumbnailUrl),
                                        style: const TextStyle(
                                            fontSize: 9,
                                            fontWeight: FontWeight.w800,
                                            color: AppColors.textSecondary)))),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary)),
                  Text(thumbnailUrl.isEmpty ? 'Tap to upload' : status,
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: thumbnailUrl.isEmpty
                              ? AppColors.textSecondary
                              : statusColor)),
                ],
              ),
            ),
            if (onView != null)
              IconButton(
                icon: const Icon(Icons.open_in_new,
                    size: 18, color: AppColors.textSecondary),
                tooltip: 'View',
                onPressed: onView,
              )
            else
              const Icon(Icons.chevron_right, color: AppColors.textMuted),
          ]),
        ),
      ),
    );
  }
}
