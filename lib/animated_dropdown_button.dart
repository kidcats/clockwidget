import 'package:flutter/material.dart';

class AnimatedDropdownButton extends StatefulWidget {
  final String labelText;
  final List<DropdownMenuItem<int>> items;
  final ValueChanged<int?>? onChanged;

  AnimatedDropdownButton({
    required this.labelText,
    required this.items,
    this.onChanged,
  });

  @override
  _AnimatedDropdownButtonState createState() => _AnimatedDropdownButtonState();
}

class _AnimatedDropdownButtonState extends State<AnimatedDropdownButton>
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
      child: DropdownButtonFormField<int>(
        decoration: InputDecoration(
          labelText: widget.labelText,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          contentPadding: EdgeInsets.all(16),
        ),
        items: widget.items,
        onChanged: widget.onChanged,
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
