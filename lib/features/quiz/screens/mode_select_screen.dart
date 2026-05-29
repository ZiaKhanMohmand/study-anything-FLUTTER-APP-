import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:study_anything/widgets/banner_ad_widget.dart';
import '../../../core/models/question_model.dart';
import '../../../core/services/gemini_service.dart';

class ModeSelectScreen extends ConsumerStatefulWidget {
  final String pdfText;
  final String pdfName;

  const ModeSelectScreen({
    super.key,
    required this.pdfText,
    required this.pdfName,
  });

  @override
  ConsumerState<ModeSelectScreen> createState() => _ModeSelectScreenState();
}

class _ModeSelectScreenState extends ConsumerState<ModeSelectScreen> {
  bool _isLoading = false;

  final List<_QuizMode> modes = [
    const _QuizMode(
      type: QuestionType.mcq,
      title: 'MCQs',
      subtitle: '10 multiple choice questions',
      icon: Icons.check_circle_outline_rounded,
      color: Color(0xFF4CAF50),
      bg: Color(0xFFE8F5E9),
      borderColor: Color(0xFF4CAF50),
      emoji: '📝',
    ),
    const _QuizMode(
      type: QuestionType.shortQuestion,
      title: 'Short Questions',
      subtitle: '5 short answer questions',
      icon: Icons.short_text_rounded,
      color: Color(0xFF2196F3),
      bg: Color(0xFFE3F2FD),
      borderColor: Color(0xFF2196F3),
      emoji: '✏️',
    ),
    const _QuizMode(
      type: QuestionType.longQuestion,
      title: 'Long Questions',
      subtitle: '3 detailed essay questions',
      icon: Icons.article_outlined,
      color: Color(0xFFFF9800),
      bg: Color(0xFFFFF3E0),
      borderColor: Color(0xFFFF9800),
      emoji: '📖',
    ),
    const _QuizMode(
      type: QuestionType.conceptual,
      title: 'Conceptual',
      subtitle: '5 deep understanding questions',
      icon: Icons.lightbulb_outline_rounded,
      color: Color(0xFF9C27B0),
      bg: Color(0xFFF3E5F5),
      borderColor: Color(0xFF9C27B0),
      emoji: '💡',
    ),
  ];

  Future<void> _generateQuiz(QuestionType type) async {
    setState(() => _isLoading = true);
    try {
      final questions = await GeminiService().generateQuestions(
        widget.pdfText,
        type,
      );
      print('=== QUESTIONS RECEIVED: ${questions.length} ===');

      if (questions.isEmpty) {
        throw Exception('No questions were generated. Try a different PDF.');
      }

      if (!mounted) return;
      setState(() => _isLoading = false);
      context.push(
        '/quiz',
        extra: {'questions': questions, 'pdfName': widget.pdfName},
      );
    } catch (e) {
      print('=== ERROR: $e ===');
      if (!mounted) return;
      setState(() => _isLoading = false);
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            'Error Generating Questions',
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            child: Text(
              e.toString(),
              style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey[600]),
            ),
          ),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6C63FF),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              onPressed: () => Navigator.pop(ctx),
              child: Text(
                'OK',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F0FF),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8),
          child: GestureDetector(
            onTap: () => context.pop(),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFE8E8F5)),
              ),
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: Color(0xFF6C63FF),
                size: 16,
              ),
            ),
          ),
        ),
        title: Text(
          'Select Mode',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: const Color(0xFF1a1a2e),
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _pdfChip(),
              const SizedBox(height: 20),
              Text(
                'What type of test?',
                style: GoogleFonts.poppins(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1a1a2e),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'AI will generate questions based on your PDF',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: Colors.grey[500],
                ),
              ),
              const SizedBox(height: 20),
              if (_isLoading) _loadingView() else _modeList(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const Padding(
        padding: EdgeInsets.only(bottom: 8),
        child: BannerAdWidget(),
      ),
    );
  }

  Widget _pdfChip() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFEEEDFE),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.picture_as_pdf_rounded,
            color: Color(0xFF6C63FF),
            size: 16,
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              widget.pdfName,
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF534AB7),
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _loadingView() {
    return Expanded(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: const Color(0xFFEEEDFE),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Padding(
                padding: EdgeInsets.all(18),
                child: CircularProgressIndicator(
                  color: Color(0xFF6C63FF),
                  strokeWidth: 3,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Generating your questions...',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1a1a2e),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'This may take a few seconds',
              style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey[400]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _modeList() {
    return Expanded(
      child: ListView.separated(
        itemCount: modes.length,
        separatorBuilder: (_, _) => const SizedBox(height: 12),
        itemBuilder: (context, i) {
          final mode = modes[i];
          return GestureDetector(
            onTap: () => _generateQuiz(mode.type),
            child: Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE8E8F5), width: 1),
                boxShadow: [
                  BoxShadow(
                    color: mode.color.withOpacity(0.08),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              clipBehavior: Clip.antiAlias,
              child: Row(
                children: [
                  Container(width: 4, color: mode.borderColor),
                  const SizedBox(width: 14),
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: mode.bg,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Center(
                      child: Text(
                        mode.emoji,
                        style: const TextStyle(fontSize: 22),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          mode.title,
                          style: GoogleFonts.poppins(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF1a1a2e),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          mode.subtitle,
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: mode.bg,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: mode.color,
                      size: 13,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _QuizMode {
  final QuestionType type;
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final Color bg;
  final Color borderColor;
  final String emoji;

  const _QuizMode({
    required this.type,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.bg,
    required this.borderColor,
    required this.emoji,
  });
}
