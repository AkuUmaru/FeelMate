import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:myapp/pages/dashboard/camera_capture_screen.dart';
import 'package:myapp/services/fer_service.dart';
import 'package:myapp/utils/colors.dart';
import 'package:image_picker/image_picker.dart';

class InputPage extends StatefulWidget {
  final Function(String result)? onFinish;
  final bool startWithCamera;
  const InputPage({super.key, this.onFinish, this.startWithCamera = false});

  @override
  State<InputPage> createState() => _InputPageState();
}

class _InputPageState extends State<InputPage> {
  XFile? _image;
  Uint8List? _imageBytes;
  bool _isUploading = false;
  bool _isModelLoading = false;
  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    if (widget.startWithCamera) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _openInAppCamera();
      });
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    final XFile? pickedFile = await _imagePicker.pickImage(
      source: source,
      imageQuality: 90,
    );
    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      setState(() {
        _image = pickedFile;
        _imageBytes = bytes;
      });
    }
  }

  Future<void> _openInAppCamera() async {
    final XFile? capturedFile = await Navigator.of(context).push<XFile>(
      MaterialPageRoute(builder: (_) => const CameraCaptureScreen()),
    );
    if (capturedFile != null) {
      final bytes = await capturedFile.readAsBytes();
      setState(() {
        _image = capturedFile;
        _imageBytes = bytes;
      });
    }
  }

  void _showSourceDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Text('Select Image Source 📷',
                style: GoogleFonts.nunito(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: kTextDark)),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _sourceOption(
                    icon: Icons.camera_alt_rounded,
                    label: 'Take Photo',
                    onTap: () {
                      Navigator.pop(context);
                      _openInAppCamera();
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _sourceOption(
                    icon: Icons.photo_library_rounded,
                    label: 'Choose Gallery',
                    onTap: () {
                      Navigator.pop(context);
                      _pickImage(ImageSource.gallery);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _sourceOption(
      {required IconData icon,
      required String label,
      required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: kPrimaryLight,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: kPrimaryColor.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: kPrimaryColor, size: 36),
            const SizedBox(height: 10),
            Text(label,
                style: GoogleFonts.nunito(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: kTextDark)),
          ],
        ),
      ),
    );
  }

  Future<void> _uploadImage() async {
    if (_image == null || _imageBytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select or capture a photo first.')),
      );
      return;
    }
    setState(() {
      _isUploading = true;
      _isModelLoading = false;
    });
    try {
      final result = await FerService.classify(
        _imageBytes!,
        _image!.name,
      );
      _showSuccessDialog(result);
    } on FerException catch (e) {
      final msg = e.message;
      if (msg.contains('loading') || msg.contains('503')) {
        setState(() => _isModelLoading = true);
        _showError(
          'The AI model is warming up (~20 s). Please tap Analyze again in a moment.',
        );
      } else {
        _showError('Classification failed: $msg');
      }
    } catch (e) {
      _showError('Unexpected error: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isUploading = false;
        });
      }
    }
  }

  void _showSuccessDialog(String fullResult) async {
    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: kPrimaryColor, size: 24),
            const SizedBox(width: 8),
            Text('Scan Complete!',
                style: GoogleFonts.nunito(fontWeight: FontWeight.w900, color: kTextDark)),
          ],
        ),
        content: Text('Your emotion has been detected! Tap OK to view results.',
            style: GoogleFonts.nunito(fontSize: 14, fontWeight: FontWeight.w600, color: kTextMuted)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('OK',
                style: GoogleFonts.nunito(
                    color: kPrimaryColor, fontWeight: FontWeight.w900, fontSize: 15)),
          ),
        ],
      ),
    );
    widget.onFinish?.call(fullResult);
    if (mounted) {
      FocusScope.of(context).unfocus();
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: const Color(0xFFDC2626)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Classify Emotion 📸',
                  style: GoogleFonts.nunito(
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      color: kTextDark)),
              const SizedBox(height: 2),
              Text('Take or upload a photo to analyze facial emotion',
                  style: GoogleFonts.nunito(
                      fontSize: 14, fontWeight: FontWeight.w600, color: kTextMuted)),
              const SizedBox(height: 24),

              // Upload Container
              GestureDetector(
                onTap: _showSourceDialog,
                child: Container(
                  width: double.infinity,
                  height: 280,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: const Color(0xFFCBD5E1), width: 1.5),
                    boxShadow: const [kCardShadow],
                  ),
                  clipBehavior: Clip.hardEdge,
                  child: _imageBytes == null
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: const BoxDecoration(
                                color: kPrimaryLight,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.add_a_photo_rounded,
                                  size: 40, color: kPrimaryColor),
                            ),
                            const SizedBox(height: 14),
                            Text('Tap to capture or pick a photo',
                                style: GoogleFonts.nunito(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w800,
                                    color: kPrimaryColor)),
                            const SizedBox(height: 4),
                            Text('Camera or Photo Gallery',
                                style: GoogleFonts.nunito(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: kTextMuted)),
                          ],
                        )
                      : Stack(
                          fit: StackFit.expand,
                          children: [
                            Image.memory(_imageBytes!, fit: BoxFit.cover),
                            Positioned(
                              right: 12,
                              top: 12,
                              child: GestureDetector(
                                onTap: _showSourceDialog,
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withValues(alpha: 0.65),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Icon(Icons.edit_rounded,
                                      color: Colors.white, size: 18),
                                ),
                              ),
                            ),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 20),

              // Tips
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFFBEB),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFFDE68A)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.lightbulb_rounded,
                        color: Color(0xFFD97706), size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Tip: For highest accuracy, use a clear, well-lit face photo facing forward.',
                        style: GoogleFonts.nunito(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF92400E),
                            height: 1.45),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 26),

              // Analyze Button
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton.icon(
                  onPressed: _isUploading ? null : _uploadImage,
                  icon: _isUploading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2.5))
                      : const Icon(Icons.center_focus_strong_rounded, color: Colors.white, size: 22),
                  label: Text(
                    _isUploading ? 'Analyzing...' : 'Analyze Facial Emotion',
                    style: GoogleFonts.nunito(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kPrimaryColor,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                ),
              ),
              if (_isModelLoading) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFBFDBFE)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline_rounded, color: Color(0xFF2563EB), size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'The AI model is warming up (~20s). Tap Analyze again in a moment!',
                          style: GoogleFonts.nunito(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF1E40AF),
                              height: 1.4),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
