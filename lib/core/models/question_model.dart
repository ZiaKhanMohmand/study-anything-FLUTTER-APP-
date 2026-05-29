enum QuestionType { mcq, shortQuestion, longQuestion, conceptual }

class Question {
  final String question;
  final QuestionType type;
  final List<String>? options; // Only for MCQ
  final String correctAnswer;
  final String explanation;
  String? userAnswer;
  bool? aiCorrect;

  Question({
    required this.question,
    required this.type,
    required this.correctAnswer,
    required this.explanation,
    this.options,
    this.userAnswer,
    this.aiCorrect,
  });

  factory Question.fromJson(Map<String, dynamic> json, QuestionType type) {
    return Question(
      question: json['question'] ?? '',
      type: type,
      options: json['options'] != null
          ? List<String>.from(json['options'])
          : null,
      correctAnswer: json['correct_answer'] ?? json['correct'] ?? '',
      explanation: json['explanation'] ?? '',
      aiCorrect: json['ai_correct'] as bool?,
    );
  }

  bool get isCorrect {
    if (aiCorrect != null) {
      return aiCorrect!; // ✅ use AI evaluation if available
    }
    if (userAnswer == null) return false;
    return userAnswer!.trim().toLowerCase() ==
        correctAnswer.trim().toLowerCase();
  }
}
