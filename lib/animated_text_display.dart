import 'package:flutter/material.dart';

class AnimatedTextDisplay extends StatefulWidget {
  final String text;

  AnimatedTextDisplay({required this.text});

  @override
  _AnimatedTextDisplayState createState() => _AnimatedTextDisplayState();
}

class _AnimatedTextDisplayState extends State<AnimatedTextDisplay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(_controller);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Opacity(
          opacity: _animation.value,
          child: Transform.translate(
            offset: Offset(0.0, 50 * (1 - _animation.value)),
            child: child,
          ),
        );
      },
      child: Text(
        widget.text,
        style: TextStyle(fontSize: 24),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _controller.forward();
  }
}
