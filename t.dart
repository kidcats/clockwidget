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
  double _startAngle = 0.0;
  double _currentAngle = -(1 / 4 * pi);
  double maxAngle =  1 / 6 * pi;
  double minAngle =  -1 / 6 * pi;
  double _initialMouseX; // 鼠标初始水平位置
  double _totalTicks = (scaleValues.length-1) * 10; // 刻度盘的总格数
  double _currentTick = 0; // 当前指针所在的刻度
  double _screenWidth; // 屏幕宽度


  @override
void initState() {
  super.initState();
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

  // 缩放因子，降低角度变化的敏感度
double scale = 0.4;

void _handlePanStart(DragStartDetails details) {
  _animationController.stop();  // 先停止现有
  _initialMouseX = details.globalPosition.dx; // 记录鼠标初始位置为相对于当前控件的本地坐标
  _screenWidth = MediaQuery.of(context).size.width; // 获取屏幕宽度
}

void _handlePanUpdate(DragUpdateDetails details) {
  double newMouseX = details.globalPosition.dx;
  double dx = newMouseX - _initialMouseX; // 计算鼠标水平方向移动距离

  // 通过屏幕宽度比例计算预期角度
  double expectedAngle = 360 * dx / _screenWidth + _currentTick * (360 / _totalTicks);
  expectedAngle = expectedAngle.clamp(minAngle, maxAngle); // 限制角度范围

  // 计算新的刻度位置
  double newTick = (expectedAngle / (360 / _totalTicks)).roundToDouble();
  newTick = newTick.clamp(0, _totalTicks); // 保证刻度不超出范围

  if (_currentTick != newTick) {
    setState(() {
      _currentTick = newTick;
    });
  }

  // 更新鼠标初始位置，以便连续移动
  _initialMouseX = newMouseX;
}

void _handlePanEnd(DragEndDetails details) {
  double overshoot = _currentTick < _totalTicks / 2 ? -0.5 : 0.5; // 根据当前位置决定回弹方向
  _animation = Tween<double>(
    begin: _currentTick,
    end: (_currentTick + overshoot).clamp(0, _totalTicks),
  ).animate(
    CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut, // 弹性曲线增加回弹效果
    ),
  )
  ..addListener(() {
    setState(() {
      _currentTick = _animation.value;
    });
  });

  _animationController
    ..reset()
    ..forward();
}

  Widget build(BuildContext context) {
    return GestureDetector(
      onPanStart: _handlePanStart,
      onPanUpdate: _handlePanUpdate,
      onPanEnd: _handlePanEnd,
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
                _buildScale(size,maxAngle,minAngle),
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

  Widget _buildScale(Size size,double maxAngle,double minAngle) {
    return Container(
      width: size.width,
      height: size.height,
      child: CustomPaint(
        painter: _ScalePainter(
          scaleValues: widget.scaleValues,
          minAngle:minAngle,
          maxAngle: maxAngle,
        ),
      ),
    );
  }

  Widget _buildPointer(Size size) {
    final pointerLength = size.height * 0.6;
    final pointerOffsetY = size.height * 0.25; // 计算Y轴偏移量
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Stack(
          alignment: Alignment.bottomCenter,
          children: [
            Positioned(
              bottom: pointerOffsetY, // 使用Positioned来定位指针
              child: Transform.rotate(
                angle: _currentAngle,
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
    final radius = min(size.width, size.height) * 0.9; // 圆弧的半径
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
      final angle =
          minAngle + (i / (totalMarks - 1)) * angleRange; // 总共有这么多大的刻度，直接平分
      const isLongMark = true;
      const markLength = 16.0; // 长刻度的长度
      final markRadius = radius - markLength / 2; //刻度的直径 ? 由于半径太长了，所以超出屏幕外面了
      final markX = 0 - markRadius * cos(angle);
      final markY = 0 - markRadius * sin(angle);
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
