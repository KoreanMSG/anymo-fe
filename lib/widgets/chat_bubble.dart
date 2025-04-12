import 'package:flutter/material.dart';
import '../models/chat_model.dart';

class ChatBubble extends StatelessWidget {
  final Message message;

  const ChatBubble({
    super.key,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: message.isDoctor
          ? Alignment.centerRight
          : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!message.isDoctor) ...[
              CustomPaint(
                painter: TrianglePainter(
                  color: Colors.grey[300]!,
                  isLeft: true,
                ),
                size: const Size(10, 10),
              ),
              const SizedBox(width: 4),
            ],
            Flexible(
              child: Column(
                crossAxisAlignment: message.isDoctor
                    ? CrossAxisAlignment.end
                    : CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: message.isDoctor ? Colors.blue[100] : Colors.grey[200],
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      message.isDoctor ? 'Doctor' : 'Patient',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: message.isDoctor ? Colors.blue[900] : Colors.black,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                    decoration: BoxDecoration(
                      color: message.isDoctor ? Colors.blue : Colors.grey[300],
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(12),
                        topRight: const Radius.circular(12),
                        bottomLeft: Radius.circular(message.isDoctor ? 12 : 0),
                        bottomRight: Radius.circular(message.isDoctor ? 0 : 12),
                      ),
                    ),
                    child: Text(
                      message.text,
                      style: TextStyle(
                        color: message.isDoctor ? Colors.white : Colors.black,
                      ),
                      softWrap: true,
                    ),
                  ),
                ],
              ),
            ),
            if (message.isDoctor) ...[
              const SizedBox(width: 4),
              CustomPaint(
                painter: TrianglePainter(
                  color: Colors.blue,
                  isLeft: false,
                ),
                size: const Size(10, 10),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class TrianglePainter extends CustomPainter {
  final Color color;
  final bool isLeft;

  TrianglePainter({
    required this.color,
    required this.isLeft,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();
    if (isLeft) {
      path.moveTo(0, size.height / 2);
      path.lineTo(size.width, 0);
      path.lineTo(size.width, size.height);
    } else {
      path.moveTo(size.width, size.height / 2);
      path.lineTo(0, 0);
      path.lineTo(0, size.height);
    }
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(TrianglePainter oldDelegate) {
    return color != oldDelegate.color || isLeft != oldDelegate.isLeft;
  }
}
