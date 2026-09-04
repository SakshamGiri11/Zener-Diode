import 'package:flutter/material.dart';
import '../../controllers/lab_controller.dart';
import '../../models/quiz_question.dart';

class QuizVivaView extends StatelessWidget {
  final LabController controller;

  const QuizVivaView({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final questions = controller.questions;
    final answers = controller.quizAnswers;
    final score = controller.quizScore;
    final total = questions.length;
    final answeredCount = answers.length;

    final cardBg = isDark ? const Color(0xFF131D2F) : Colors.white;
    final borderColor = isDark ? const Color(0xFF22324D) : const Color(0xFFE2E8F0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. Score & Progress Header Card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: borderColor, width: 1.2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isDark ? 0.2 : 0.03),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF38BDF8).withOpacity(0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.quiz_rounded, color: Color(0xFF38BDF8), size: 20),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'Viva-Voce Self Assessment',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: isDark ? const Color(0xFFF1F5F9) : const Color(0xFF0F172A),
                          letterSpacing: -0.2,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0284C7).withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFF0284C7), width: 1.2),
                        ),
                        child: Text(
                          'Score: $score / $total',
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 13.5,
                            color: Color(0xFF38BDF8),
                          ),
                        ),
                      ),
                      if (answeredCount > 0) ...[
                        const SizedBox(width: 8),
                        TextButton.icon(
                          onPressed: controller.resetQuiz,
                          icon: const Icon(Icons.restart_alt_rounded, size: 16),
                          label: const Text('Reset', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: total > 0 ? (answeredCount / total) : 0,
                  backgroundColor: isDark ? const Color(0xFF090E1A) : const Color(0xFFE2E8F0),
                  valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF38BDF8)),
                  minHeight: 6,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Answered: $answeredCount of $total questions',
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w500,
                  color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),

        // 2. Questions List
        ...questions.map((q) {
          final selectedOption = answers[q.id];
          final isAnswered = selectedOption != null;
          final isCorrect = isAnswered && selectedOption == q.correctOptionIndex;

          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isAnswered
                    ? (isCorrect ? const Color(0xFF10B981) : const Color(0xFFEF4444))
                    : borderColor,
                width: isAnswered ? 1.5 : 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(isDark ? 0.2 : 0.03),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header (Topic Badge + Correct/Incorrect Indicator)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFF38BDF8).withOpacity(0.12),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'Q${q.id} • ${q.topic}',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF38BDF8),
                        ),
                      ),
                    ),
                    const Spacer(),
                    if (isAnswered)
                      Icon(
                        isCorrect ? Icons.check_circle_rounded : Icons.cancel_rounded,
                        color: isCorrect ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                        size: 22,
                      ),
                  ],
                ),
                const SizedBox(height: 10),

                // Question Heading (H)
                Text(
                  q.question,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    height: 1.45,
                    color: isDark ? const Color(0xFFF1F5F9) : const Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 14),

                // Options List (P)
                ...List.generate(q.options.length, (optIdx) {
                  final optText = q.options[optIdx];
                  final isThisSelected = selectedOption == optIdx;
                  final isThisCorrect = q.correctOptionIndex == optIdx;

                  Color optBg;
                  Color optBorder;
                  Color optTextCol;

                  if (isAnswered) {
                    if (isThisCorrect) {
                      optBg = const Color(0xFF064E3B).withOpacity(0.35);
                      optBorder = const Color(0xFF10B981);
                      optTextCol = const Color(0xFF6EE7B7);
                    } else if (isThisSelected) {
                      optBg = const Color(0xFF7F1D1D).withOpacity(0.35);
                      optBorder = const Color(0xFFEF4444);
                      optTextCol = const Color(0xFFFCA5A5);
                    } else {
                      optBg = isDark ? const Color(0xFF090E1A) : const Color(0xFFF8FAFC);
                      optBorder = borderColor;
                      optTextCol = isDark ? Colors.white38 : Colors.black38;
                    }
                  } else {
                    optBg = isDark ? const Color(0xFF090E1A) : const Color(0xFFF8FAFC);
                    optBorder = borderColor;
                    optTextCol = isDark ? const Color(0xFFCBD5E1) : const Color(0xFF334155);
                  }

                  return InkWell(
                    borderRadius: BorderRadius.circular(8),
                    onTap: isAnswered
                        ? null
                        : () => controller.answerQuizQuestion(q.id, optIdx),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: optBg,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: optBorder, width: 1.2),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: optBorder),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              String.fromCharCode(65 + optIdx),
                              style: TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.bold,
                                color: optTextCol,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              optText,
                              style: TextStyle(
                                fontSize: 13,
                                height: 1.4,
                                color: optTextCol,
                                fontWeight: isThisSelected || (isAnswered && isThisCorrect)
                                    ? FontWeight.bold
                                    : FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),

                // Explanation Box (P)
                if (isAnswered) ...[
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF090E1A) : const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isDark ? const Color(0xFF1E293B) : const Color(0xFFCBD5E1),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.info_outline_rounded,
                            size: 18, color: Color(0xFF38BDF8)),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            q.explanation,
                            style: TextStyle(
                              fontSize: 12.5,
                              height: 1.5,
                              color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF334155),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          );
        }),
      ],
    );
  }
}
