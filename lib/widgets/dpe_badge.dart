import 'package:flutter/material.dart';

const _kDpeColors = {
  'A': Color(0xFF00A86B),
  'B': Color(0xFF4CAF50),
  'C': Color(0xFF8BC34A),
  'D': Color(0xFFFFEB3B),
  'E': Color(0xFFFF9800),
  'F': Color(0xFFFF5722),
  'G': Color(0xFFF44336),
};

Color dpeColor(String letter) =>
    _kDpeColors[letter.toUpperCase()] ?? const Color(0xFF9E9E9E);

class DpeBadge extends StatelessWidget {
  const DpeBadge(this.dpe, {super.key, this.size = 14});

  final String dpe;
  final double size;

  @override
  Widget build(BuildContext context) {
    final letter = dpe.toUpperCase();
    final bg = dpeColor(letter);
    final useDark = letter == 'D'; // jaune → texte sombre
    return Container(
      padding:
          EdgeInsets.symmetric(horizontal: size * 0.5, vertical: size * 0.2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        letter,
        style: TextStyle(
          fontSize: size,
          fontWeight: FontWeight.w700,
          color: useDark ? Colors.black87 : Colors.white,
        ),
      ),
    );
  }
}
