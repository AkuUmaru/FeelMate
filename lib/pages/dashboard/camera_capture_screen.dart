import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:myapp/services/fer_service.dart';
import 'package:myapp/utils/colors.dart';

/// Unified Face Scan page — GoPay-style camera scanner.
///
/// Features:
/// • Live front-facing camera with animated scan-line indicator
/// • Gallery import button (top-right) — no need to leave the page
/// • Shutter capture button at the bottom
/// • "Analyze Facial Emotion" CTA button below shutter
/// • After capture/gallery pick → image preview replaces live feed
/// • Calls [onFinish] with the FER JSON result on success
class CameraCaptureScreen extends StatefulWidget {
  final Function(String result)? onFinish;

  /// Called when the user taps the close (X) button. Used when this screen is
  /// hosted as a tab (not a pushed route) so it can hand control back to the
  /// host instead of popping the whole dashboard off the navigator (black
  /// screen). Falls back to `Navigator.pop` when null.
  final VoidCallback? onClose;

  const CameraCaptureScreen({super.key, this.onFinish, this.onClose});

  @override
  State<CameraCaptureScreen> createState() => _CameraCaptureScreenState();
}

class _CameraCaptureScreenState extends State<CameraCaptureScreen>
    with TickerProviderStateMixin {
  // ── Camera ──────────────────────────────────────────────────────────────────
  CameraController? _controller;
  Future<void>? _initFuture;

  // ── Image state ─────────────────────────────────────────────────────────────
  XFile? _capturedFile;
  Uint8List? _imageBytes;

  // ── Processing ──────────────────────────────────────────────────────────────
  bool _isAnalyzing = false;
  bool _isModelLoading = false;

  // ── Animations ──────────────────────────────────────────────────────────────
  late final AnimationController _scanLineCtrl;
  late final Animation<double> _scanLineAnim;
  late final AnimationController _pulseCtrl;
  late final Animation<double> _pulseAnim;

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();

    // Scan-line sweeps top → bottom repeatedly
    _scanLineCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat();
    _scanLineAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _scanLineCtrl, curve: Curves.easeInOut),
    );

    // Corner pulse breathes slowly
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );

    _initFuture = _initCamera();
  }

  Future<void> _initCamera() async {
    final cameras = await availableCameras();
    if (cameras.isEmpty) return;
    final front = cameras.firstWhere(
      (c) => c.lensDirection == CameraLensDirection.front,
      orElse: () => cameras.first,
    );
    final controller = CameraController(
      front,
      ResolutionPreset.medium,
      enableAudio: false,
    );
    await controller.initialize();
    if (!mounted) return;
    setState(() => _controller = controller);
  }

  Future<void> _capture() async {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) return;
    try {
      final file = await controller.takePicture();
      final bytes = await file.readAsBytes();
      setState(() {
        _capturedFile = file;
        _imageBytes = bytes;
      });
    } catch (_) {}
  }

  Future<void> _pickFromGallery() async {
    final file = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 90,
    );
    if (file != null) {
      final bytes = await file.readAsBytes();
      setState(() {
        _capturedFile = file;
        _imageBytes = bytes;
      });
    }
  }

  void _retake() {
    setState(() {
      _capturedFile = null;
      _imageBytes = null;
      _isAnalyzing = false;
      _isModelLoading = false;
    });
  }

  Future<void> _analyze() async {
    if (_imageBytes == null || _capturedFile == null) return;
    setState(() {
      _isAnalyzing = true;
      _isModelLoading = false;
    });
    try {
      final result = await FerService.classify(_imageBytes!, _capturedFile!.name);
      if (!mounted) return;
      _showSuccessDialog(result);
    } on FerException catch (e) {
      if (!mounted) return;
      final msg = e.message;
      if (msg.contains('loading') || msg.contains('503')) {
        setState(() => _isModelLoading = true);
        _showError('AI model warming up (~20s). Tap Analyze again in a moment.');
      } else {
        _showError(msg);
      }
    } catch (e) {
      if (!mounted) return;
      _showError('Unexpected error: $e');
    } finally {
      if (mounted) setState(() => _isAnalyzing = false);
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
                style: GoogleFonts.nunito(
                    fontWeight: FontWeight.w900, color: kTextDark)),
          ],
        ),
        content: Text(
          'Your emotion has been detected! Tap OK to view results.',
          style: GoogleFonts.nunito(
              fontSize: 14, fontWeight: FontWeight.w600, color: kTextMuted),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('OK',
                style: GoogleFonts.nunito(
                    color: kPrimaryColor,
                    fontWeight: FontWeight.w900,
                    fontSize: 15)),
          ),
        ],
      ),
    );
    widget.onFinish?.call(fullResult);
    // Only pop when used as a pushed route. In tab mode the host's onFinish
    // already navigates (to ResultPage); popping here would tear the whole
    // dashboard off the navigator → black screen.
    if (widget.onFinish == null && mounted) Navigator.of(context).pop();
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message,
          style: GoogleFonts.nunito(fontWeight: FontWeight.w700)),
      backgroundColor: const Color(0xFFDC2626),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ));
  }

  @override
  void dispose() {
    _controller?.dispose();
    _scanLineCtrl.dispose();
    _pulseCtrl.dispose();
    super.dispose();
  }

  // ── Build ────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: FutureBuilder<void>(
        future: _initFuture,
        builder: (context, snapshot) {
          final camReady =
              _controller != null && _controller!.value.isInitialized;

          return Stack(
            fit: StackFit.expand,
            children: [
              // ── Background: camera preview or captured image ──────────────
              if (_imageBytes != null)
                Image.memory(_imageBytes!, fit: BoxFit.cover)
              else if (camReady)
                _buildCameraPreview()
              else
                const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                ),

              // ── Dark gradient vignette (top & bottom) ─────────────────────
              _buildVignette(),

              // ── Viewfinder overlay (only when live camera, no captured image) ──
              if (_imageBytes == null && camReady) _buildViewfinderOverlay(),

              // ── Captured image preview frame ──────────────────────────────
              if (_imageBytes != null) _buildPreviewFrame(),

              // ── Top bar ───────────────────────────────────────────────────
              _buildTopBar(),

              // ── Bottom controls ───────────────────────────────────────────
              _buildBottomControls(camReady),
            ],
          );
        },
      ),
    );
  }

  // ── Camera preview ──────────────────────────────────────────────────────────

  Widget _buildCameraPreview() {
    final controller = _controller!;
    return OverflowBox(
      maxWidth: double.infinity,
      maxHeight: double.infinity,
      child: FittedBox(
        fit: BoxFit.cover,
        child: SizedBox(
          width: controller.value.previewSize!.height,
          height: controller.value.previewSize!.width,
          child: CameraPreview(controller),
        ),
      ),
    );
  }

  // ── Vignette ────────────────────────────────────────────────────────────────

  Widget _buildVignette() {
    return IgnorePointer(
      child: Column(
        children: [
          Container(
            height: 160,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xCC000000), Colors.transparent],
              ),
            ),
          ),
          const Spacer(),
          Container(
            height: 280,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [Color(0xDD000000), Colors.transparent],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Viewfinder overlay ──────────────────────────────────────────────────────

  Widget _buildViewfinderOverlay() {
    return Center(
      child: SizedBox(
        width: 260,
        height: 260,
        child: Stack(
          children: [
            // Corner brackets
            AnimatedBuilder(
              animation: _pulseAnim,
              builder: (_, __) => CustomPaint(
                size: const Size(260, 260),
                painter: _CornerBracketPainter(
                  color: kPrimaryColor.withValues(alpha: _pulseAnim.value),
                  strokeWidth: 3.5,
                  bracketSize: 28,
                  radius: 16,
                ),
              ),
            ),
            // Scan line
            AnimatedBuilder(
              animation: _scanLineAnim,
              builder: (_, __) => Positioned(
                top: _scanLineAnim.value * 248,
                left: 16,
                right: 16,
                child: Container(
                  height: 2,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        kPrimaryColor.withValues(alpha: 0.9),
                        kPrimaryColor,
                        kPrimaryColor.withValues(alpha: 0.9),
                        Colors.transparent,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(1),
                    boxShadow: [
                      BoxShadow(
                        color: kPrimaryColor.withValues(alpha: 0.6),
                        blurRadius: 8,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Captured image preview frame ─────────────────────────────────────────────

  Widget _buildPreviewFrame() {
    return Center(
      child: Container(
        width: 280,
        height: 280,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: kPrimaryColor, width: 2.5),
          boxShadow: [
            BoxShadow(
              color: kPrimaryColor.withValues(alpha: 0.35),
              blurRadius: 20,
              spreadRadius: 2,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(17.5),
          child: Image.memory(_imageBytes!, fit: BoxFit.cover),
        ),
      ),
    );
  }

  // ── Top bar ─────────────────────────────────────────────────────────────────

  Widget _buildTopBar() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Close button
            _iconBtn(Icons.close_rounded, () {
              if (widget.onClose != null) {
                widget.onClose!();
              } else {
                Navigator.of(context).pop();
              }
            }),

            // Title
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _imageBytes != null ? 'Photo Ready' : 'Face Scan',
                  style: GoogleFonts.nunito(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.3,
                  ),
                ),
                Text(
                  _imageBytes != null
                      ? 'Tap Analyze to detect emotion'
                      : 'Position your face in the frame',
                  style: GoogleFonts.nunito(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),

            // Gallery button
            _iconBtn(
              Icons.photo_library_rounded,
              _pickFromGallery,
              badge: false,
            ),
          ],
        ),
      ),
    );
  }

  Widget _iconBtn(IconData icon, VoidCallback onTap, {bool badge = false}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.18),
          shape: BoxShape.circle,
          border: Border.all(
              color: Colors.white.withValues(alpha: 0.25), width: 1),
        ),
        child: Icon(icon, color: Colors.white, size: 22),
      ),
    );
  }

  // ── Bottom controls ─────────────────────────────────────────────────────────

  Widget _buildBottomControls(bool camReady) {
    final hasImage = _imageBytes != null;

    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Tips banner
              _buildTipsBanner(),
              const SizedBox(height: 20),

              // Model warming indicator
              if (_isModelLoading) ...[
                _buildModelLoadingBanner(),
                const SizedBox(height: 14),
              ],

              // Shutter row (retake on left, shutter center, gallery on right)
              if (!hasImage) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Left spacer (gallery already in top bar)
                    const SizedBox(width: 60),

                    // Shutter button
                    GestureDetector(
                      onTap: camReady ? _capture : null,
                      child: Container(
                        width: 76,
                        height: 76,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 4),
                          color: Colors.white.withValues(alpha: 0.18),
                        ),
                        child: Center(
                          child: Container(
                            width: 56,
                            height: 56,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                            ),
                            child: const Icon(
                              Icons.center_focus_strong_rounded,
                              color: kPrimaryColor,
                              size: 30,
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Right spacer
                    const SizedBox(width: 60),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Tap to capture',
                  style: GoogleFonts.nunito(
                    color: Colors.white.withValues(alpha: 0.6),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Analyze button (shown whether captured or not, grayed if no image)
              _buildAnalyzeButton(hasImage),

              // Retake button (only when image is captured)
              if (hasImage) ...[
                const SizedBox(height: 12),
                TextButton.icon(
                  onPressed: _retake,
                  icon: const Icon(Icons.refresh_rounded,
                      size: 18, color: Colors.white70),
                  label: Text(
                    'Retake Photo',
                    style: GoogleFonts.nunito(
                      color: Colors.white70,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTipsBanner() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
            color: const Color(0xFFFDE68A).withValues(alpha: 0.6), width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.lightbulb_rounded,
              color: Color(0xFFFBBF24), size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'For best results: look directly at the camera in a well-lit area. '
              'Keep your face clearly visible in the frame.',
              style: GoogleFonts.nunito(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: Colors.white.withValues(alpha: 0.9),
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModelLoadingBanner() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF1E40AF).withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          const SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
                color: Colors.white, strokeWidth: 2),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'AI model is warming up (~20s). Tap Analyze again in a moment!',
              style: GoogleFonts.nunito(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalyzeButton(bool hasImage) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton.icon(
        onPressed: (_isAnalyzing || !hasImage) ? null : _analyze,
        icon: _isAnalyzing
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                    color: Colors.white, strokeWidth: 2.5))
            : const Icon(Icons.analytics_rounded,
                color: Colors.white, size: 22),
        label: Text(
          _isAnalyzing
              ? 'Analyzing Emotion...'
              : hasImage
                  ? 'Analyze Facial Emotion'
                  : 'Capture or pick a photo first',
          style: GoogleFonts.nunito(
            fontSize: 15,
            fontWeight: FontWeight.w900,
            color: Colors.white,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor:
              hasImage ? kPrimaryColor : Colors.white.withValues(alpha: 0.25),
          disabledBackgroundColor: hasImage
              ? kPrimaryColor.withValues(alpha: 0.7)
              : Colors.white.withValues(alpha: 0.15),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: hasImage ? 4 : 0,
          shadowColor: kPrimaryColor.withValues(alpha: 0.4),
        ),
      ),
    );
  }
}

// ── Corner bracket painter ────────────────────────────────────────────────────

class _CornerBracketPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double bracketSize;
  final double radius;

  _CornerBracketPainter({
    required this.color,
    required this.strokeWidth,
    required this.bracketSize,
    required this.radius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final w = size.width;
    final h = size.height;
    final b = bracketSize;
    final r = radius;

    // Top-left
    _drawCorner(canvas, paint, Offset(0, r), Offset(r, 0), b, r, 0);
    // Top-right
    _drawCorner(canvas, paint, Offset(w - r, 0), Offset(w, r), b, r, 1);
    // Bottom-right
    _drawCorner(canvas, paint, Offset(w, h - r), Offset(w - r, h), b, r, 2);
    // Bottom-left
    _drawCorner(canvas, paint, Offset(r, h), Offset(0, h - r), b, r, 3);
  }

  void _drawCorner(Canvas canvas, Paint paint, Offset p1, Offset p2,
      double len, double r, int corner) {
    final path = Path();
    switch (corner) {
      case 0: // top-left
        path.moveTo(p1.dx, p1.dy + len - r);
        path.arcToPoint(Offset(p1.dx + r, p1.dy), radius: Radius.circular(r));
        path.lineTo(p2.dx + len, p2.dy);
        break;
      case 1: // top-right
        path.moveTo(p1.dx - len, p1.dy);
        path.arcToPoint(Offset(p2.dx, p2.dy - r), radius: Radius.circular(r));
        path.lineTo(p2.dx, p2.dy + len - r);
        break;
      case 2: // bottom-right
        path.moveTo(p1.dx, p1.dy - len + r);
        path.arcToPoint(Offset(p1.dx - r, p1.dy), radius: Radius.circular(r));
        path.lineTo(p2.dx - len, p2.dy);
        break;
      case 3: // bottom-left
        path.moveTo(p1.dx + len, p1.dy);
        path.arcToPoint(Offset(p2.dx, p2.dy + r), radius: Radius.circular(r));
        path.lineTo(p2.dx, p2.dy - len + r);
        break;
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_CornerBracketPainter old) =>
      old.color != color || old.strokeWidth != strokeWidth;
}
