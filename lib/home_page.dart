import 'package:flutter/material.dart';
import 'package:my_app/animated_knob_button.dart';
import 'package:provider/provider.dart';

import 'calculator_provider.dart';
import 'animated_text_field.dart';
import 'animated_dropdown_button.dart';
import 'animated_text_display.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF7F9F9),
      appBar: AppBar(
        title: Text(
          'Thermal Relay Calculator',
          style: TextStyle(
            fontFamily: 'Roboto',
            fontWeight: FontWeight.w400,
            fontSize: 22,
          ),
        ),
        backgroundColor: Color(0xFF4E6C50),
        elevation: 0,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Card(
                elevation: 5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: AnimatedTextField(
                    labelText: 'Enter X Value',
                    onChanged: (value) {
                      context.read<CalculatorProvider>().updateXValue(double.parse(value));
                    },
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
            Expanded(
              child: Card(
                elevation: 5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: AnimatedDropdownButton(
                    labelText: 'Select Contactor Amperage',
                    items: [
                      DropdownMenuItem(value: 9, child: Text('9A')),
                      DropdownMenuItem(value: 12, child: Text('12A')),
                      DropdownMenuItem(value: 18, child: Text('18A')),
                      DropdownMenuItem(value: 25, child: Text('25A')),
                      DropdownMenuItem(value: 32, child: Text('32A')),
                      // Add more options as needed
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        context.read<CalculatorProvider>().updateContactorAmperage(value);
                      }
                    },
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
            Expanded(
              child: Card(
                elevation: 5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: AnimatedTextDisplay(
                    text: '${context.watch<CalculatorProvider>().minThermalRelayCurrentRange.toStringAsFixed(2)} - ${context.watch<CalculatorProvider>().maxThermalRelayCurrentRange.toStringAsFixed(2)} A',
                  ),
                ),
              ),
            ),
          SizedBox(height: 20),
          Expanded(child: AmmeterWidget(
            scaleValues:[0,20,40,60,100,120,140,160,180,200]
          ))
          ],
        ),
      ),
    );
  }
}
