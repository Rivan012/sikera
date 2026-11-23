import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;
import '../../../core/constants/api_constants.dart';
import '../../../core/theme/app_theme.dart';

class ModuleBanner extends StatefulWidget {
  static bool useStaticPlaceholderBanner = false;
  static const String staticPlaceholderAsset = 'assets/banner/banner.png';

  @visibleForTesting
  static void clearCache() {
    _ModuleBannerState._svgCache.clear();
    _ModuleBannerState._rasterCache.clear();
  }

  final String? bannerImage;
  final int moduleId;
  final int moduleNumber;
  final String? title;
  final double? height;
  final double? width;
  final BorderRadius? borderRadius;
  final BoxFit fit;
  final AlignmentGeometry alignment;
  final bool useModuleFallback;
  final Widget? overlay;
  final Key? bannerKey;
  final Color? backgroundColor;

  const ModuleBanner({
    super.key,
    this.bannerImage,
    required this.moduleId,
    required this.moduleNumber,
    this.title,
    this.height,
    this.width,
    this.borderRadius,
    this.fit = BoxFit.cover,
    this.alignment = Alignment.center,
    this.useModuleFallback = false,
    this.overlay,
    this.bannerKey,
    this.backgroundColor,
  });

  /// Normalisasi URL gambar dari backend / endpoint API
  static String resolveUrl(String? raw, int moduleId) {
    String url;
    if (raw == null || raw.trim().isEmpty) {
      url = '${ApiConstants.baseUrl}${ApiConstants.moduleBanner(moduleId)}';
    } else {
      final trimmed = raw.trim();
      if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
        url = trimmed;
      } else {
        final serverBase = Uri.parse(ApiConstants.baseUrl).origin;
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
  static final Map<String, Uint8List> _rasterCache = {};

  String? _svgString;
  Uint8List? _rasterBytes;
  bool _isLoading = true;
  String? _activeUrl;

  @override
  void initState() {
    super.initState();
    _loadBanner(fromUpdate: false);
  }

  @override
  void didUpdateWidget(covariant ModuleBanner oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.bannerImage != widget.bannerImage ||
        oldWidget.moduleId != widget.moduleId) {
      _loadBanner(fromUpdate: true);
    }
  }

  Future<void> _loadBanner({required bool fromUpdate}) async {
    if (ModuleBanner.useStaticPlaceholderBanner) {
      _isLoading = false;
      if (fromUpdate && mounted) setState(() {});
      return;
    }

    final url = ModuleBanner.resolveUrl(widget.bannerImage, widget.moduleId);
    _activeUrl = url;

    final cachedSvg = _svgCache[url];
    final cachedRaster = _rasterCache[url];
    if (cachedSvg != null || cachedRaster != null) {
      _svgString = cachedSvg;
      _rasterBytes = cachedRaster;
      _isLoading = false;
      if (fromUpdate && mounted) setState(() {});
      return;
    }

    _svgString = null;
    _rasterBytes = null;
    _isLoading = true;
    if (fromUpdate && mounted) setState(() {});

    try {
      final response = await http
          .get(
            Uri.parse(url),
            headers: const {'Accept': 'image/svg+xml, image/*, */*'},
          )
          .timeout(const Duration(seconds: 15));

      if (!mounted || _activeUrl != url) return;

      if (response.statusCode == 200 && response.bodyBytes.isNotEmpty) {
        final mime = response.headers['content-type']
            ?.split(';')
            .first
            .trim()
            .toLowerCase();
        final bytes = response.bodyBytes;
        final isSvg =
            mime == 'image/svg+xml' ||
            (mime?.startsWith('image/') != true &&
                utf8
                    .decode(bytes.take(512).toList(), allowMalformed: true)
                    .contains('<svg'));
        if (isSvg) {
          _svgString = utf8.decode(bytes);
          _svgCache[url] = _svgString!;
        } else {
          _rasterBytes = bytes;
          _rasterCache[url] = bytes;
        }
      }
    } catch (_) {
      if (!mounted || _activeUrl != url) return;
    }
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final effectiveRadius =
        widget.borderRadius ?? BorderRadius.circular(AppTheme.radiusLg);

    Widget imageWidget;
    if (ModuleBanner.useStaticPlaceholderBanner) {
      imageWidget = Image.asset(
        ModuleBanner.staticPlaceholderAsset,
        fit: widget.fit,
        alignment: widget.alignment,
        width: widget.width ?? double.infinity,
        height: widget.height,
        errorBuilder: (context, error, stackTrace) => _buildFallback(context),
      );
    } else if (_svgString != null) {
      imageWidget = SvgPicture.string(
        _svgString!,
        fit: widget.fit,
        alignment: widget.alignment,
        width: widget.width ?? double.infinity,
        height: widget.height,
        errorBuilder: (context, error, stackTrace) => _buildFallback(context),
      );
    } else if (_rasterBytes != null) {
      imageWidget = Image.memory(
        _rasterBytes!,
        fit: widget.fit,
        alignment: widget.alignment,
        width: widget.width ?? double.infinity,
        height: widget.height,
        errorBuilder: (context, error, stackTrace) => _buildFallback(context),
      );
    } else if (_isLoading) {
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
          color:
              widget.backgroundColor ??
              (Theme.of(context).brightness == Brightness.dark
                  ? AppTheme.softAccentSurfaceDark
                  : AppTheme.primary50),
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
      ModuleBanner.staticPlaceholderAsset,
      fit: widget.fit,
      alignment: widget.alignment,
      errorBuilder: (context, error, stackTrace) =>
          _buildModuleFallback(context),
    );
  }

  Widget _buildModuleFallback(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final compact = (widget.height ?? 160) < 150;
    final enlargedText = MediaQuery.textScalerOf(context).scale(16) > 22;
    return Container(
      color: isDark ? AppTheme.softAccentSurfaceDark : AppTheme.primary50,
      padding: EdgeInsets.symmetric(
        horizontal: 16,
        vertical: compact ? 10 : 14,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Modul ${widget.moduleNumber}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: isDark
                  ? AppTheme.textSecondaryDark
                  : AppTheme.textSecondaryLight,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          if (widget.title != null && widget.title!.isNotEmpty) ...[
            SizedBox(height: compact ? 4 : 6),
            Flexible(
              child: Text(
                widget.title!,
                maxLines: enlargedText ? 1 : 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: isDark
                      ? AppTheme.textPrimaryDark
                      : AppTheme.textPrimaryLight,
                  fontSize: 16,
                  height: 1.25,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
