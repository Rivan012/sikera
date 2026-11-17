import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';
import '../../../core/theme/app_theme.dart';

/// Pemutar video YouTube interaktif untuk halaman materi/submateri edukasi.
/// Fitur:
/// - Ekstraksi otomatis ID video YouTube 11 karakter dari berbagai format (ID mentah, link watch, link embed, link pendek youtu.be).
/// - Pemutaran video inline langsung di dalam aplikasi menggunakan [YoutubePlayer] iframe dengan kontrol lengkap.
/// - Tombol aksi "Buka di YouTube" untuk pengalaman layar penuh di aplikasi resmi YouTube / browser.
/// - Tombol salin link video.
/// - Manajemen lifecycle controller yang aman ([close] dipanggil saat dispose).
class TopicVideoPlayer extends StatefulWidget {
  final String videoId;
  final String? embedUrl;
  final String? title;

  const TopicVideoPlayer({
    super.key,
    required this.videoId,
    this.embedUrl,
    this.title,
  });

  /// Helper untuk mengekstrak 11-char YouTube Video ID dari teks/URL apapun
  static String extractVideoId(String input) {
    final trimmed = input.trim();
    if (trimmed.isEmpty) return '';

    // Pola regex komprehensif YouTube
    final regExp = RegExp(
      r'(?:https?:\/\/)?(?:www\.)?(?:youtube\.com\/(?:[^\/\n\s]+\/\S+\/|(?:v|e(?:mbed)?)\/|\S*?[?&]v=)|youtu\.be\/)([a-zA-Z0-9_-]{11})',
      caseSensitive: false,
    );
    final match = regExp.firstMatch(trimmed);
    if (match != null && match.groupCount >= 1) {
      return match.group(1)!;
    }

    // Jika sudah berupa ID 11 karakter
    if (RegExp(r'^[a-zA-Z0-9_-]{11}$').hasMatch(trimmed)) {
      return trimmed;
    }

    // Jika ID terkandung di akhir slash
    final parts = trimmed.split('/');
    if (parts.isNotEmpty && parts.last.length == 11) {
      return parts.last;
    }

    return trimmed;
  }

  @override
  State<TopicVideoPlayer> createState() => _TopicVideoPlayerState();
}

class _TopicVideoPlayerState extends State<TopicVideoPlayer> {
  late final String _cleanVideoId;
  YoutubePlayerController? _controller;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _cleanVideoId = TopicVideoPlayer.extractVideoId(widget.videoId.isNotEmpty ? widget.videoId : (widget.embedUrl ?? ''));

    if (_cleanVideoId.isNotEmpty) {
      try {
        _controller = YoutubePlayerController.fromVideoId(
          videoId: _cleanVideoId,
          autoPlay: false,
          params: const YoutubePlayerParams(
            showControls: true,
            showFullscreenButton: true,
            enableCaption: true,
            showVideoAnnotations: false,
          ),
        );
      } catch (e) {
        _hasError = true;
      }
    } else {
      _hasError = true;
    }
  }

  @override
  void dispose() {
    _controller?.close();
    super.dispose();
  }

  Future<void> _openExternalYouTube() async {
    if (_cleanVideoId.isEmpty) return;
    final Uri url = Uri.parse('https://www.youtube.com/watch?v=$_cleanVideoId');
    try {
      final launched = await launchUrl(url, mode: LaunchMode.externalApplication);
      if (!launched) {
        await launchUrl(url, mode: LaunchMode.platformDefault);
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Tidak dapat membuka link: $url'),
            backgroundColor: AppTheme.error,
          ),
        );
      }
    }
  }

  void _copyLink() {
    if (_cleanVideoId.isEmpty) return;
    final link = 'https://www.youtube.com/watch?v=$_cleanVideoId';
    Clipboard.setData(ClipboardData(text: link));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Link video YouTube berhasil disalin!'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppTheme.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        border: Border.all(
          color: isDark ? AppTheme.borderDark : AppTheme.borderLight,
          width: 1.0,
        ),
        boxShadow: isDark ? null : AppTheme.cardShadow,
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header Bar Video
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF0000).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.play_circle_filled_rounded,
                    color: Color(0xFFFF0000),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Video Pembelajaran',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.2,
                        ),
                      ),
                      Text(
                        'Putar langsung atau buka di aplikasi YouTube',
                        style: TextStyle(
                          fontSize: 11,
                          color: isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondaryLight,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.share_outlined, size: 18),
                  tooltip: 'Salin Link Video',
                  visualDensity: VisualDensity.compact,
                  onPressed: _copyLink,
                ),
              ],
            ),
          ),

          // Player Container
          if (_hasError || _controller == null)
            _buildErrorOrFallback(context, isDark)
          else
            AspectRatio(
              aspectRatio: 16 / 9,
              child: YoutubePlayer(
                controller: _controller!,
                aspectRatio: 16 / 9,
              ),
            ),

          // Bottom Action Footer
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Wrap(
              alignment: WrapAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: _openExternalYouTube,
                  icon: const Icon(Icons.open_in_new_rounded, size: 14),
                  label: const Text('Buka di YouTube', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                  style: TextButton.styleFrom(
                    foregroundColor: isDark ? AppTheme.primary500 : AppTheme.primary700,
                    minimumSize: const Size(48, 48),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorOrFallback(BuildContext context, bool isDark) {
    return Container(
        color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.smart_display_outlined, size: 40, color: Color(0xFFFF0000)),
            const SizedBox(height: 8),
            const Text(
              'Video Siap Diputar',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
            const SizedBox(height: 4),
            Text(
              'Ketuk tombol di bawah untuk memutar via aplikasi YouTube.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 11, color: isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondaryLight),
            ),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: _openExternalYouTube,
              icon: const Icon(Icons.play_arrow_rounded, size: 16),
              label: const Text('Tonton di YouTube', style: TextStyle(fontSize: 12)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFC53030),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                minimumSize: const Size(48, 48),
              ),
            ),
          ],
        ),
    );
  }
}
