import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/theme/app_colors.dart';
import '../../services/auth_service.dart';
import '../../services/auth_state.dart';
import '../../services/firestore_service.dart';
import '../../widgets/address_entry_page.dart';
import '../../widgets/signature_pad_page.dart';

class CollectorIDCard extends StatefulWidget {
  const CollectorIDCard({super.key});
  @override
  State<CollectorIDCard> createState() => _CollectorIDCardState();
}

class _CollectorIDCardState extends State<CollectorIDCard> {
  int _mode = 0;
  // Which ID detail is mid-save ('photo' / 'birthdate' / 'signature').
  String? _saving;

  static const _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  String _formatDate(DateTime d) =>
      '${_months[d.month - 1]} ${d.day.toString().padLeft(2, '0')}, ${d.year}';

  Future<void> _run(String field, Future<void> Function() action) async {
    setState(() => _saving = field);
    try {
      await action();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Could not save: $e')));
      }
    } finally {
      if (mounted) setState(() => _saving = null);
    }
  }

  Future<void> _changePhoto() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (sheetContext) => SafeArea(
        child: Wrap(children: [
          ListTile(
            leading: const Icon(Icons.camera_alt_outlined),
            title: const Text('Take Photo'),
            onTap: () => Navigator.pop(sheetContext, ImageSource.camera),
          ),
          ListTile(
            leading: const Icon(Icons.photo_library_outlined),
            title: const Text('Choose from Gallery'),
            onTap: () => Navigator.pop(sheetContext, ImageSource.gallery),
          ),
        ]),
      ),
    );
    if (source == null) return;
    // Downscaled on pick so it lands far under the 2MB ID photo cap.
    final photo = await ImagePicker().pickImage(
        source: source,
        maxWidth: 600,
        maxHeight: 600,
        imageQuality: 80,
        preferredCameraDevice: CameraDevice.front);
    if (photo == null) return;
    await _run('photo', () async {
      final url = await FirestoreService().uploadIdPhoto(File(photo.path));
      await AuthService.instance.updateCollectorIdDetails(profilePhotoUrl: url);
    });
  }

  Future<void> _pickBirthdate() async {
    final now = DateTime.now();
    // Collectors must be adults.
    final latest = DateTime(now.year - 18, now.month, now.day);
    final current = AuthState.instance.birthdate;
    final picked = await showDatePicker(
      context: context,
      initialDate: current != null && !current.isAfter(latest) ? current : latest,
      firstDate: DateTime(1940),
      lastDate: latest,
      helpText: 'Select your birthdate',
    );
    if (picked == null) return;
    await _run('birthdate', () {
      return AuthService.instance.updateCollectorIdDetails(birthdate: picked);
    });
  }

  Future<void> _drawSignature() async {
    final bytes = await Navigator.push<Uint8List>(context,
        MaterialPageRoute(builder: (_) => const SignaturePadPage()));
    if (bytes == null) return;
    await _run('signature', () async {
      final url = await FirestoreService().uploadSignature(bytes);
      await AuthService.instance.updateCollectorIdDetails(signatureUrl: url);
    });
  }

  Future<void> _editAddress() async {
    await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) => AddressEntryPage(
                initialAddress: AuthState.instance.collectorAddress,
                onSave: AuthService.instance.updateCollectorAddress)));
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final auth = AuthState.instance;
    final name =
        auth.displayName.trim().isEmpty ? 'Collector' : auth.displayName;
    final initials = name
        .trim()
        .split(' ')
        .where((w) => w.isNotEmpty)
        .take(2)
        .map((w) => w[0])
        .join()
        .toUpperCase();
    final isVerified = auth.verificationStatus == 'Verified';
    Matrix4 cardTransform = Matrix4.identity();
    if (_mode == 1) {
      cardTransform = Matrix4.identity()
        ..setEntry(3, 2, 0.001)
        ..rotateX(-0.08)
        ..rotateY(0.12);
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        automaticallyImplyLeading: true,
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('My Digital ID Card',
            style: TextStyle(
                color: Color(0xFF111827),
                fontWeight: FontWeight.w800,
                fontSize: 16)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF111827)),
          onPressed: () => Navigator.pop(context),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.5),
          child: Container(color: const Color(0xFFE5E7EB), height: 1.5),
        ),
      ),
      body: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          children: [
            const SizedBox(height: 8),
            Transform(
                transform: cardTransform,
                alignment: Alignment.center,
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                      color: AppColors.buyerBlue,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: _mode == 1
                          ? [
                              BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.3),
                                  blurRadius: 20,
                                  offset: const Offset(0, 10))
                            ]
                          : null),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('KILOTAP',
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w900,
                                      color: Colors.white70,
                                      letterSpacing: 2)),
                              Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                      color: isVerified
                                          ? AppColors.success
                                          : AppColors.warning,
                                      borderRadius: BorderRadius.circular(12)),
                                  child: Text(
                                      auth.verificationStatus.toUpperCase(),
                                      style: const TextStyle(
                                          fontSize: 9,
                                          fontWeight: FontWeight.w800,
                                          color: Colors.white,
                                          letterSpacing: 1))),
                            ]),
                        const SizedBox(height: 18),
                        Row(children: [
                          GestureDetector(
                            onTap: _saving == null ? _changePhoto : null,
                            child: Container(
                                width: 76,
                                height: 90,
                                clipBehavior: Clip.antiAlias,
                                decoration: BoxDecoration(
                                    color: Colors.white24,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                        color: Colors.white, width: 2)),
                                child: _saving == 'photo'
                                    ? const Center(
                                        child: SizedBox(
                                            width: 22,
                                            height: 22,
                                            child: CircularProgressIndicator(
                                                color: Colors.white,
                                                strokeWidth: 2)))
                                    : auth.profilePhotoUrl.isNotEmpty
                                        ? Image.network(auth.profilePhotoUrl,
                                            fit: BoxFit.cover,
                                            errorBuilder: (_, __, ___) =>
                                                _InitialsBox(initials))
                                        : _InitialsBox(initials,
                                            showAddHint: true)),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                Text(name,
                                    style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w800,
                                        color: Colors.white)),
                                Text(
                                    auth.vehicleType.isEmpty
                                        ? 'Vehicle not set'
                                        : '${auth.vehicleType} Operator',
                                    style: const TextStyle(
                                        fontSize: 11, color: Colors.white60)),
                                const SizedBox(height: 8),
                                Text('★ ${auth.avgRating.toStringAsFixed(1)}',
                                    style: const TextStyle(
                                        fontSize: 14, color: AppColors.star)),
                              ])),
                        ]),
                        const SizedBox(height: 16),
                        _CardField(
                            'ADDRESS',
                            auth.collectorAddress.isEmpty
                                ? 'Not set'
                                : auth.collectorAddress),
                        const SizedBox(height: 8),
                        _CardField(
                            'BIRTHDATE',
                            auth.birthdate == null
                                ? 'Not set'
                                : _formatDate(auth.birthdate!)),
                        const SizedBox(height: 16),
                        Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10)),
                            child: Row(children: [
                              const Icon(Icons.qr_code,
                                  size: 50, color: AppColors.textPrimary),
                              const SizedBox(width: 12),
                              Expanded(
                                  child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                    const Text('Scan to Verify',
                                        style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w700,
                                            color: AppColors.textPrimary)),
                                    Text(
                                        'kilotap.app/v/${(auth.uid ?? '').isEmpty ? '—' : auth.uid!.substring(0, auth.uid!.length < 8 ? auth.uid!.length : 8)}',
                                        style: const TextStyle(
                                            fontSize: 10,
                                            color: AppColors.buyerBlue)),
                                    const Text('Issued by KiloTap',
                                        style: TextStyle(
                                            fontSize: 9,
                                            color: AppColors.textMuted)),
                                  ])),
                              Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                      width: 90,
                                      height: 36,
                                      child: auth.signatureUrl.isNotEmpty
                                          ? Image.network(auth.signatureUrl,
                                              fit: BoxFit.contain,
                                              errorBuilder: (_, __, ___) =>
                                                  const SizedBox.shrink())
                                          : null,
                                    ),
                                    Container(
                                        width: 90,
                                        height: 1,
                                        color: AppColors.textMuted),
                                    const SizedBox(height: 2),
                                    const Text('Signature',
                                        style: TextStyle(
                                            fontSize: 9,
                                            color: AppColors.textMuted)),
                                  ]),
                            ])),
                      ]),
                )),
            const SizedBox(height: 20),
            Row(children: [
              _ModeButton(
                  label: '2D View',
                  active: _mode == 0,
                  onTap: () => setState(() => _mode = 0)),
              const SizedBox(width: 8),
              _ModeButton(
                  label: '3D Rotate',
                  active: _mode == 1,
                  onTap: () => setState(() => _mode = 1)),
              const SizedBox(width: 8),
              _ModeButton(
                  label: 'Share Card',
                  active: _mode == 2,
                  onTap: () {
                    setState(() => _mode = 2);
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text('Card shared! kilotap.app/v/jd123'),
                        duration: Duration(seconds: 2)));
                  }),
            ]),
            if (_mode == 2) ...[
              const SizedBox(height: 12),
              Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                      color: AppColors.buyerBlue.withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                          color: AppColors.buyerBlue.withValues(alpha: 0.2))),
                  child: const Row(children: [
                    Icon(Icons.check_circle,
                        size: 16, color: AppColors.buyerBlue),
                    SizedBox(width: 8),
                    Expanded(
                        child: Text('Card shared! Sent to your messaging app.',
                            style: TextStyle(
                                fontSize: 11,
                                color: AppColors.buyerBlue,
                                fontWeight: FontWeight.w600)))
                  ])),
            ],
            const SizedBox(height: 20),
            const _SectionTitle('ID DETAILS'),
            _DetailTile(
              icon: Icons.photo_camera_outlined,
              label: 'ID Photo',
              value: auth.profilePhotoUrl.isEmpty ? 'Add photo' : 'Change photo',
              busy: _saving == 'photo',
              onTap: _saving == null ? _changePhoto : null,
            ),
            _DetailTile(
              icon: Icons.cake_outlined,
              label: 'Birthdate',
              value: auth.birthdate == null
                  ? 'Set birthdate'
                  : _formatDate(auth.birthdate!),
              busy: _saving == 'birthdate',
              onTap: _saving == null ? _pickBirthdate : null,
            ),
            _DetailTile(
              icon: Icons.draw_outlined,
              label: 'Signature',
              value: auth.signatureUrl.isEmpty ? 'Draw signature' : 'Redraw',
              busy: _saving == 'signature',
              onTap: _saving == null ? _drawSignature : null,
            ),
            _DetailTile(
              icon: Icons.home_outlined,
              label: 'Address',
              value: auth.collectorAddress.isEmpty
                  ? 'Set address'
                  : auth.collectorAddress,
              busy: false,
              onTap: _saving == null ? _editAddress : null,
            ),
            const SizedBox(height: 20),
            const _SectionTitle('VERIFICATION STATUS'),
            if (auth.verificationDocs.isEmpty)
              const _VerifyItem('No documents on file', false)
            else
              for (final d in auth.verificationDocs)
                _VerifyItem(
                  d['type'] as String? ?? 'Document',
                  (d['status'] as String? ?? '').toLowerCase() == 'verified',
                ),
            const SizedBox(height: 20),
            Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                    color: AppColors.pureWhite,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.divider)),
                child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _SectionTitle('SHOW THIS CARD TO'),
                      _ShowToItem('Subdivision Guards'),
                      _ShowToItem('Households Before Entry'),
                      _ShowToItem('Business Owners'),
                      _ShowToItem('Barangay Officials'),
                    ])),
            const SizedBox(height: 20),
            Row(children: [
              Expanded(
                  child: _ActionBtn(
                      'DOWNLOAD',
                      AppColors.buyerBlue,
                      Colors.white,
                      () => ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('ID Card downloaded'))))),
              const SizedBox(width: 8),
              Expanded(
                  child: _ActionBtn(
                      'SHARE', Colors.transparent, AppColors.textPrimary, () {
                setState(() => _mode = 2);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text('Card shared!'),
                    duration: Duration(seconds: 2)));
              })),
              const SizedBox(width: 8),
              Expanded(
                  child: _ActionBtn(
                      'REPORT LOST',
                      AppColors.error.withValues(alpha: 0.05),
                      AppColors.error,
                      () => showDialog(
                          context: context,
                          builder: (c) => AlertDialog(
                                  title: const Text('Report Lost Card'),
                                  content: const Text(
                                      'Your card will be revoked and reissued after verification.'),
                                  actions: [
                                    TextButton(
                                        onPressed: () => Navigator.pop(c),
                                        child: const Text('Cancel')),
                                    TextButton(
                                        onPressed: () {
                                          Navigator.pop(c);
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(const SnackBar(
                                                  content: Text(
                                                      'Report submitted. Card reissue pending.')));
                                        },
                                        child: const Text('Report',
                                            style: TextStyle(
                                                color: AppColors.error)))
                                  ])))),
            ]),
            const SizedBox(height: 30),
          ]),
    );
  }
}

class _InitialsBox extends StatelessWidget {
  final String initials;
  final bool showAddHint;
  const _InitialsBox(this.initials, {this.showAddHint = false});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(initials,
            style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w900,
                color: Colors.white)),
        if (showAddHint) ...[
          const SizedBox(height: 4),
          const Icon(Icons.add_a_photo_outlined,
              size: 14, color: Colors.white70),
        ],
      ],
    );
  }
}

class _CardField extends StatelessWidget {
  final String label;
  final String value;
  const _CardField(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w800,
                color: Colors.white60,
                letterSpacing: 1)),
        const SizedBox(height: 2),
        Text(value,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.white)),
      ],
    );
  }
}

class _DetailTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool busy;
  final VoidCallback? onTap;
  const _DetailTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.busy,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: Colors.white,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: Color(0xFFE5E7EB), width: 1.5)),
        clipBehavior: Clip.antiAlias,
        child: ListTile(
          onTap: onTap,
          leading: Icon(icon, color: AppColors.buyerBlue),
          title: Text(label,
              style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  color: Color(0xFF111827))),
          subtitle: Text(value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
          trailing: busy
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2))
              : const Icon(Icons.chevron_right, color: AppColors.textMuted),
        ),
      ),
    );
  }
}

class _ModeButton extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;
  const _ModeButton(
      {required this.label, required this.active, required this.onTap});
  @override
  Widget build(BuildContext context) => Expanded(
          child: GestureDetector(
        onTap: onTap,
        child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
                color: active ? AppColors.buyerBlue : Colors.white,
                border: Border.all(
                    color:
                        active ? AppColors.buyerBlue : const Color(0xFFE5E7EB),
                    width: 1.5),
                borderRadius: BorderRadius.circular(12)),
            child: Text(label,
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: active ? Colors.white : const Color(0xFF6B7280)))),
      ));
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);
  @override
  Widget build(BuildContext context) => Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(text,
          style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF6B7280),
              fontWeight: FontWeight.w800,
              letterSpacing: 1.5)));
}

class _VerifyItem extends StatelessWidget {
  final String label;
  final bool ok;
  const _VerifyItem(this.label, this.ok);
  @override
  Widget build(BuildContext context) {
    final color = ok ? AppColors.success : AppColors.warning;
    return Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE5E7EB), width: 1.5)),
        child: Row(children: [
          Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1), shape: BoxShape.circle),
              child: Center(
                  child: Icon(ok ? Icons.check_circle : Icons.hourglass_top,
                      size: 16, color: color))),
          const SizedBox(width: 12),
          Expanded(
              child: Text(label,
                  style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      color: Color(0xFF111827)))),
          Text(ok ? 'Verified' : 'Pending',
              style: TextStyle(
                  fontSize: 12, fontWeight: FontWeight.w700, color: color))
        ]));
  }
}

class _ShowToItem extends StatelessWidget {
  final String text;
  const _ShowToItem(this.text);
  @override
  Widget build(BuildContext context) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(children: [
        Container(
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
                color: AppColors.buyerBlue, shape: BoxShape.circle)),
        const SizedBox(width: 12),
        Text(text,
            style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF4B5563)))
      ]));
}

class _ActionBtn extends StatelessWidget {
  final String label;
  final Color bg, fg;
  final VoidCallback onTap;
  const _ActionBtn(this.label, this.bg, this.fg, this.onTap);
  @override
  Widget build(BuildContext context) => ElevatedButton(
      style: ElevatedButton.styleFrom(
          backgroundColor: bg,
          foregroundColor: fg,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          side: bg == Colors.transparent
              ? const BorderSide(color: Color(0xFFE5E7EB), width: 1.5)
              : BorderSide.none),
      onPressed: onTap,
      child: Text(label,
          style: const TextStyle(
              fontSize: 12, fontWeight: FontWeight.w800, letterSpacing: 0.5)));
}
