import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/models/question_model.dart';
import '../../../core/models/quiz_result_model.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../../../core/services/ad_service.dart';

class ResultsScreen extends StatefulWidget {
  final QuizResult result;

  const ResultsScreen({super.key, required this.result});

  @override
  State<ResultsScreen> createState() => _ResultsScreenState();
}

class _ResultsScreenState extends State<ResultsScreen> {
  RewardedAd? _rewardedAd;

  Color get _gradeColor {
    if (widget.result.scorePercent >= 80) return const Color(0xFF4CAF50);
    if (widget.result.scorePercent >= 60) return const Color(0xFFFF9800);
    return const Color(0xFFE53935);
  }

  @override
  void initState() {
    super.initState();
    _loadRewardedAd();
  }

  @override
  void dispose() {
    _rewardedAd?.dispose();
    super.dispose();
  }

  void _loadRewardedAd() {
    AdService.loadRewarded(onLoaded: (ad) => setState(() => _rewardedAd = ad));
  }

  void _onTryAnotherPdfTapped() {
    context.go('/upload');
  }

  void _onRetakeTapped() {
    if (_rewardedAd == null) {
      _retakeQuiz();
      return;
    }
    _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _rewardedAd = null;
        _retakeQuiz();
        _loadRewardedAd();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        _rewardedAd = null;
        _retakeQuiz();
      },
    );
    _rewardedAd!.show(onUserEarnedReward: (_, __) {});
  }

  void _retakeQuiz() {
    for (final q in widget.result.questions) {
      q.userAnswer = null;
      q.aiCorrect = null;
    }
    context.push(
      '/mode-select',
      extra: {
        'pdfText': widget.result.pdfText,
        'pdfName': widget.result.pdfName,
        'skipQuota': true,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F0FF),
      body: Column(
        children: [
          _header(context),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
              children: [
                _scoreCard(),
                const SizedBox(height: 24),
                _sectionTitle('Question Review'),
                const SizedBox(height: 12),
                ...widget.result.questions.asMap().entries.map(
                  (e) => _questionCard(e.key, e.value),
                ),
                const SizedBox(height: 24),
                _actionButtons(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _header(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 12,
        bottom: 16,
        left: 16,
        right: 16,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF7B74FF), Color(0xFF3B37C8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => context.go('/home'),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(51),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.close_rounded,
                color: Colors.white,
                size: 18,
              ),
            ),
          ),
          Expanded(
            child: Text(
              'Quiz Results',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 36),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: const Color(0xFF1a1a2e),
      ),
    );
  }

  Widget _scoreCard() {
    final color = _gradeColor;
    final isPass = widget.result.scorePercent >= 60;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE8E8F5), width: 1),
        boxShadow: [
          BoxShadow(
            color: color.withAlpha(38),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: color.withAlpha(26),
              shape: BoxShape.circle,
              border: Border.all(color: color.withAlpha(77), width: 2),
            ),
            child: Center(
              child: Text(
                widget.result.grade,
                style: GoogleFonts.poppins(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            '${widget.result.scorePercent.toStringAsFixed(0)}%',
            style: GoogleFonts.poppins(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1a1a2e),
            ),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: color.withAlpha(26),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              isPass ? '🎉 Great job!' : '📚 Keep studying!',
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF8F8FF),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _stat(
                  'Correct',
                  widget.result.correctCount.toString(),
                  const Color(0xFF4CAF50),
                ),
                _statDivider(),
                _stat(
                  'Wrong',
                  (widget.result.totalQuestions - widget.result.correctCount)
                      .toString(),
                  const Color(0xFFE53935),
                ),
                _statDivider(),
                _stat(
                  'Total',
                  widget.result.totalQuestions.toString(),
                  const Color(0xFF6C63FF),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _statDivider() =>
      Container(width: 1, height: 36, color: const Color(0xFFE8E8F5));

  Widget _stat(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey[500]),
        ),
      ],
    );
  }

  Widget _questionCard(int index, Question question) {
    final isCorrect = question.isCorrect;
    final isMcq = question.type == QuestionType.mcq;
    final color = isCorrect ? const Color(0xFF4CAF50) : const Color(0xFFE53935);
    final bgColor = isCorrect
        ? const Color(0xFFF0FBF4)
        : const Color(0xFFFFF5F5);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withAlpha(64), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  isCorrect ? Icons.check_circle_rounded : Icons.cancel_rounded,
                  color: color,
                  size: 18,
                ),
                const SizedBox(width: 6),
                Text(
                  'Q${index + 1}',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    color: color,
                    fontSize: 13,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: color.withAlpha(31),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    isCorrect ? 'Correct ✓' : 'Wrong ✗',
                    style: GoogleFonts.poppins(
                      fontSize: 10,
                      color: color,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  question.question,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1a1a2e),
                  ),
                ),
                const SizedBox(height: 10),
                if (isMcq) ...[
                  _answerChip(
                    'Your Answer',
                    question.userAnswer ?? 'Not answered',
                    isCorrect
                        ? const Color(0xFF4CAF50)
                        : const Color(0xFFE53935),
                    isCorrect
                        ? const Color(0xFFF0FBF4)
                        : const Color(0xFFFFF5F5),
                  ),
                  if (!isCorrect) ...[
                    const SizedBox(height: 6),
                    _answerChip(
                      'Correct Answer',
                      question.correctAnswer,
                      const Color(0xFF4CAF50),
                      const Color(0xFFF0FBF4),
                    ),
                  ],
                ] else ...[
                  _textAnswerBlock(
                    'Your Answer',
                    question.userAnswer ?? 'Not answered',
                    isCorrect
                        ? const Color(0xFF4CAF50)
                        : const Color(0xFFE53935),
                    bgColor,
                  ),
                  const SizedBox(height: 8),
                  _textAnswerBlock(
                    'Model Answer',
                    question.correctAnswer,
                    const Color(0xFF6C63FF),
                    const Color(0xFFF5F4FF),
                  ),
                ],
                const SizedBox(height: 10),
                _explanationBox(question.explanation),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _answerChip(
    String label,
    String value,
    Color textColor,
    Color bgColor,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label: ',
            style: GoogleFonts.poppins(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 11,
                color: textColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _textAnswerBlock(
    String label,
    String value,
    Color labelColor,
    Color bgColor,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: GoogleFonts.poppins(
              fontSize: 9,
              fontWeight: FontWeight.bold,
              color: labelColor,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: const Color(0xFF3a3a5e),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _explanationBox(String explanation) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F4FF),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFDDDBFF), width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: const Color(0xFFEEEDFE),
              borderRadius: BorderRadius.circular(7),
            ),
            child: const Icon(
              Icons.lightbulb_outline_rounded,
              size: 13,
              color: Color(0xFF6C63FF),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Explanation',
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF6C63FF),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  explanation,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: const Color(0xFF534AB7),
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionButtons(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton.icon(
            onPressed: _onTryAnotherPdfTapped,
            icon: const Icon(
              Icons.upload_file_rounded,
              color: Colors.white,
              size: 18,
            ),
            label: Text(
              'Try Another PDF',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6C63FF),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton.icon(
            onPressed: _onRetakeTapped,
            icon: const Icon(
              Icons.replay_rounded,
              color: Colors.white,
              size: 18,
            ),
            label: Text(
              _rewardedAd != null ? '🎬 Watch Ad & Retake' : 'Retake Quiz',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4CAF50),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          height: 52,
          child: OutlinedButton.icon(
            onPressed: () => context.go('/home'),
            icon: const Icon(
              Icons.home_outlined,
              color: Color(0xFF6C63FF),
              size: 18,
            ),
            label: Text(
              'Go Home',
              style: GoogleFonts.poppins(
                color: const Color(0xFF6C63FF),
                fontWeight: FontWeight.bold,
              ),
            ),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Color(0xFF6C63FF), width: 1.5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
