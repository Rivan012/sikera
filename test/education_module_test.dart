import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sikera/app/core/constants/api_constants.dart';
import 'package:sikera/app/data/models/module_model.dart';
import 'package:sikera/app/modules/education/widgets/module_banner.dart';
import 'package:sikera/app/modules/education/widgets/topic_video_player.dart';

void main() {
  group('TopicVideoPlayer Video ID Extraction Tests', () {
    test('Extracts raw 11-char ID correctly', () {
      expect(TopicVideoPlayer.extractVideoId('v3F4QW_h32M'), 'v3F4QW_h32M');
    });

    test('Extracts from standard watch URL', () {
      expect(
        TopicVideoPlayer.extractVideoId(
          'https://www.youtube.com/watch?v=v3F4QW_h32M',
        ),
        'v3F4QW_h32M',
      );
    });

    test('Extracts from watch URL with extra parameters', () {
      expect(
        TopicVideoPlayer.extractVideoId(
          'https://www.youtube.com/watch?v=v3F4QW_h32M&feature=shared&t=10s',
        ),
        'v3F4QW_h32M',
      );
    });

    test('Extracts from short youtu.be URL', () {
      expect(
        TopicVideoPlayer.extractVideoId('https://youtu.be/v3F4QW_h32M'),
        'v3F4QW_h32M',
      );
    });

    test('Extracts from embed URL', () {
      expect(
        TopicVideoPlayer.extractVideoId(
          'https://www.youtube.com/embed/v3F4QW_h32M',
        ),
        'v3F4QW_h32M',
      );
    });

    test('Handles empty and whitespace input', () {
      expect(TopicVideoPlayer.extractVideoId(''), '');
      expect(TopicVideoPlayer.extractVideoId('   '), '');
    });
  });

  group('ModuleBanner URL Resolution Tests', () {
    test('Preserves full HTTP and HTTPS URLs', () {
      expect(
        ModuleBanner.resolveUrl('https://example.com/images/banner.png', 1),
        'https://example.com/images/banner.png',
      );
      expect(
        ModuleBanner.resolveUrl(
          'http://127.0.0.1:8000/api/v1/modules/1/banner.svg',
          1,
        ),
        'http://127.0.0.1:8000/api/v1/modules/1/banner.svg',
      );
    });

    test('Resolves relative paths with server base URL', () {
      final resolved = ModuleBanner.resolveUrl(
        '/images/banners/banner-module-1.svg',
        1,
      );
      expect(resolved, isNotNull);
      expect(resolved.endsWith('/images/banners/banner-module-1.svg'), isTrue);
      expect(resolved.contains('/api/v1'), isFalse);
    });

    test('Defaults to API endpoint banner for null and empty inputs', () {
      expect(
        ModuleBanner.resolveUrl(null, 1),
        '${ApiConstants.baseUrl}/modules/1/banner.svg',
      );
      expect(
        ModuleBanner.resolveUrl('', 2),
        '${ApiConstants.baseUrl}/modules/2/banner.svg',
      );
      expect(
        ModuleBanner.resolveUrl('   ', 3),
        '${ApiConstants.baseUrl}/modules/3/banner.svg',
      );
    });
  });

  group('ModuleDetailModel Serialization Tests', () {
    test('Parses banner_image from JSON', () {
      final json = {
        'id': 1,
        'module_number': 1,
        'title': 'Anatomi & Fisiologi Reproduksi',
        'subtitle': 'Mengenal tubuh dan kesehatan reproduksi',
        'description': 'Modul komprehensif',
        'banner_image': '/images/banners/banner-module-1.svg',
        'has_pretest': true,
        'has_posttest': false,
        'topics': [],
      };

      final model = ModuleDetailModel.fromJson(json);
      expect(model.id, 1);
      expect(model.moduleNumber, 1);
      expect(model.title, 'Anatomi & Fisiologi Reproduksi');
      expect(model.bannerImage, '/images/banners/banner-module-1.svg');
    });
  });

  group('ModuleBanner Widget Tests', () {
    testWidgets('Renders ModuleBanner with asset fallback and overlay', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ModuleBanner(
              bannerImage: null,
              moduleNumber: 2,
              title: 'Pubertas & Perubahan Tubuh',
              height: 140,
              overlay: Text('OVERLAY TEST'),
            ),
          ),
        ),
      );

      expect(find.byType(ModuleBanner), findsOneWidget);
      expect(find.text('OVERLAY TEST'), findsOneWidget);

      await tester.pumpAndSettle();
      expect(find.byType(ModuleBanner), findsOneWidget);
      expect(find.text('OVERLAY TEST'), findsOneWidget);
    });
  });
}
