import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
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

  final modes = [
    (
      type: QuestionType.mcq,
      title: 'MCQs',
      subtitle: '10 multiple choice questions',
      icon: Icons.check_circle_outline,
      color: Color(0xFF4CAF50),
      emoji: '📝',
    ),
    (
      type: QuestionType.shortQuestion,
      title: 'Short Questions',
      subtitle: '5 short answer questions',
      icon: Icons.short_text,
      color: Color(0xFF2196F3),
      emoji: '✏️',
    ),
    (
      type: QuestionType.longQuestion,
      title: 'Long Questions',
      subtitle: '3 detailed essay questions',
      icon: Icons.article_outlined,
      color: Color(0xFFFF9800),
      emoji: '📖',
    ),
    (
      type: QuestionType.conceptual,
      title: 'Conceptual',
      subtitle: '5 deep understanding questions',
      icon: Icons.lightbulb_outline,
      color: Color(0xFF9C27B0),
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
          title: const Text('❌ Error Generating Questions'),
          content: SingleChildScrollView(
            child: Text(e.toString(), style: const TextStyle(fontSize: 13)),
          ),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6C63FF),
              ),
              onPressed: () => Navigator.pop(ctx),
              child: const Text('OK', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5FF),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF6C63FF)),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Select Mode',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: const Color(0xFF2D2D2D),
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF6C63FF).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.picture_as_pdf,
                      color: Color(0xFF6C63FF),
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        widget.pdfName,
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF6C63FF),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'What type of test?',
                style: GoogleFonts.poppins(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF2D2D2D),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'AI will generate questions based on your PDF',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 24),
              if (_isLoading)
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const CircularProgressIndicator(
                          color: Color(0xFF6C63FF),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'Generating your questions...',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF2D2D2D),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'This may take a few seconds',
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                Expanded(
                  child: ListView.separated(
                    itemCount: modes.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 14),
                    itemBuilder: (context, i) {
                      final mode = modes[i];
                      return GestureDetector(
                        onTap: () => _generateQuiz(mode.type),
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: mode.color.withOpacity(0.12),
                                blurRadius: 15,
                                offset: const Offset(0, 5),
                              ),
                            ],
                            border: Border.all(
                              color: mode.color.withOpacity(0.2),
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: mode.color.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  mode.emoji,
                                  style: const TextStyle(fontSize: 28),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      mode.title,
                                      style: GoogleFonts.poppins(
                                        fontSize: 17,
                                        fontWeight: FontWeight.bold,
                                        color: const Color(0xFF2D2D2D),
                                      ),
                                    ),
                                    Text(
                                      mode.subtitle,
                                      style: GoogleFonts.poppins(
                                        fontSize: 13,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Icon(
                                Icons.arrow_forward_ios,
                                color: mode.color,
                                size: 18,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
