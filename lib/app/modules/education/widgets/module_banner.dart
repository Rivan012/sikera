import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;
import '../../../core/constants/api_constants.dart';
import '../../../core/theme/app_theme.dart';

/// Widget serbaguna untuk menampilkan banner modul edukasi SIKERA.
/// Mendukung:
/// - Format SVG dinamis dari API backend via [SvgPicture.string] dengan in-memory cache
/// - Format raster (PNG, JPG, WebP) via [Image.network]
/// - Resolusi otomatis URL endpoint API (`/api/v1/modules/{id}/banner.svg`)
/// - Resolusi otomatis URL relatif backend (`/images/banners/...`)
/// - Fallback estetik dengan aset lokal & gradien bertema jika gambar offline/null
class ModuleBanner extends StatefulWidget {
  final String? bannerImage;
  final int moduleNumber;
  final String? title;
  final double? height;
  final double? width;
  final BorderRadius? borderRadius;
  final BoxFit fit;
  final Widget? overlay;
  final Key? bannerKey;

  const ModuleBanner({
    super.key,
    this.bannerImage,
    required this.moduleNumber,
    this.title,
    this.height,
    this.width,
    this.borderRadius,
    this.fit = BoxFit.cover,
    this.overlay,
    this.bannerKey,
  });

  /// Normalisasi URL gambar dari backend / endpoint API
  static String resolveUrl(String? raw, [int moduleNumber = 1]) {
    String url;
    if (raw == null || raw.trim().isEmpty) {
      url = '${ApiConstants.baseUrl}/modules/$moduleNumber/banner.svg';
    } else {
      final trimmed = raw.trim();
      if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
        url = trimmed;
      } else {
        final serverBase = ApiConstants.baseUrl.replaceAll('/api/v1', '');
        final cleanPath = trimmed.startsWith('/') ? trimmed : '/$trimmed';
        url = '$serverBase$cleanPath';
      }
    }

    // Penyesuaian host untuk Android emulator
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      if (ApiConstants.baseUrl.contains('10.0.2.2')) {
        url = url
            .replaceAll('127.0.0.1:8000', '10.0.2.2:8000')
            .replaceAll('localhost:8000', '10.0.2.2:8000');
      }
    }

    return url;
  }

  @override
  State<ModuleBanner> createState() => _ModuleBannerState();
}

class _ModuleBannerState extends State<ModuleBanner> {
  static final Map<String, String> _svgCache = {};
  String? _svgString;
  bool _isLoading = true;
  bool _isRaster = false;
  bool _hasError = false;
  String? _activeUrl;

  @override
  void initState() {
    super.initState();
    _loadBanner();
  }

  @override
  void didUpdateWidget(covariant ModuleBanner oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.bannerImage != widget.bannerImage ||
        oldWidget.moduleNumber != widget.moduleNumber) {
      _loadBanner();
    }
  }

  Future<void> _loadBanner() async {
    final url = ModuleBanner.resolveUrl(widget.bannerImage, widget.moduleNumber);
    _activeUrl = url;

    // 1. Cek memory cache untuk SVG yang sudah pernah di-fetch
    if (_svgCache.containsKey(url)) {
      if (mounted) {
        setState(() {
          _svgString = _svgCache[url];
          _isLoading = false;
          _isRaster = false;
          _hasError = false;
        });
      }
      return;
    }

    // 2. Jika secara eksplisit file raster statis
    final lower = url.toLowerCase();
    if (lower.endsWith('.png') ||
        lower.endsWith('.jpg') ||
        lower.endsWith('.jpeg') ||
        lower.endsWith('.webp')) {
      if (mounted) {
        setState(() {
          _isRaster = true;
          _isLoading = false;
          _hasError = false;
        });
      }
      return;
    }

    // 3. Muat via HTTP (Mendukung SVG dari endpoint API maupun file statis)
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      final response = await http
          .get(
            Uri.parse(url),
            headers: {'Accept': 'image/svg+xml, image/*, */*'},
          )
          .timeout(const Duration(seconds: 8));

      if (!mounted || _activeUrl != url) return;

      if (response.statusCode == 200) {
        final body = response.body;
        if (body.contains('<svg') && body.contains('</svg>')) {
          _svgCache[url] = body;
          setState(() {
            _svgString = body;
            _isLoading = false;
            _isRaster = false;
            _hasError = false;
          });
        } else {
          // Binary raster stream
          setState(() {
            _isRaster = true;
            _isLoading = false;
            _hasError = false;
          });
        }
      } else {
        setState(() {
          _hasError = true;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (!mounted || _activeUrl != url) return;
      setState(() {
        _hasError = true;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final effectiveRadius =
        widget.borderRadius ?? BorderRadius.circular(AppTheme.radiusLg);

    Widget imageWidget;
    if (_svgString != null) {
      imageWidget = SvgPicture.string(
        _svgString!,
        fit: widget.fit,
        width: widget.width ?? double.infinity,
        height: widget.height,
      );
    } else if (_isRaster && _activeUrl != null) {
      imageWidget = Image.network(
        _activeUrl!,
        fit: widget.fit,
        width: widget.width ?? double.infinity,
        height: widget.height,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return _buildShimmerOrPlaceholder(context);
        },
        errorBuilder: (context, error, stackTrace) => _buildFallback(context),
      );
    } else if (_isLoading && !_hasError) {
      imageWidget = _buildShimmerOrPlaceholder(context);
    } else {
      imageWidget = _buildFallback(context);
    }

    return ClipRRect(
      key: widget.bannerKey,
      borderRadius: effectiveRadius,
      child: Container(
        width: widget.width ?? double.infinity,
        height: widget.height,
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark
              ? AppTheme.surfaceDark
              : AppTheme.primary900,
          borderRadius: effectiveRadius,
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            imageWidget,
            ?widget.overlay,
          ],
        ),
      ),
    );
  }

  Widget _buildShimmerOrPlaceholder(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
      child: Center(
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(
              isDark ? AppTheme.primary500 : AppTheme.primary700,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFallback(BuildContext context) {
    return Image.asset(
      'assets/banner/banner.png',
      fit: widget.fit,
      errorBuilder: (context, error, stackTrace) =>
          _buildGradientFallback(context),
    );
  }

  Widget _buildGradientFallback(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Menentukan tema palet berdasarkan nomor modul
    final List<Color> colors;
    switch (widget.moduleNumber % 4) {
      case 1:
        colors = isDark
            ? const [Color(0xFF0F766E), Color(0xFF042F2E)]
            : const [Color(0xFF0D9488), Color(0xFF115E59)];
        break;
      case 2:
        colors = isDark
            ? const [Color(0xFF1D4ED8), Color(0xFF1E1B4B)]
            : const [Color(0xFF2563EB), Color(0xFF1E40AF)];
        break;
      case 3:
        colors = isDark
            ? const [Color(0xFFB45309), Color(0xFF451A03)]
            : const [Color(0xFFD97706), Color(0xFF92400E)];
        break;
      default:
        colors = isDark
            ? const [Color(0xFFBE123C), Color(0xFF4C0519)]
            : const [Color(0xFFE11D48), Color(0xFF9F1239)];
    }

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: colors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'MODUL ${widget.moduleNumber}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10.5,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                if (widget.title != null && widget.title!.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    widget.title!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),
          Icon(
            Icons.menu_book_rounded,
            size: 40,
            color: Colors.white.withValues(alpha: 0.35),
          ),
        ],
      ),
    );
  }
}
