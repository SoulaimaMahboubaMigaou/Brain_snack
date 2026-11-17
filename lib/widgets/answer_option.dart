import 'package:flutter/material.dart';

class AnswerOption extends StatelessWidget {
  const AnswerOption({
    super.key,
    required this.label,
    required this.isSelected,
    required this.isCorrect,
    required this.isLocked,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final bool isCorrect;
  final bool isLocked;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    Color background = const Color(0xFF122033);
    Color border = Colors.white.withValues(alpha: 0.06);

    if (isLocked && isCorrect) {
      background = const Color(0xFF133C32);
      border = const Color(0xFF17B890);
    } else if (isLocked && isSelected && !isCorrect) {
      background = const Color(0xFF402127);
      border = const Color(0xFFFF6B6B);
    } else if (isSelected) {
      background = const Color(0xFF173B63);
      border = const Color(0xFF5B8CFF);
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: background,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: isLocked ? null : onTap,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: border, width: 1.4),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    label,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                if (isLocked && isCorrect)
                  const Icon(
                    Icons.check_circle_rounded,
                    color: Color(0xFF2DE1B8),
                  )
                else if (isLocked && isSelected && !isCorrect)
                  const Icon(Icons.cancel_rounded, color: Color(0xFFFF8A8A)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
