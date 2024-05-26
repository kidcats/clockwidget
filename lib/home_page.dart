import 'package:flutter/material.dart';
import 'package:my_app/DigitalTubeInput.dart';
import 'package:my_app/DigitalTubeInputController.dart';
import 'package:provider/provider.dart';
import 'package:my_app/animated_knob_button.dart';
import 'package:window_manager/window_manager.dart';
import 'calculator_provider.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WindowListener {
  int _integerPart = 0;
  int _decimalPart = 0;
      double _combinedNumber = 0;
     final DigitalTubeInputController controller = DigitalTubeInputController();


  @override
  void initState() {
    super.initState();
    windowManager.addListener(this);
  }

  @override
  void dispose() {
    windowManager.removeListener(this);
    super.dispose();
  }

  void _updateIntegerPart(BuildContext context, double value) {
    final provider = Provider.of<CalculatorProvider>(context, listen: false);
    setState(() {
      _integerPart = value.toInt();
      if (_integerPart > 200) {
        _integerPart = 200;
      }
      provider.updateXValue(_integerPart + _decimalPart / 10.0);
    });
  }

  void _updateDecimalPart(BuildContext context, double value) {
    final provider = Provider.of<CalculatorProvider>(context, listen: false);
    setState(() {
      if (_integerPart < 200) {
        _decimalPart = value.toInt();
      }
      provider.updateXValue(_integerPart + _decimalPart / 10.0);
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<CalculatorProvider>(context);
    final size = MediaQuery.of(context).size;

    void updateCombinedNumber(int number) {
      setState(() {
        _combinedNumber = number / 10;
      });
    }

    void resetDigitalTubes() {
      setState(() {
        _combinedNumber = 0;
      });
    }

    // Define icon and text sizes
    final double iconsize = 40;
    final double signalsize = 22;
    final double resultsize = 50;

    return Scaffold(
      appBar: AppBar(
        title: Text('开始使用'),
        centerTitle: true,
        backgroundColor: Colors.blue.shade800,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue.shade400, Colors.blue.shade900],
          ),
        ),
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            double circleDiameter = constraints.maxHeight * 0.4;
            return Column(
              children: [
                SizedBox(height: 30),
                ElevatedButton(
                  onPressed: () => { controller.resetDigits()},
                  child: Text(
                    '重置',
                    style: TextStyle(
                      fontSize: 24,
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Center(
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Container(
                              width: circleDiameter,
                              height: circleDiameter,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white.withOpacity(0.1),
                                border: Border.all(
                                  color: Colors.white,
                                  width: 4,
                                ),
                              ),
                            ),
                            Container(
                              height: circleDiameter * 0.8,
                              child: AmmeterWidget(
                                scaleValues: [
                                  0,
                                  20,
                                  40,
                                  60,
                                  100,
                                  120,
                                  140,
                                  160,
                                  180,
                                  200
                                ],
                                onValueChanged: (value) {
                                  _updateIntegerPart(context, value);
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(width: 20),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        DigitalTubeInput(onNumberChanged: updateCombinedNumber,controller: controller,),
                        SizedBox(height: 20),
                        Text(
                          'Combined Number: $_combinedNumber',
                          style: TextStyle(fontSize: 24),
                        ),
                      ],
                    ),
                    SizedBox(width: 20),
                    Expanded(
                      child: Center(
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Container(
                              width: circleDiameter,
                              height: circleDiameter,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white.withOpacity(0.1),
                                border: Border.all(
                                  color: Colors.white,
                                  width: 4,
                                ),
                              ),
                            ),
                            Container(
                              height: circleDiameter * 0.8,
                              child: AmmeterWidget(
                                scaleValues: [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10],
                                onValueChanged: (value) {
                                  _updateDecimalPart(context, value);
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 50),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Expanded(
                        child: Card(
                            color: Colors.blue.shade100,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15.0),
                            ),
                            elevation: 5,
                            child: SizedBox(
                              height: circleDiameter * 0.6,
                              child: Padding(
                                padding: EdgeInsets.symmetric(horizontal: 20),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.electrical_services,
                                            size: iconsize,
                                            color: Colors.blue.shade900),
                                        SizedBox(width: 10),
                                        Text(
                                          '接触器电流数值',
                                          style: TextStyle(
                                            fontSize: signalsize,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.blue.shade900,
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 20),
                                    Text(
                                      '${provider.contactorAmperage}A',
                                      style: TextStyle(
                                        fontSize: resultsize,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blue.shade900,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Card(
                            color: Colors.blue.shade50,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15.0),
                            ),
                            elevation: 5,
                            child: SizedBox(
                              height: circleDiameter * 0.6,
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 30),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.settings_applications,
                                            size: iconsize,
                                            color: Colors.blue.shade900),
                                        const SizedBox(width: 10),
                                        Text(
                                          '热继电器整定电流',
                                          style: TextStyle(
                                            fontSize: signalsize,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.blue.shade900,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 20),
                                    Text(
                                      '${provider.minThermalRelayCurrentRange.toStringAsFixed(1)} ~ ${provider.maxThermalRelayCurrentRange.toStringAsFixed(1)}A',
                                      style: TextStyle(
                                        fontSize: resultsize,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blue.shade900,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  @override
  void onWindowEvent(String eventName) {
    print('[WindowManager] onWindowEvent: $eventName');
  }

  @override
  void onWindowClose() {
    // do something
  }

  @override
  void onWindowFocus() {
    // do something
  }

  @override
  void onWindowBlur() {
    // do something
  }

  @override
  void onWindowMaximize() {
    // do something
  }

  @override
  void onWindowUnmaximize() {
    // do something
  }

  @override
  void onWindowMinimize() {
    // do something
  }

  @override
  void onWindowRestore() {
    // do something
  }

  @override
  void onWindowResize() {
    // do something
  }

  @override
  void onWindowMove() {
    // do something
  }

  @override
  void onWindowEnterFullScreen() {
    // do something
  }

  @override
  void onWindowLeaveFullScreen() {
    // do something
  }

  Widget _buildDigitalTube(int number) {
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
        child: Text(
          number.toString(),
          style: TextStyle(
            fontSize: 36,
            color: Colors.greenAccent,
            fontFamily: 'Digital', // Ensure you have a digital-style font
          ),
        ),
      ),
    );
  }
}
