import 'package:flutter/material.dart';

class DigitalTubeInput extends StatefulWidget {
  final Function(int) onNumberChanged;

  DigitalTubeInput({required this.onNumberChanged});

  @override
  _DigitalTubeInputState createState() => _DigitalTubeInputState();
}

class _DigitalTubeInputState extends State<DigitalTubeInput> {
  final List<TextEditingController> _controllers = List.generate(
    4,
    (index) => TextEditingController(text: '0'),
  );

  final List<FocusNode> _focusNodes = List.generate(4, (index) => FocusNode());

  int getCombinedNumber() {
    int combinedNumber = 0;
    for (int i = 0; i < _controllers.length; i++) {
      int digit = int.tryParse(_controllers[i].text) ?? 0;
      combinedNumber = combinedNumber * 10 + digit;
    }
    return combinedNumber;
  }

  void _handleTextChanged(TextEditingController controller, String value, int index) {
    if (value.isEmpty) {
      controller.text = '0';
    } else if (value.length > 1) {
      controller.text = value.substring(value.length - 1);
    }
    controller.selection = TextSelection.fromPosition(
      TextPosition(offset: controller.text.length),
    );
    if (value.isNotEmpty && index < _controllers.length - 1) {
      _focusNodes[index + 1].requestFocus();
    }
    widget.onNumberChanged(getCombinedNumber());
  }

  Widget _buildDigitalTube(TextEditingController controller, FocusNode focusNode, int index) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: Container(
        width: 60,
        height: 100,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(4),
          boxShadow: [
            BoxShadow(
              color: Colors.black45,
              offset: Offset(2, 2),
              blurRadius: 4,
            ),
          ],
        ),
        child: TextField(
          controller: controller,
          focusNode: focusNode,
          keyboardType: TextInputType.number,
          style: TextStyle(
            fontSize: 36,
            color: Colors.greenAccent,
            fontFamily: 'Digital', // Ensure you have a digital-style font
          ),
          textAlign: TextAlign.center,
          decoration: InputDecoration(
            border: InputBorder.none,
          ),
          onChanged: (value) => _handleTextChanged(controller, value, index),
        ),
      ),
    );
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var focusNode in _focusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ...List.generate(3, (index) => _buildDigitalTube(_controllers[index], _focusNodes[index], index)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0),
          child: Text(
            '.',
            style: TextStyle(
              fontSize: 36,
              color: Colors.white,
            ),
          ),
        ),
        _buildDigitalTube(_controllers[3], _focusNodes[3], 3),
      ],
    );
  }
}
