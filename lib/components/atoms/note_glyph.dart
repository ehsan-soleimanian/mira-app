import 'package:flutter/material.dart';
import 'package:mira_app/theme/note_card_tokens.dart';

/// Blue overlapping-notes glyph for [NoteCard] (24×24 SVG paths).
class NoteGlyph extends StatelessWidget {
  const NoteGlyph({super.key, this.size = 34});

  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: const CustomPaint(painter: NoteGlyphPainter()),
    );
  }
}

class NoteGlyphPainter extends CustomPainter {
  const NoteGlyphPainter();

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / 24.0, size.height / 24.0);

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..color = NoteCardTokens.glyphBlue
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final back = Path()
      ..moveTo(21.6602, 10.44)
      ..lineTo(20.6802, 14.62)
      ..cubicTo(19.8402, 18.23, 18.1802, 19.69, 15.0602, 19.39)
      ..cubicTo(14.5602, 19.35, 14.0202, 19.26, 13.4402, 19.12)
      ..lineTo(11.7602, 18.72)
      ..cubicTo(7.59018, 17.73, 6.30018, 15.67, 7.28018, 11.49)
      ..lineTo(8.26018, 7.30001)
      ..cubicTo(8.46018, 6.45001, 8.70018, 5.71001, 9.00018, 5.10001)
      ..cubicTo(10.1702, 2.68001, 12.1602, 2.03001, 15.5002, 2.82001)
      ..lineTo(17.1702, 3.21001)
      ..cubicTo(21.3602, 4.19001, 22.6402, 6.26001, 21.6602, 10.44)
      ..close();

    final front = Path()
      ..moveTo(15.0584, 19.3901)
      ..cubicTo(14.4384, 19.8101, 13.6584, 20.1601, 12.7084, 20.4701)
      ..lineTo(11.1284, 20.9901)
      ..cubicTo(7.15839, 22.2701, 5.06839, 21.2001, 3.77839, 17.2301)
      ..lineTo(2.49839, 13.2801)
      ..cubicTo(1.21839, 9.3101, 2.27839, 7.2101, 6.24839, 5.9301)
      ..lineTo(7.82839, 5.4101)
      ..cubicTo(8.23839, 5.2801, 8.62839, 5.1701, 8.99839, 5.1001)
      ..cubicTo(8.69839, 5.7101, 8.45839, 6.4501, 8.25839, 7.3001)
      ..lineTo(7.27839, 11.4901)
      ..cubicTo(6.29839, 15.6701, 7.58839, 17.7301, 11.7584, 18.7201)
      ..lineTo(13.4384, 19.1201)
      ..cubicTo(14.0184, 19.2601, 14.5584, 19.3501, 15.0584, 19.3901)
      ..close();

    final line1 = Path()
      ..moveTo(12.6406, 8.52979)
      ..lineTo(17.4906, 9.75979);
    final line2 = Path()
      ..moveTo(11.6602, 12.3999)
      ..lineTo(14.5602, 13.1399);

    canvas.drawPath(back, paint);
    canvas.drawPath(front, paint);
    canvas.drawPath(line1, paint);
    canvas.drawPath(line2, paint);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant NoteGlyphPainter oldDelegate) => false;
}
