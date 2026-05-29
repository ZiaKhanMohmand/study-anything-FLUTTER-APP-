import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:study_anything/core/models/question_model.dart';
import 'package:study_anything/core/models/quiz_result_model.dart';
import 'package:study_anything/core/services/gemini_service.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

final _currentIndexProvider = StateProvider<int>((ref) => 0);
final _answersProvider = StateProvider<Map<int, String>>((ref) => {});

class QuizScreen extends ConsumerStatefulWidget {
  final List<Question> questions;
  final String pdfName;

  const QuizScreen({super.key, required this.questions, required this.pdfName});

  @override
  ConsumerState<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends ConsumerState<QuizScreen> {
  late TextEditingController _textController;
  int _lastIndex = 0;
  InterstitialAd? _interstitialAd;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController();
    _loadInterstitialAd();
  }

  void _loadInterstitialAd() {
    InterstitialAd.load(
      adUnitId: 'ca-app-pub-3940256099942544/1033173712', // TEST ID
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) => _interstitialAd = ad,
        onAdFailedToLoad: (error) => _interstitialAd = null,
      ),
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    _interstitialAd?.dispose();
    super.dispose();
  }

  String _typeLabel(String type) {
    switch (type) {
      case 'MCQ':
        return 'Multiple Choice';
      case 'SHORT_ANSWER':
        return 'Short Answer';
      case 'LONG_ANSWER':
        return 'Long Answer';
      default:
        return type;
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = ref.watch(_currentIndexProvider);
    final answers = ref.watch(_answersProvider);
    final question = widget.questions[currentIndex];
    final progress = (currentIndex + 1) / widget.questions.length;

    // Update controller when question changes
    if (_lastIndex != currentIndex) {
      _lastIndex = currentIndex;
      _textController.text = answers[currentIndex] ?? '';
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5FF),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text(
          'Question ${currentIndex + 1} of ${widget.questions.length}',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: const Color(0xFF2D2D2D),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => _confirmSubmit(context, answers),
            child: Text(
              'Submit',
              style: GoogleFonts.poppins(
                color: const Color(0xFF6C63FF),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: progress,
                  backgroundColor: Colors.grey[200],
                  color: const Color(0xFF6C63FF),
                  minHeight: 8,
                ),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _questionCard(question),
                    const SizedBox(height: 24),
                    if (question.type == QuestionType.mcq)
                      _mcqOptions(question, currentIndex, answers)
                    else
                      _textInput(currentIndex, answers),
                  ],
                ),
              ),
            ),
            _bottomNav(context, currentIndex, answers),
          ],
        ),
      ),
    );
  }

  Widget _questionCard(Question question) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6C63FF), Color(0xFF3B37C8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              _typeLabel(question.type.toString().split('.').last),
              style: GoogleFonts.poppins(
                fontSize: 11,
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            question.question,
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: Colors.white,
              fontWeight: FontWeight.w500,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _mcqOptions(Question question, int index, Map<int, String> answers) {
    return Column(
      children: (question.options ?? []).map((option) {
        final isSelected = answers[index] == option;
        return GestureDetector(
          onTap: () {
            final updated = Map<int, String>.from(answers);
            updated[index] = option;
            ref.read(_answersProvider.notifier).state = updated;
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isSelected
                  ? const Color(0xFF6C63FF).withValues(alpha: 0.1)
                  : Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isSelected ? const Color(0xFF6C63FF) : Colors.grey[200]!,
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected
                        ? const Color(0xFF6C63FF)
                        : Colors.grey[200],
                  ),
                  child: isSelected
                      ? const Icon(Icons.check, color: Colors.white, size: 14)
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    option,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: isSelected
                          ? const Color(0xFF6C63FF)
                          : const Color(0xFF2D2D2D),
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.normal,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _textInput(int index, Map<int, String> answers) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: TextField(
          controller: _textController, // ✅ stable controller
          textDirection: TextDirection.ltr,
          onChanged: (value) {
            final updated = Map<int, String>.from(answers);
            updated[index] = value;
            ref.read(_answersProvider.notifier).state = updated;
          },
          maxLines: 8,
          decoration: InputDecoration(
            hintText: 'Type your answer here...',
            hintStyle: GoogleFonts.poppins(color: Colors.grey[400]),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.all(16),
          ),
          style: GoogleFonts.poppins(fontSize: 14),
        ),
      ),
    );
  }

  Widget _bottomNav(
    BuildContext context,
    int currentIndex,
    Map<int, String> answers,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          if (currentIndex > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  ref.read(_currentIndexProvider.notifier).state =
                      currentIndex - 1;
                },
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  side: const BorderSide(color: Color(0xFF6C63FF)),
                ),
                child: Text(
                  'Previous',
                  style: GoogleFonts.poppins(color: const Color(0xFF6C63FF)),
                ),
              ),
            ),
          if (currentIndex > 0) const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                if (currentIndex < widget.questions.length - 1) {
                  ref.read(_currentIndexProvider.notifier).state =
                      currentIndex + 1;
                } else {
                  _submitQuiz(context, answers);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6C63FF),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                currentIndex < widget.questions.length - 1 ? 'Next' : 'Finish',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmSubmit(BuildContext context, Map<int, String> answers) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Submit Quiz?',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'You have answered ${answers.length} of ${widget.questions.length} questions.',
          style: GoogleFonts.poppins(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Continue'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6C63FF),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              _submitQuiz(context, answers);
            },
            child: const Text('Submit', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _submitQuiz(BuildContext context, Map<int, String> answers) async {
    for (int i = 0; i < widget.questions.length; i++) {
      widget.questions[i].userAnswer = answers[i];
    }

    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const Center(
        child: CircularProgressIndicator(color: Color(0xFF6C63FF)),
      ),
    );

    try {
      final evaluations = await GeminiService().evaluateAnswers(
        widget.questions,
      );
      for (int i = 0; i < widget.questions.length; i++) {
        widget.questions[i].aiCorrect = evaluations[i];
      }
    } catch (e) {
      // Falls back to exact matching if AI fails
    }

    if (!mounted) return;
    Navigator.pop(context); // close loading dialog

    if (!mounted) return;
    final result = QuizResult(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      pdfName: widget.pdfName,
      questionType: widget.questions.first.type,
      questions: widget.questions,
      takenAt: DateTime.now(),
    );

    ref.read(_currentIndexProvider.notifier).state = 0;
    ref.read(_answersProvider.notifier).state = {};

    if (mounted) {
      if (_interstitialAd != null) {
        _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
          onAdDismissedFullScreenContent: (ad) {
            ad.dispose();
            _interstitialAd = null;
            if (mounted) context.go('/results', extra: {'result': result});
          },
          onAdFailedToShowFullScreenContent: (ad, error) {
            ad.dispose();
            _interstitialAd = null;
            if (mounted) context.go('/results', extra: {'result': result});
          },
        );
        _interstitialAd!.show();
      } else {
        context.go('/results', extra: {'result': result}); // fallback
      }
    }
  }
}
