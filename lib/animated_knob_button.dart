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
  double _currentAngle = -0.35 * pi;
  double maxAngle = 1 / 4 * pi;
  double minAngle = -1 / 4 * pi;
  late double _totalTicks; // 刻度盘的总格数
  double _currentTick = 0; // 当前指针所在的刻度
  double _previousMouseX = 0.0; // 上一次鼠标的水平位置
  double _ticksPerPixel = 0.0; // 每像素对应的刻度数
  double offsetAngle = 0.0;

  @override
  void initState() {
    super.initState();
    _totalTicks = (widget.scaleValues.length - 1) * 10;
    _ticksPerPixel = _totalTicks / (maxAngle - minAngle);
    _totalTicks = (widget.scaleValues.length - 1) * 10;
    _animationController = AnimationController(
      duration: Duration(milliseconds: 500),
      vsync: this,
    );

    _animation = Tween<double>(begin: 0, end: 0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.elasticOut, // 使用具有回弹效果的曲线
      ),
    )..addListener(() {
        setState(() {
          _currentTick = _animation.value;
        });
      });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // 缩放因子,降低角度变化的敏感度
  double scale = 0.4;

  void _handlePanStart(DragStartDetails details) {
    _animationController.stop(); // 停止当前动画
    _previousMouseX = details.globalPosition.dx; // 记录鼠标起始水平位置
  }

  void _handlePanUpdate(DragUpdateDetails details) {
    final double _minAngle =  minAngle ;
    final double _maxAngle =  maxAngle;
    double newMouseX = details.globalPosition.dx;
    double dx = newMouseX - _previousMouseX;
    double deltaAngle = dx / _ticksPerPixel;

    double newAngle = _currentAngle + deltaAngle;
    newAngle = newAngle.clamp(_minAngle, _maxAngle);

    double newTick = ((newAngle - _minAngle) * _ticksPerPixel).roundToDouble();
    newTick = newTick.clamp(0, _totalTicks);

    if (_currentTick != newTick) {
      setState(() {
        _currentTick = newTick;
        _currentAngle = newAngle;
        widget.onValueChanged?.call(widget.scaleValues[
            (_currentTick ~/ 10).clamp(0, widget.scaleValues.length - 1)]);
      });
    }

    _previousMouseX = newMouseX;
  }

  void _handlePanEnd(DragEndDetails details) {
    final double _minAngle = minAngle ;
    final double _maxAngle =  maxAngle;
    double velocity = details.velocity.pixelsPerSecond.dx;
    double targetTick = _currentTick;

    if (velocity.abs() > 100) {
      double direction = velocity.sign;
      double targetAngle = _currentAngle + direction * (velocity.abs() / 1000);
      targetAngle = targetAngle.clamp(_minAngle, _maxAngle);
      targetTick = ((targetAngle - _minAngle) * _ticksPerPixel).roundToDouble();
      targetTick = targetTick.clamp(0, _totalTicks);
    }

    _animation = Tween<double>(
      begin: _currentTick,
      end: targetTick,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.decelerate,
      ),
    )..addListener(() {
        setState(() {
          _currentTick = _animation.value;
          _currentAngle = _minAngle + (_currentTick / _ticksPerPixel);
          widget.onValueChanged?.call(widget.scaleValues[
              (_currentTick ~/ 10).clamp(0, widget.scaleValues.length - 1)]);
        });
      });

    _animationController
      ..reset()
      ..forward();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanStart: _handlePanStart,
      onPanUpdate: _handlePanUpdate,
      onPanEnd: _handlePanEnd,
      child: LayoutBuilder(
        builder: (context, constraints) {
          // 使用constraints计算尺寸
          Size size = Size(constraints.maxWidth, constraints.maxHeight);
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
                _buildScale(size, maxAngle, minAngle),
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

  Widget _buildScale(Size size, double maxAngle, double minAngle) {
    return Container(
      width: size.width,
      height: size.height,
      child: CustomPaint(
        painter: _ScalePainter(
          scaleValues: widget.scaleValues,
          minAngle: minAngle,
          maxAngle: maxAngle,
        ),
      ),
    );
  }

Widget _buildPointer(Size size) {
  final pointerLength = size.height * 0.6;
  final pointerOffsetY = size.height * 0.1;
  final offsetAngle = atan(pointerOffsetY / (pointerLength / 2));

  return AnimatedBuilder(
    animation: _animation,
    builder: (context, child) {
      return Stack(
        alignment: Alignment.bottomCenter,
        children: [
          Positioned(
            bottom: pointerOffsetY,
            child: Transform.rotate(
              angle: _currentAngle - offsetAngle,
              alignment: Alignment.bottomCenter,
              child: CustomPaint(
                painter: _ScalePointerPainter(
                  angle: _currentAngle,
                  pointerLength: min(size.width, size.height) * 0.65,
                  pointerWidth: 8,
                ),
              ),
            ),
          ),
        ],
      );
    },
  );
}

  Widget _buildCenterPoint(Size size) {
    final centerPointRadius = widget.centerPointSize;
    return Transform(
      transform: Matrix4.identity()..translate(0.0, size.height * 0.4),
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
  final double minorTicksPerInterval;

  _ScalePainter({
    required this.scaleValues,
    required this.minAngle,
    required this.maxAngle,
    this.minorTicksPerInterval = 10,
  }) : textPainter = TextPainter(
          textDirection: TextDirection.ltr,
          textAlign: TextAlign.center,
        );

  @override
  void paint(Canvas canvas, Size size) {
    final width = size.width;
    final height = size.height;
    final centerX = width / 2;
    final radius = max(width, height) * 0.3;
    final tickLength = radius * 0.05;
    final minorTickLength = tickLength * 0.5;

    final linePaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final tickPaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final minorTickPaint = Paint()
      ..color = Colors.grey
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final angleRange = maxAngle - minAngle;
    final totalTicks = scaleValues.length;
    final tickAngleInterval = angleRange / (totalTicks - 1);

    canvas.translate(centerX, size.height/2+radius * cos(angleRange / 2));
    canvas.rotate(-pi / 2);

    // 绘制圆弧
    canvas.drawArc(
      Rect.fromCircle(center: Offset.zero, radius: radius),
      minAngle,
      angleRange,
      false,
      linePaint,
    );

    for (int i = 0; i < totalTicks; i++) {
      final value = scaleValues[i];
      final angle = minAngle + i * tickAngleInterval;

      // 绘制主刻度
      canvas.save();
      canvas.rotate(angle);
      canvas.drawLine(
        Offset(radius - tickLength, 0),
        Offset(radius+tickLength, 0),
        tickPaint,
      );
      canvas.restore();

      // 绘制主刻度上的数值
      textPainter.text = TextSpan(
        text: value.toStringAsFixed(1),
        style: TextStyle(color: Colors.black, fontSize: 16),
      );
      textPainter.layout();
      canvas.save();
      canvas.translate(
        (radius - tickLength - 16) * cos(angle),
        (radius - tickLength - 16) * sin(angle),
      );
      canvas.rotate(angle + pi / 2);
      textPainter.paint(canvas, Offset(-textPainter.width / 2, 0));
      canvas.restore();

      // 绘制次刻度
      if (i < totalTicks - 1) {
        final minorTickAngleInterval = tickAngleInterval / (minorTicksPerInterval + 1);
        for (int j = 1; j <= minorTicksPerInterval; j++) {
          final minorAngle = angle + j * minorTickAngleInterval;
          canvas.save();
          canvas.rotate(minorAngle);
          canvas.drawLine(
            Offset(radius - minorTickLength, 0),
            Offset(radius, 0),
            minorTickPaint,
          );
          canvas.restore();
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

class _ScalePointerPainter extends CustomPainter {
  final double angle;
  final double pointerLength;
  final double pointerWidth;

  _ScalePointerPainter({
    required this.angle,
    required this.pointerLength,
    required this.pointerWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final centerY = size.height / 2;
    final radius = max(size.width, size.height) * 0.7;

    final pointerPaint = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.fill;

    canvas.translate(centerX, centerY);
    canvas.rotate(angle);

    final pointerPath = Path()
      ..moveTo(-pointerWidth / 2, 0)
      ..lineTo(0, -pointerLength)
      ..lineTo(pointerWidth / 2, 0) 
      ..close();

    canvas.drawPath(pointerPath, pointerPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
