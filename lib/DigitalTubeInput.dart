import 'package:flutter/material.dart';
import 'package:my_app/DigitalTubeInputController.dart';

class DigitalTubeInput extends StatefulWidget {
  final Function(int) onNumberChanged;
  final DigitalTubeInputController controller;

  DigitalTubeInput(
      {Key? key, required this.onNumberChanged, required this.controller})
      : super(key: key);

  @override
  DigitalTubeInputState createState() => DigitalTubeInputState();
}

class DigitalTubeInputState extends State<DigitalTubeInput> {
  final List<TextEditingController> _controllers =
      List.generate(4, (index) => TextEditingController(text: '0'));
  final List<FocusNode> _focusNodes = List.generate(4, (index) => FocusNode());

  @override
  void initState() {
    super.initState();
    // Delaying the attachment to ensure the widget is fully created.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        widget.controller.attach(this);
        print("Controller attached.");
      }
    });
  }

  @override
  void dispose() {
    widget.controller.detach();
    _controllers.forEach((controller) => controller.dispose());
    _focusNodes.forEach((focusNode) => focusNode.dispose());
    super.dispose();
  }

  int getCombinedNumber() {
    return _controllers.fold(0,
        (prev, controller) => prev * 10 + (int.tryParse(controller.text) ?? 0));
  }

  void resetDigits() {
    // print("Resetting digits...");
    setState(() {
      _controllers.forEach((controller) => controller.text = '0');
    });
    widget.onNumberChanged(0);
  }

  void _handleTextChanged(String value, int index) {
    final controller = _controllers[index];
    final cursorPosition = controller.selection.baseOffset;
    print(cursorPosition);

    if (value.isEmpty) {
      controller.text = '0';
    } else if (cursorPosition == 1) {
      // 光标在输入框开头,直接使用前面的值
      print(cursorPosition);
      print(value.substring(0,1));
      controller.text = value.substring(0,1);
    } else if (value.length > 1) {
      // 光标在输入框中间或结尾,截取最后一个字符
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

  Widget _buildDigitalTube(int index) {
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
          controller: _controllers[index],
          focusNode: _focusNodes[index],
          keyboardType: TextInputType.number,
          style: TextStyle(
            fontSize: 36,
            color: Colors.greenAccent,
            fontFamily:
                'Digital', // Make sure you have this font in your assets
          ),
          textAlign: TextAlign.center,
          decoration: InputDecoration(
            border: InputBorder.none,
          ),
          onChanged: (value) => _handleTextChanged(value, index),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ...List.generate(3, (index) => _buildDigitalTube(index)),
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
        _buildDigitalTube(3),
      ],
    );
  }
}
