import 'package:my_app/DigitalTubeInput.dart';

class DigitalTubeInputController {
  DigitalTubeInputState? _state;

  void attach(DigitalTubeInputState state) {
    _state = state;
  }

  void detach() {
    _state = null;
  }

  void resetDigits() {
    if (_state != null) {
      print("Controller: Resetting digits through state");
      _state!.resetDigits();
    } else {
      print("Controller: State not attached");
    }
  }
}
