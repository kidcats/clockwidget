import 'dart:math';
import 'package:flutter/material.dart';

class AmmeterWidget extends StatefulWidget {
  final List<double> scaleValues;
  final double pointerLength;
  final double centerPointSize;
  final Color pointerColor;
  final ValueChanged<double>? onValueChanged;

  AmmeterWidget({
    required this.scaleValues,
    this.pointerLength = 200.0,
    this.centerPointSize = 40.0,
    this.pointerColor = Colors.red,
    this.onValueChanged,
  });

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
  final RenderBox renderBox = context.findRenderObject() as RenderBox;
  final offset = renderBox.globalToLocal(details.globalPosition);
  final center = renderBox.size.center(Offset.zero);

  double touchAngle = math.atan2(offset.dy - center.dy, offset.dx - center.dx);
  _currentAngle = touchAngle - _startAngle;
  // 限制角度范围
  _currentAngle = math.max(math.pi / 180 * -150, math.min(math.pi / 180 * 150, _currentAngle));

  // 更新动画
  _animation = Tween(begin: _animation.value, end: _currentAngle).animate(_animationController)
    ..addListener(() {
      setState(() {});
    });
  _animationController.forward(from: 0.0);

  // 更新数值并调用回调
  final newValue = _calculateValueFromAngle(_currentAngle);
  if (_currentValue != newValue) {
    widget.onValueChanged?.call(newValue);
    _currentValue = newValue;
  }
}

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanStart: _handlePanStart,
      onPanUpdate: _handlePanUpdate,
      child: Container(
        width: 300,
        height: 300,
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
        return Transform(
          transform: Matrix4.identity()
            ..translate(0.0, -widget.pointerLength / 2 + 25 )
            ..rotateZ(_currentAngle - (0.4 * pi)),
          alignment: Alignment.bottomCenter,
          child: Container(
            width: 8,
            height: widget.pointerLength,
            decoration: BoxDecoration(
              color: widget.pointerColor,
              borderRadius: BorderRadius.circular(2),
              gradient: LinearGradient(
                colors: [
                  widget.pointerColor.withOpacity(0.7),
                  widget.pointerColor.withOpacity(0.9),
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
        );
      },
    );
  }

  Widget _buildCenterPoint() {
    return Container(
      width: widget.centerPointSize,
      height: widget.centerPointSize,
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
    final radius = size.width;

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
  final TextPainter textPainter;

  _ScalePainter({
    required this.scaleValues,
    required this.minAngle,
    required this.maxAngle,
  }) : textPainter = TextPainter(
          textDirection: TextDirection.ltr,
          textAlign: TextAlign.center,
        );

  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final centerY = size.height / 2;
    final radius = min(centerX, centerY) - 140;

    final paint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    final markPaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    final double angleRange = maxAngle - minAngle;
    final int totalMarks = scaleValues.length;

    canvas.rotate(pi / 2);
    canvas.translate(size.height, 0);

    for (int i = 0; i < totalMarks; i++) {
      final value = scaleValues[i];
      final angle = minAngle + (i / (totalMarks - 1)) * angleRange;
      const isLongMark = true;
      const markLength = 16.0;
      final markRadius = radius - markLength;
      final markX = centerY + markRadius * cos(angle);
      final markY = centerX + markRadius * sin(angle);
      canvas.save();
      canvas.translate(markX, markY);
      canvas.rotate(angle - pi / 2);
      canvas.drawLine(
        Offset(0, -markLength / 2),
        Offset(0, markLength / 2),
        markPaint,
      );
      canvas.restore();

      if (i < totalMarks - 1) {
        final nextValue = scaleValues[i + 1];
        final nextAngle = minAngle + ((i + 1) / (totalMarks - 1)) * angleRange;
        final auxiliaryMarksCount = 10;

        for (int j = 1; j <= auxiliaryMarksCount; j++) {
          final fraction = j / (auxiliaryMarksCount + 1);
          final auxiliaryAngle = angle + fraction * (nextAngle - angle);

          final auxiliaryMarkX = centerY + markRadius * cos(auxiliaryAngle);
          final auxiliaryMarkY = centerX + markRadius * sin(auxiliaryAngle);

          canvas.save();
          canvas.translate(auxiliaryMarkX, auxiliaryMarkY);
          canvas.rotate(auxiliaryAngle - pi / 2);

          canvas.drawLine(
            Offset(0, -4.0),
            Offset(0, 4.0),
            markPaint..strokeWidth = 0.5,
          );

          canvas.restore();
        }
      }

      canvas.save();
      canvas.translate(markX, markY);
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
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
