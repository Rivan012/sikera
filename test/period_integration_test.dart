import 'dart:async';
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sikera/app/core/constants/api_constants.dart';
import 'package:sikera/app/core/services/api_service.dart';
import 'package:sikera/app/core/services/storage_service.dart';
import 'package:sikera/app/data/models/selfcare_model.dart';
import 'package:sikera/app/modules/selfcare/selfcare_controller.dart';

class TestSelfcareController extends SelfcareController {
  @override
  // ignore: must_call_super
  void onInit() {}
}

Map<String, dynamic> predictionFixture() => {
  'countdown_text': '15 hari lagi',
  'summary_narrative': 'Perkiraan berdasarkan catatan uji.',
  'predictions': {
    'next_period': {
      'start_date': '2026-09-29',
      'end_date': '2026-10-03',
      'start_formatted': '29 September 2026',
    },
    'ovulation': {'date': '2026-09-15'},
    'fertile_window': {'start_date': '2026-09-10', 'end_date': '2026-09-16'},
  },
  'current_status': {
    'cycle_day': 14,
    'days_until_next_period': 15,
    'phase_name': 'Masa subur',
  },
};

http.Response apiResponse(
  Object? data, {
  int status = 200,
  bool success = true,
}) => http.Response(
  jsonEncode({'success': success, 'data': data}),
  status,
  headers: {'content-type': 'application/json; charset=utf-8'},
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late TestSelfcareController controller;

  setUp(() async {
    Get.testMode = true;
    SharedPreferences.setMockInitialValues({'auth_token': 'test-token'});
    await StorageService.init();
    controller = TestSelfcareController();
    controller.isFemale.value = true;
    controller.summaryData.value = {'is_female': true};
    controller.startDate.value = DateTime(2026, 9, 1);
    controller.endDate.value = DateTime(2026, 9, 6);
    controller.isRegular.value = false;
  });

  tearDown(() {
    controller.onClose();
    Get.reset();
  });

  test(
    'Complete clinical payload uses backend keys and inclusive duration',
    () {
      controller.menarcheAgeController.text = '12';
      controller.includePbac.value = true;
      controller.pbacCounts['pads_heavy'] = 5;
      controller.painScore.value = 5;
      controller.workingAbility.value = 2;
      controller.painLocations.assignAll(['perut_bawah', 'pinggang']);
      controller.painDaysController.text = '3';
      expect(controller.validatePeriod(), isNull);
      final data = controller.periodPayload();
      expect(data['menarche_age'], 12);
      expect(data['is_regular'], false);
      expect(data['period_duration'], 6);
      expect(data['end_date'], '2026-09-06');
      expect(data['pbac_pads_heavy'], 5);
      expect(data['walidd_working_ability'], 2);
      expect(data['walidd_locations'], ['perut_bawah', 'pinggang']);
      expect(data['walidd_pain_days'], 3);
      expect(data['has_dysmenorrhea'], true);
      expect(data.containsKey('pbac_score'), false);
    },
  );

  test('Ongoing record does not invent end date or submit disabled PBAC', () {
    controller.endDate.value = null;
    expect(controller.validatePeriod(), isNull);
    final data = controller.periodPayload();
    expect(data.containsKey('end_date'), false);
    expect(data.keys.any((key) => key.startsWith('pbac_')), false);
    expect(data.containsKey('menarche_age'), false);
  });

  test(
    'Date, cycle, menarche, regularity and pain validation reject invalid inputs',
    () {
      controller.endDate.value = DateTime(2026, 8, 31);
      expect(controller.validatePeriod(), contains('sebelum'));
      controller.endDate.value = DateTime(2026, 9, 1);
      expect(controller.recordedDuration, 1);
      controller.cycleLengthController.text = '0';
      expect(controller.validatePeriod(), contains('15 dan 60'));
      controller.cycleLengthController.text = '28';
      controller.menarcheAgeController.text = '3';
      expect(controller.validatePeriod(), contains('8–25'));
      controller.menarcheAgeController.clear();
      controller.isRegular.value = null;
      expect(controller.validatePeriod(), contains('teratur'));
      controller.isRegular.value = true;
      controller.painDaysController.text = '5';
      expect(controller.validatePeriod(), contains('NRS 0'));
    },
  );

  test('Anonymous and male accounts cannot send protected records', () async {
    var requests = 0;
    await http.runWithClient(
      () async {
        await StorageService.clearAuth();
        await controller.submitPeriod();
        expect(controller.periodError.value, contains('Masuk'));
        await StorageService.setToken('test-token');
        controller.isFemale.value = false;
        await controller.submitPeriod();
        await controller.fetchPeriodHistory();
        await controller.fetchPeriodPrediction();
        expect(controller.periodError.value, contains('mahasiswi'));
      },
      () => MockClient((_) async {
        requests++;
        return apiResponse(null);
      }),
    );
    expect(requests, 0);
  });

  test(
    'Save sends token once, prevents double submission, refreshes data and reports returned reward',
    () async {
      final gate = Completer<http.Response>();
      final paths = <String>[];
      await http.runWithClient(
        () async {
          final pending = controller.submitPeriod();
          await Future<void>.delayed(Duration.zero);
          await controller.submitPeriod();
          expect(paths.where((path) => path.endsWith('/period')), hasLength(1));
          gate.complete(
            apiResponse({
              'period_log': {'id': 20},
              'points_earned': 10,
            }, status: 201),
          );
          await pending;
          expect(controller.isSavingPeriod.value, false);
          expect(controller.periodSuccess.value, contains('+10 poin'));
          expect(
            paths,
            containsAll([
              '/api/v1/selfcare/summary',
              '/api/v1/selfcare/period/history',
              '/api/v1/selfcare/period/prediction',
            ]),
          );
          await controller.submitPeriod();
          expect(paths.where((path) => path.endsWith('/period')), hasLength(1));
        },
        () => MockClient((request) async {
          paths.add(request.url.path);
          expect(request.headers['authorization'], 'Bearer test-token');
          if (request.url.path.endsWith('/period')) return gate.future;
          if (request.url.path.endsWith('/summary')) {
            return apiResponse({'is_female': true});
          }
          if (request.url.path.endsWith('/history')) {
            return apiResponse({'period_logs': []});
          }
          return apiResponse(predictionFixture());
        }),
      );
    },
  );

  test(
    '422 and malformed save responses preserve form and never show a reward',
    () async {
      for (final response in [
        http.Response(
          jsonEncode({
            'message': 'Data tidak valid',
            'errors': {
              'cycle_length': ['Siklus tidak valid'],
            },
          }),
          422,
        ),
        http.Response('<html>Not JSON</html>', 200),
      ]) {
        await http.runWithClient(
          controller.submitPeriod,
          () => MockClient((_) async => response),
        );
        expect(controller.periodSuccess.value, isEmpty);
        expect(controller.periodError.value, isNotEmpty);
        expect(controller.startDate.value, DateTime(2026, 9, 1));
        expect(controller.isSavingPeriod.value, false);
      }
    },
  );

  test(
    'Public calculators omit token and serialize different calculation keys',
    () async {
      final bodies = <String, Map<String, dynamic>>{};
      controller.painScore.value = 5;
      controller.painDaysController.text = '3';
      controller.pbacCounts['pads_heavy'] = 5;
      await http.runWithClient(
        () async {
          await controller.calculatePbac();
          await controller.calculateWalidd();
          await controller.calculatePeriodSimulation(
            lastPeriodDate: DateTime(2026, 9, 1),
            cycleLength: 28,
            periodDuration: 5,
          );
        },
        () => MockClient((request) async {
          expect(request.headers.containsKey('authorization'), false);
          bodies[request.url.path] =
              jsonDecode(request.body) as Map<String, dynamic>;
          return request.url.path.endsWith('/period/calculate')
              ? apiResponse(predictionFixture())
              : apiResponse({
                  'total_score': 7,
                  'max_score': 12,
                  'category': 'Kategori uji',
                });
        }),
      );
      expect(
        bodies['/api/v1/selfcare/period/pbac/calculate']!['pads_heavy'],
        5,
      );
      expect(
        bodies['/api/v1/selfcare/period/walidd/calculate']!['nrs_score'],
        5,
      );
      expect(
        bodies['/api/v1/selfcare/period/walidd/calculate']!['pain_days'],
        3,
      );
      expect(controller.simulationResult.value!.nextPeriodDate, '2026-09-29');
    },
  );

  test(
    'Failed public calculation leaves login intact and produces no local prediction',
    () async {
      await http.runWithClient(
        () async {
          final result = await controller.calculatePeriodSimulation(
            lastPeriodDate: DateTime(2026, 9, 1),
            cycleLength: 28,
            periodDuration: 5,
          );
          expect(result, isNull);
          expect(controller.simulationResult.value, isNull);
          expect(controller.simulationError.value, isNotEmpty);
          expect(StorageService.getToken(), 'test-token');
          expect(controller.isCalculatingSimulation.value, false);
        },
        () => MockClient(
          (_) async => apiResponse(null, status: 401, success: false),
        ),
      );
    },
  );

  test(
    'Changes to inputs discard in-flight PBAC and simulation results',
    () async {
      final gate = Completer<http.Response>();
      await http.runWithClient(() async {
        final request = controller.calculatePbac();
        controller.pbacCounts['pads_heavy'] = 2;
        controller.invalidatePbac();
        gate.complete(
          apiResponse({'total_score': 0, 'category': 'Old result'}),
        );
        await request;
        expect(controller.pbacResult.value, isNull);
      }, () => MockClient((_) => gate.future));
      final simulation = Completer<http.Response>();
      await http.runWithClient(() async {
        final request = controller.calculatePeriodSimulation(
          lastPeriodDate: DateTime(2026, 9, 1),
          cycleLength: 28,
          periodDuration: 5,
        );
        controller.invalidateSimulation();
        simulation.complete(apiResponse(predictionFixture()));
        expect(await request, isNull);
        expect(controller.simulationResult.value, isNull);
      }, () => MockClient((_) => simulation.future));
    },
  );

  test(
    'History failure stays distinct from empty history and summary details parse',
    () async {
      await http.runWithClient(
        controller.fetchPeriodHistory,
        () => MockClient(
          (_) async => apiResponse(null, status: 500, success: false),
        ),
      );
      expect(controller.historyError.value, isNotEmpty);
      expect(controller.periodHistory, isEmpty);
      expect(controller.isHistoryLoading.value, false);
      final fixture = predictionFixture();
      final details = fixture.remove('predictions');
      final parsed = PeriodPredictionModel.fromJson({
        ...fixture,
        'details': details,
      });
      expect(parsed.nextPeriodDate, '2026-09-29');
      expect(parsed.nextPeriodFormatted, '29 September 2026');
      expect(parsed.countdownText, '15 hari lagi');
    },
  );

  test('Clinical history model reads stored PBAC and WaLIDD results', () {
    final record = PeriodRecordModel.fromJson({
      'start_date': '2026-09-01T00:00:00.000000Z',
      'menarche_age': 12,
      'is_regular': false,
      'pbac_score': 123,
      'volume_category': 'menoragia',
      'walidd_total_score': 6,
      'walidd_category': 'Dismenore Sedang',
    });
    expect(record.menarcheAge, 12);
    expect(record.isRegular, false);
    expect(record.pbacScore, 123);
    expect(record.waliddTotalScore, 6);
    expect(record.waliddCategory, 'Dismenore Sedang');
  });

  test('Both public guides load without authorization header', () async {
    await http.runWithClient(
      () async {
        await controller.fetchBloodGuides();
        await controller.fetchHygieneGuides();
      },
      () => MockClient((request) async {
        expect(request.headers.containsKey('authorization'), false);
        return apiResponse(
          request.url.path.endsWith('/blood') ? {'guides': []} : {'tips': []},
        );
      }),
    );
    expect(controller.bloodError.value, isEmpty);
    expect(controller.hygieneError.value, isEmpty);
    expect(controller.isBloodLoading.value, false);
    expect(controller.isHygieneLoading.value, false);
  });

  test('API rejects non-JSON success responses', () async {
    final response = await http.runWithClient(
      () => ApiService.post(ApiConstants.periodPbacCalculate, auth: false),
      () => MockClient((_) async => http.Response('broken', 200)),
    );
    expect(response.success, false);
    expect(response.isMalformed, true);
  });

  test('Invalid prediction JSON is an error, not an empty record', () async {
    await http.runWithClient(
      controller.fetchPeriodPrediction,
      () => MockClient((_) async => http.Response('broken', 200)),
    );
    expect(controller.predictionError.value, isNotEmpty);
  });
}
