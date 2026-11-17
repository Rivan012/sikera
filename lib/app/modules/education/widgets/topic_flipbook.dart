import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart' as html;

import '../../../core/theme/app_theme.dart';
import '../../../data/models/module_model.dart';
import 'topic_video_player.dart';

List<String> topicBookPages(String? content) {
  final document = html.parseFragment(content ?? '');
  for (final element in document.querySelectorAll('script, style')) {
    element.remove();
  }
  for (final element in document.querySelectorAll('br')) {
    element.replaceWith(dom.Text('\n'));
  }
  for (final element in document.querySelectorAll('li')) {
    final siblings =
        element.parent?.children.where((e) => e.localName == 'li').toList() ??
        [];
    final marker = element.parent?.localName == 'ol'
        ? '${siblings.indexOf(element) + 1}. '
        : '- ';
    element.nodes.insert(0, dom.Text(marker));
  }
  for (final element in document.querySelectorAll(
    'p, div, section, h1, h2, h3, h4, h5, h6, ul, ol, li, blockquote, tr',
  )) {
    element.nodes.add(dom.Text('\n\n'));
  }
  for (final element in document.querySelectorAll('td, th')) {
    element.nodes.add(dom.Text(' '));
  }
  var remaining = (document.text ?? '')
      .replaceAll(RegExp(r'[^\S\n]+'), ' ')
      .replaceAll(RegExp(r' *\n *'), '\n')
      .replaceAll(RegExp(r'\n{3,}'), '\n\n')
      .trim();
  final pages = <String>[];
  // Keep page boundaries stable on rotation; enlarged text can scroll per page.
  const pageLength = 850;
  while (remaining.length > pageLength) {
    var end = remaining.lastIndexOf('\n\n', pageLength);
    if (end < pageLength ~/ 2) {
      end = remaining.lastIndexOf(RegExp(r'\s'), pageLength);
    }
    if (end <= 0) end = remaining.indexOf(RegExp(r'\s'), pageLength);
    if (end < 0) break;
    pages.add(remaining.substring(0, end).trim());
    remaining = remaining.substring(end).trimLeft();
  }
  if (remaining.isNotEmpty) pages.add(remaining);
  return pages;
}

class TopicFlipbook extends StatefulWidget {
  final TopicModel topic;
  final VoidCallback onFinished;

  const TopicFlipbook({
    super.key,
    required this.topic,
    required this.onFinished,
  });

  @override
  State<TopicFlipbook> createState() => _TopicFlipbookState();
}

class _TopicFlipbookState extends State<TopicFlipbook> {
  final _controller = PageController();
  late List<String> _pages;
  int _currentPage = 0;

  bool get _hasVideo =>
      (widget.topic.youtubeVideoId?.trim().isNotEmpty ?? false) ||
      (widget.topic.youtubeEmbedUrl?.trim().isNotEmpty ?? false);
  int get _pageCount =>
      1 + (_pages.isEmpty ? 1 : _pages.length) + (_hasVideo ? 1 : 0);

  @override
  void initState() {
    super.initState();
    _pages = topicBookPages(widget.topic.contentHtml);
  }

  @override
  void didUpdateWidget(covariant TopicFlipbook oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.topic != widget.topic) {
      _pages = topicBookPages(widget.topic.contentHtml);
      _currentPage = 0;
      if (_controller.hasClients) _controller.jumpToPage(0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _turnTo(int page) {
    if (page < 0 || page >= _pageCount || !_controller.hasClients) return;
    if (MediaQuery.disableAnimationsOf(context)) {
      _controller.jumpToPage(page);
    } else {
      _controller.animateToPage(
        page,
        duration: const Duration(milliseconds: 420),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final accent = isDark ? AppTheme.primary200 : AppTheme.primary700;
    final secondary = isDark
        ? AppTheme.textSecondaryDark
        : AppTheme.textSecondaryLight;

    return SafeArea(
      child: CallbackShortcuts(
        bindings: {
          const SingleActivator(LogicalKeyboardKey.arrowLeft): () =>
              _turnTo(_currentPage - 1),
          const SingleActivator(LogicalKeyboardKey.arrowRight): () =>
              _turnTo(_currentPage + 1),
          const SingleActivator(LogicalKeyboardKey.home): () => _turnTo(0),
          const SingleActivator(LogicalKeyboardKey.end): () =>
              _turnTo(_pageCount - 1),
        },
        child: Focus(
          autofocus: true,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 760),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: isDark
                                ? AppTheme.softAccentSurfaceDark
                                : AppTheme.primary50,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.menu_book_rounded,
                            color: accent,
                            size: 21,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Submateri ${widget.topic.topicCode}',
                                style: TextStyle(
                                  color: accent,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              Text(
                                widget.topic.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: isDark
                                      ? AppTheme.textPrimaryDark
                                      : AppTheme.primary900,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          tooltip: 'Kembali ke sampul',
                          onPressed: _currentPage == 0
                              ? null
                              : () => _turnTo(0),
                          icon: const Icon(Icons.first_page_rounded),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: PageView.builder(
                          controller: _controller,
                          itemCount: _pageCount,
                          allowImplicitScrolling: true,
                          onPageChanged: (page) =>
                              setState(() => _currentPage = page),
                          itemBuilder: (context, index) =>
                              _buildPage(context, index),
                        ),
                      ),
                    ),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: (_currentPage + 1) / _pageCount,
                        color: accent,
                        backgroundColor: isDark
                            ? AppTheme.softAccentSurfaceDark
                            : AppTheme.primary50,
                        minHeight: 5,
                        semanticsLabel: 'Posisi bacaan',
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        IconButton.filledTonal(
                          tooltip: 'Halaman sebelumnya',
                          onPressed: _currentPage == 0
                              ? null
                              : () => _turnTo(_currentPage - 1),
                          icon: const Icon(Icons.chevron_left_rounded),
                        ),
                        Expanded(
                          child: Semantics(
                            liveRegion: true,
                            label:
                                'Halaman ${_currentPage + 1} dari $_pageCount',
                            child: Text(
                              MediaQuery.sizeOf(context).width < 360 &&
                                      MediaQuery.textScalerOf(
                                            context,
                                          ).scale(13) >
                                          20
                                  ? '${_currentPage + 1} / $_pageCount'
                                  : 'Halaman ${_currentPage + 1} dari $_pageCount',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: secondary,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        IconButton.filledTonal(
                          tooltip: 'Halaman berikutnya',
                          onPressed: _currentPage == _pageCount - 1
                              ? null
                              : () => _turnTo(_currentPage + 1),
                          icon: const Icon(Icons.chevron_right_rounded),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPage(BuildContext context, int index) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isCover = index == 0;
    final isVideo = _hasVideo && index == _pageCount - 1;
    final isLast = index == _pageCount - 1;
    final accent = isDark ? AppTheme.primary200 : AppTheme.primary700;
    final secondary = isDark
        ? AppTheme.textSecondaryDark
        : AppTheme.textSecondaryLight;

    return Container(
      decoration: BoxDecoration(
        color: isCover
            ? (isDark
                  ? AppTheme.pocketSurfaceDark
                  : AppTheme.pocketSurfaceLight)
            : theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        border: Border.all(
          color: isDark ? AppTheme.borderDark : AppTheme.borderLight,
        ),
      ),
      child: SingleChildScrollView(
        key: PageStorageKey('topic-${widget.topic.id}-page-$index'),
        padding: EdgeInsets.all(
          MediaQuery.sizeOf(context).width < 360 ? 16 : 24,
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 620),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (isCover) ...[
                  Row(
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppTheme.primary700
                              : AppTheme.primary900,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(
                          Icons.menu_book_rounded,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'SIKERA',
                          style: TextStyle(
                            color: isDark
                                ? AppTheme.textPrimaryDark
                                : AppTheme.primary900,
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.3,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),
                  Text(
                    'Submateri ${widget.topic.topicCode}',
                    style: TextStyle(
                      color: accent,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    widget.topic.title,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: isDark
                          ? AppTheme.textPrimaryDark
                          : AppTheme.primary900,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.4,
                      height: 1.25,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Divider(
                    color: isDark ? AppTheme.borderDark : AppTheme.primary200,
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 16,
                    runSpacing: 8,
                    children: [
                      if (_pages.isNotEmpty)
                        Text(
                          '${_pages.length} bagian bacaan',
                          style: TextStyle(color: secondary),
                        ),
                      if (_pages.isEmpty && !_hasVideo)
                        Text(
                          'Isi materi belum tersedia',
                          style: TextStyle(color: secondary),
                        ),
                      if (_hasVideo)
                        Text(
                          'Video pembelajaran tersedia',
                          style: TextStyle(color: secondary),
                        ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: () => _turnTo(1),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                    ),
                    child: const Text(
                      'Mulai Membaca',
                      textAlign: TextAlign.center,
                    ),
                  ),
                ] else ...[
                  Text(
                    isVideo
                        ? 'Video pembelajaran'
                        : (_pages.isEmpty
                              ? 'Konten materi'
                              : 'Bacaan $index dari ${_pages.length}'),
                    style: TextStyle(
                      color: accent,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    isVideo ? 'Tonton Materi' : widget.topic.title,
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: isDark
                          ? AppTheme.textPrimaryDark
                          : AppTheme.primary900,
                      fontWeight: FontWeight.w700,
                      height: 1.25,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Divider(
                    color: isDark ? AppTheme.borderDark : AppTheme.borderLight,
                  ),
                  const SizedBox(height: 20),
                  if (isVideo)
                    // Dispose the player when turning away so hidden video stops.
                    if (index == _currentPage)
                      TopicVideoPlayer(
                        videoId: widget.topic.youtubeVideoId ?? '',
                        embedUrl: widget.topic.youtubeEmbedUrl,
                        title: widget.topic.title,
                      )
                    else
                      const AspectRatio(
                        aspectRatio: 16 / 9,
                        child: SizedBox.shrink(),
                      )
                  else
                    Column(
                      key: ValueKey('topic-text-$index'),
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        for (final paragraph
                            in (_pages.isEmpty
                                ? ['Isi materi belum tersedia.']
                                : _pages[index - 1].split('\n\n')))
                          Padding(
                            padding: const EdgeInsets.only(bottom: 18),
                            child: Text(
                              paragraph,
                              style: TextStyle(
                                fontSize: 16,
                                height: 1.55,
                                color: theme.colorScheme.onSurface,
                              ),
                            ),
                          ),
                      ],
                    ),
                  if (isLast) ...[
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: widget.onFinished,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                      ),
                      child: Text(
                        _pages.isEmpty && !_hasVideo
                            ? 'Kembali ke Modul'
                            : 'Selesai Membaca',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
