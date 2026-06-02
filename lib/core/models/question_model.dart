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
    return _fallbackMatches(userAnswer!, correctAnswer, type);
  }

  bool _fallbackMatches(
    String userAnswer,
    String correctAnswer,
    QuestionType type,
  ) {
    final normalizedUserAnswer = _normalizeText(userAnswer);
    final normalizedCorrectAnswer = _normalizeText(correctAnswer);

    if (normalizedUserAnswer.isEmpty || normalizedCorrectAnswer.isEmpty) {
      return false;
    }

    if (type == QuestionType.mcq) {
      return normalizedUserAnswer == normalizedCorrectAnswer;
    }

    if (normalizedUserAnswer == normalizedCorrectAnswer) {
      return true;
    }

    if (normalizedUserAnswer.contains(normalizedCorrectAnswer) ||
        normalizedCorrectAnswer.contains(normalizedUserAnswer)) {
      return true;
    }

    final userTokens = _contentTokens(normalizedUserAnswer);
    final correctTokens = _contentTokens(normalizedCorrectAnswer);

    if (userTokens.isEmpty || correctTokens.isEmpty) {
      return false;
    }

    final overlap = userTokens.intersection(correctTokens).length;
    final overlapScore = overlap / correctTokens.length;
    final coverageScore = overlap / userTokens.length;

    final threshold = switch (type) {
      QuestionType.shortQuestion => 0.45,
      QuestionType.longQuestion => 0.35,
      QuestionType.conceptual => 0.4,
      QuestionType.mcq => 1.0,
    };

    return overlapScore >= threshold || coverageScore >= threshold;
  }

  String _normalizeText(String text) {
    return text
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9\s]'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  Set<String> _contentTokens(String text) {
    const stopWords = {
      'a',
      'an',
      'the',
      'and',
      'or',
      'but',
      'if',
      'to',
      'of',
      'in',
      'on',
      'for',
      'with',
      'as',
      'by',
      'at',
      'from',
      'is',
      'are',
      'was',
      'were',
      'be',
      'been',
      'being',
      'it',
      'this',
      'that',
      'these',
      'those',
      'they',
      'them',
      'their',
      'there',
      'here',
      'about',
      'into',
      'over',
      'under',
      'through',
      'during',
      'before',
      'after',
      'between',
      'within',
      'without',
      'because',
      'while',
      'when',
      'where',
      'why',
      'how',
      'what',
      'which',
      'who',
      'whom',
      'whose',
    };

    return text
        .split(' ')
        .map((word) => word.trim())
        .where(
          (word) =>
              word.isNotEmpty && word.length > 2 && !stopWords.contains(word),
        )
        .toSet();
  }
}
