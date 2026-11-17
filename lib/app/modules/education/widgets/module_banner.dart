import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;
import '../../../core/constants/api_constants.dart';
import '../../../core/theme/app_theme.dart';

class ModuleBanner extends StatefulWidget {
  final String? bannerImage;
  final int moduleNumber;
  final String? title;
  final double? height;
  final double? width;
  final BorderRadius? borderRadius;
  final BoxFit fit;
  final bool useModuleFallback;
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
    this.useModuleFallback = false,
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
    final url = ModuleBanner.resolveUrl(
      widget.bannerImage,
      widget.moduleNumber,
    );
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
          return _buildLoadingPlaceholder(context);
        },
        errorBuilder: (context, error, stackTrace) => _buildFallback(context),
      );
    } else if (_isLoading && !_hasError) {
      imageWidget = _buildLoadingPlaceholder(context);
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
              ? AppTheme.softAccentSurfaceDark
              : AppTheme.primary50,
          borderRadius: effectiveRadius,
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [imageWidget, ?widget.overlay],
        ),
      ),
    );
  }

  Widget _buildLoadingPlaceholder(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      color: isDark ? AppTheme.surfaceDark : AppTheme.backgroundLight,
      child: Center(
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            semanticsLabel: 'Memuat gambar materi',
            valueColor: AlwaysStoppedAnimation<Color>(
              isDark ? AppTheme.primary500 : AppTheme.primary700,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFallback(BuildContext context) {
    if (widget.useModuleFallback) return _buildModuleFallback(context);
    return Image.asset(
      'assets/banner/banner.png',
      fit: widget.fit,
      errorBuilder: (context, error, stackTrace) =>
          _buildModuleFallback(context),
    );
  }

  Widget _buildModuleFallback(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      color: isDark ? AppTheme.softAccentSurfaceDark : AppTheme.primary50,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Modul ${widget.moduleNumber}',
            style: TextStyle(
              color: isDark
                  ? AppTheme.textSecondaryDark
                  : AppTheme.textSecondaryLight,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          if (widget.title != null && widget.title!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              widget.title!,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: isDark
                    ? AppTheme.textPrimaryDark
                    : AppTheme.textPrimaryLight,
                fontSize: 16,
                height: 1.3,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
