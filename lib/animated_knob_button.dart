import 'dart:math';
import 'package:flutter/material.dart';

class AmmeterWidget extends StatefulWidget {
  final List<double> scaleValues;
  final ValueChanged<double>? onValueChanged;

  AmmeterWidget({required this.scaleValues, this.onValueChanged});

  @override
  _AmmeterWidgetState createState() => _AmmeterWidgetState();
}

class _AmmeterWidgetState extends State<AmmeterWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  double _currentValue = 0.0;
  double _startAngle = 0.0;
  double _currentAngle = 0.0;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _updateValue(double angle) {
    double normalizedAngle = (angle % (2 * pi) + 2 * pi) % (2 * pi);
    double value = (normalizedAngle / (2 * pi)) *
            (widget.scaleValues.last - widget.scaleValues.first) +
        widget.scaleValues.first;
    value = value.clamp(widget.scaleValues.first, widget.scaleValues.last);
    setState(() {
      _currentValue = value;
      _currentAngle = normalizedAngle;
    });
    _animationController.forward(from: 0.0);
    widget.onValueChanged?.call(_currentValue);
  }

  void _handlePanStart(DragStartDetails details) {
    _startAngle = _currentAngle;
  }

  void _handlePanUpdate(DragUpdateDetails details) {
    RenderBox renderBox = context.findRenderObject() as RenderBox;
    Offset center = renderBox.size.center(Offset.zero);
    Offset localPosition = renderBox.globalToLocal(details.globalPosition);
    double touchAngle = (localPosition - center).direction;
    double angleDiff = touchAngle - _startAngle;
    _updateValue(_currentAngle + angleDiff);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanStart: _handlePanStart,
      onPanUpdate: _handlePanUpdate,
      child: Container(
        width: 1500,
        height: 800,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(150),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              spreadRadius: 2,
              blurRadius: 5,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            _buildAmmeterBackground(),
            _buildScale(),
            _buildPointer(),
            _buildCenterPoint(),
          ],
        ),
      ),
    );
  }

  Widget _buildAmmeterBackground() {
    return CustomPaint(
      painter: _AmmeterBackgroundPainter(),
    );
  }

  Widget _buildScale() {
    return CustomPaint(
      painter: _ScalePainter(
        scaleValues: widget.scaleValues,
        minAngle: -0.4 * pi,
        maxAngle: 0.4 * pi,
      ),
    );
  }

Widget _buildPointer() {
  return AnimatedBuilder(
    animation: _animation,
    builder: (context, child) {
      const pointerLength = 200.0; // 指针长度
      const translateY = -pointerLength / 2; // 向上偏移半个指针长度

      return Transform.translate(
        offset: const Offset(0, translateY),
        child: Transform.rotate(
          angle: _currentAngle - (0.4 * pi),
          alignment: Alignment.bottomCenter, // 设置旋转中心为底部中心
          child: Container(
            width: 8,
            height: pointerLength,
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.circular(2),
              gradient: LinearGradient(
                colors: [
                  Colors.red[700]!,
                  Colors.red[900]!,
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 2,
                  offset: Offset(0, 1),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}

  // these code for center point black
  Widget _buildCenterPoint() {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: Colors.black,
        shape: BoxShape.circle,
      ),
    );
  }
}

class _AmmeterBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final centerY = size.width;
    final radius =  size.width;

    final paint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8;

    canvas.drawArc(
      Rect.fromCircle(center: Offset(centerX, centerY), radius: radius),
      -0.1 * pi,
      0.1 * pi,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

class _ScalePainter extends CustomPainter {
  final List<double> scaleValues;
  final double minAngle;
  final double maxAngle;

  _ScalePainter(
      {required this.scaleValues,
      required this.minAngle,
      required this.maxAngle});

  @override
  void paint(Canvas canvas, Size size) {
    // Calculate the center coordinates of the widget
    final centerX = size.width / 2;
    final centerY = size.height / 2;

    // Calculate the radius of the scale based on the widget size
    final radius = min(centerX, centerY) - 40;

    // Create a paint object for drawing the scale lines
    final paint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    // Create a paint object for drawing the scale marks
    final markPaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    // Create a text painter for rendering the scale values
    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );

    // Calculate the range of angles for the scale
    final double angleRange = maxAngle - minAngle;

    // Get the total number of scale marks based on the scaleValues list
    final int totalMarks = scaleValues.length;

    // Rotate the canvas 90° clockwise
    canvas.rotate(pi / 2);
    canvas.translate(size.height, 0);

    // Iterate through each scale mark
    for (int i = 0; i < totalMarks; i++) {
      // Get the value for the current scale mark
      final value = scaleValues[i];

      // Calculate the angle for the current scale mark
      final angle = minAngle + (i / (totalMarks - 1)) * angleRange;

      // Check if the current scale mark is a long mark (every 5th mark)
      const isLongMark = true;

      // Set the length of the scale mark based on whether it's a long mark or not
      const markLength = 16.0;

      // Calculate the radius for the scale mark position
      final markRadius = radius - markLength;

      // Calculate the x and y coordinates for the scale mark position
      final markX = centerY + markRadius * cos(angle);
      final markY = centerX + markRadius * sin(angle);

      // Save the current canvas state
      canvas.save();

      // Translate the canvas to the scale mark position
      canvas.translate(markX, markY);

      // Rotate the canvas to align the scale mark with the angle
      canvas.rotate(angle - pi / 2);

      // Draw the scale mark line
      canvas.drawLine(
        Offset(0, -markLength / 2),
        Offset(0, markLength / 2),
        markPaint,
      );
      canvas.restore();
      // Draw auxiliary tick marks between major tick marks
      // Add auxiliary marks between two main marks
      if (i < totalMarks - 1) {
        final nextValue = scaleValues[i + 1];
        final nextAngle = minAngle + ((i + 1) / (totalMarks - 1)) * angleRange;
        final auxiliaryMarksCount = 10; // Adjust count as needed

        for (int j = 1; j <= auxiliaryMarksCount; j++) {
          final fraction = j / (auxiliaryMarksCount + 1);
          final auxiliaryAngle = angle + fraction * (nextAngle - angle);

          final auxiliaryMarkX = centerY + markRadius * cos(auxiliaryAngle);
          final auxiliaryMarkY = centerX + markRadius * sin(auxiliaryAngle);

          canvas.save();
          canvas.translate(auxiliaryMarkX, auxiliaryMarkY);
          canvas.rotate(auxiliaryAngle - pi / 2);

          canvas.drawLine(
            Offset(0, -4.0), // Shorter mark
            Offset(0, 4.0),
            markPaint..strokeWidth = 0.5,
          );

          canvas.restore();
        }
      }

      // Correctly place this block inside the loop to handle all long marks
      canvas.save();
      canvas.translate(markX, markY);

      // Rotate the canvas to align the scale mark with the angle
      canvas.rotate(angle - pi / 2);
      if (isLongMark) {
        textPainter.text = TextSpan(
          text: value.toStringAsFixed(0),
          style: TextStyle(color: Colors.black, fontSize: 12),
        );
        textPainter.layout();
        textPainter.paint(
          canvas,
          Offset(
            -textPainter.width / 2,
            markLength / 2 + 4,
          ),
        );
      }
      // Restore the canvas state to its previous state
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    // Repaint the scale whenever the scaleValues, minAngle, or maxAngle change
    return true;
  }
}
