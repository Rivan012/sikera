import 'package:get/get.dart';
import '../../core/constants/api_constants.dart';
import '../../core/services/api_service.dart';
import '../../data/models/gamification_model.dart';

class GamificationController extends GetxController {
  final isLoading = false.obs;
  final errorMessage = ''.obs;

  // Trivia
  final triviaQuestion = Rxn<TriviaQuestionModel>();
  final selectedTriviaAnswer = ''.obs;
  final triviaResultExplanation = Rxn<String>();

  // Myth vs Fact
  final mythFactCard = Rxn<MythFactCardModel>();
  final mythFactExplanation = Rxn<String>();

  @override
  void onInit() {
    super.onInit();
    fetchTrivia();
    fetchMythFact();
  }

  Future<void> fetchTrivia({bool forceRefresh = false}) async {
    if (triviaQuestion.value == null || forceRefresh) {
      isLoading.value = true;
    }
    errorMessage.value = '';
    selectedTriviaAnswer.value = '';
    triviaResultExplanation.value = null;

    final response = await ApiService.get(ApiConstants.trivia);

    isLoading.value = false;

    if (response.success && response.data != null) {
      if (response.data is Map<String, dynamic>) {
        final map = response.data as Map<String, dynamic>;
        final target = map['question'] is Map<String, dynamic>
            ? map['question'] as Map<String, dynamic>
            : map;
        triviaQuestion.value = TriviaQuestionModel.fromJson(target);
      }
    } else {
      // Fallback kuis jika API belum terisi data
      triviaQuestion.value = TriviaQuestionModel(
        id: 1,
        question: 'Berapa rata-rata rentang siklus menstruasi yang normal pada remaja perempuan?',
        options: [
          '21 hingga 35 hari',
          '10 hingga 15 hari',
          '45 hingga 60 hari',
          'Selalu tepat 30 hari',
        ],
        explanation: 'Siklus menstruasi normal berkisar antara 21 sampai 35 hari, dengan rata-rata 28 hari.',
      );
    }
  }

  Future<void> answerTrivia(String answer) async {
    if (selectedTriviaAnswer.value.isNotEmpty || triviaResultExplanation.value != null || isLoading.value) return;
    selectedTriviaAnswer.value = answer;
    if (triviaQuestion.value == null) return;

    final response = await ApiService.post(
      ApiConstants.trivia,
      body: {
        'question_id': triviaQuestion.value!.id,
        'answer': answer,
      },
    );

    if (response.success && response.data is Map<String, dynamic>) {
      triviaResultExplanation.value = response.data['explanation']?.toString() ?? 'Jawaban Anda telah dicatat.';
    } else {
      triviaResultExplanation.value = triviaQuestion.value?.explanation ?? 'Jawaban telah tersimpan.';
    }
  }

  Future<void> fetchMythFact({bool forceRefresh = false}) async {
    if (mythFactCard.value == null || forceRefresh) {
      isLoading.value = true;
    }
    mythFactExplanation.value = null;

    final response = await ApiService.get(ApiConstants.mythFact);

    isLoading.value = false;

    if (response.success && response.data != null) {
      if (response.data is Map<String, dynamic>) {
        final map = response.data as Map<String, dynamic>;
        final target = map['card'] is Map<String, dynamic>
            ? map['card'] as Map<String, dynamic>
            : map;
        mythFactCard.value = MythFactCardModel.fromJson(target);
      }
    } else {
      mythFactCard.value = MythFactCardModel(
        id: 1,
        statement: 'Minum air dingin saat menstruasi dapat membekukan darah haid di dalam rahim.',
        category: 'Mitos Haid',
        correctAnswer: 'myth',
        explanation: 'MITOS! Saluran pencernaan dan rahim adalah dua organ yang terpisah. Suhu air minum tidak memengaruhi pembekuan darah dalam rongga rahim.',
      );
    }
  }

  Future<void> answerMythFact(String guess) async {
    if (mythFactExplanation.value != null || isLoading.value) return;
    if (mythFactCard.value == null) return;

    final response = await ApiService.post(
      ApiConstants.mythFact,
      body: {
        'card_id': mythFactCard.value!.id,
        'answer': guess,
      },
    );

    if (response.success && response.data is Map<String, dynamic>) {
      mythFactExplanation.value = response.data['explanation']?.toString();
    } else {
      mythFactExplanation.value = mythFactCard.value?.explanation;
    }
  }
}
