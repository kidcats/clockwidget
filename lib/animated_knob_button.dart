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
    this.centerPointSize = 20.0,
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

  void _handlePanStart(DragStartDetails details) {
    _startAngle = _currentAngle;
  }

  double _calculateValueFromAngle(
      double angle, double maxAngle, double minAngle) {
    // 将角度从弧度转换为度
    double angleInDegrees = angle * 180 / pi;

    // 确定角度和数值之间的比例
    // 这里假设电表的角度范围是 -150 到 150 度，对应的数值范围是 0 到 100
    double minValue = 0.0;
    double maxValue = 100.0;

    // 计算当前角度对应的数值
    // 先将角度限制在有效范围内
    double clampedAngle = max(minAngle, min(maxAngle, angleInDegrees));
    // 计算数值
    double value = ((clampedAngle - minAngle) / (maxAngle - minAngle)) *
            (maxValue - minValue) +
        minValue;

    return value;
  }

  void _handlePanUpdate(DragUpdateDetails details) {
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final offset = renderBox.globalToLocal(details.globalPosition);
    final center = renderBox.size.center(Offset.zero);

    double touchAngle = atan2(offset.dy - center.dy, offset.dx - center.dx);
    _currentAngle = touchAngle - _startAngle;
    // 限制角度范围
    _currentAngle = max(pi / 180 * -150, min(pi / 180 * 150, _currentAngle));

    // 更新动画
    _animation = Tween(begin: _animation.value, end: _currentAngle)
        .animate(_animationController)
      ..addListener(() {
        setState(() {});
      });
    _animationController.forward(from: 0.0);

    // 更新数值并调用回调
    final newValue =
        _calculateValueFromAngle(_currentAngle, 1 / 6 * pi, -1 / 6 * pi);
    if (_currentValue != newValue) {
      widget.onValueChanged?.call(newValue);
      _currentValue = newValue;
    }
  }

  Widget build(BuildContext context) {
    return GestureDetector(
      onPanStart: _handlePanStart,
      onPanUpdate: _handlePanUpdate,
      child: LayoutBuilder(
        builder: (context, constraints) {
          // 使用constraints计算尺寸
          Size size = Size(constraints.maxWidth, constraints.maxHeight);
          print(size);
          return Container(
            width: size.width,
            height: size.height,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(size.height / 2),
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
                _buildAmmeterBackground(size),
                _buildScale(size),
                _buildPointer(size),
                _buildCenterPoint(size),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildAmmeterBackground(Size size) {
    return CustomPaint(
      painter: _AmmeterBackgroundPainter(size),
    );
  }

  Widget _buildScale(Size size) {
    return Container(
      width: size.width,
      height: size.height,
      child: CustomPaint(
        painter: _ScalePainter(
          scaleValues: widget.scaleValues,
          minAngle: -1 / 4 * pi,
          maxAngle: 1 / 4 * pi,
        ),
      ),
    );
  }

  Widget _buildPointer(Size size) {
    final pointerLength = size.height * 0.6;
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform(
          transform: Matrix4.identity()
            ..translate(0.0, -size.height * 0.08)
            ..rotateZ(_currentAngle - (1 / 4 * pi)),
          alignment: Alignment.bottomCenter,
          child: Container(
            width: 8,
            height: pointerLength,
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

  Widget _buildCenterPoint(Size size) {
    final centerPointRadius = widget.centerPointSize;
    return Transform(
      transform: Matrix4.identity()..translate(0.0, size.height * 0.22),
      child: Container(
        width: centerPointRadius,
        height: centerPointRadius,
        decoration: BoxDecoration(
          color: Colors.black,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}

class _AmmeterBackgroundPainter extends CustomPainter {
  _AmmeterBackgroundPainter(Size size);

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
    final radius = min(size.width, size.height)*0.9; // 圆弧的半径
    // final radius = -300; // 圆弧的半径
    final markPaint = Paint() // 长刻度的画笔
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    final double angleRange = maxAngle - minAngle; // 度数范围
    final int totalMarks = scaleValues.length; // 刻度范围
    canvas.rotate(pi / 2); // 画布旋转现在X轴向下，Y轴向左边
    canvas.translate(size.height, -centerX); // 画布平移 ，这个真的有用吗？打印的都是0，为什么

    for (int i = 0; i < totalMarks; i++) {
      final value = scaleValues[i];
      final angle = minAngle + (i / (totalMarks - 1)) * angleRange; // 总共有这么多大的刻度，直接平分
      const isLongMark = true;
      const markLength = 16.0; // 长刻度的长度
      final markRadius = radius - markLength / 2; //刻度的直径 ? 由于半径太长了，所以超出屏幕外面了
      final markX = 0 - markRadius * cos(angle);
      final markY = 0 -  markRadius * sin(angle);
      print("---------");
      print(markX);
      print("----X----");
      print(markY);
      print("----Y----");
      print("---------");
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

          final auxiliaryMarkX = 0 - markRadius * cos(auxiliaryAngle);
          final auxiliaryMarkY = 0 - markRadius * sin(auxiliaryAngle);

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
