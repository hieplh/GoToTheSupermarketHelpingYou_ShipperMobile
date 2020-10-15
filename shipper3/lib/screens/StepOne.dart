import 'package:flutter/material.dart';
import 'package:shipper3/screens/Location.dart';
import 'package:steps_indicator/steps_indicator.dart';
import 'Camera.dart';

import 'ListCheck.dart';

class StepOne extends StatefulWidget {
  @override
  _StepOneState createState() => _StepOneState();
}

class _StepOneState extends State<StepOne> {
  int currentStep = 0;
  List<Step> steps = [
    Step(
        title: Text(
          'Đi chợ',
          style: TextStyle(fontSize: 18),
        ),
        content: Container(width: 300, height: 350, child: GPSLocation()),
        isActive: true),
    Step(
        title: Text('Giỏ Hàng'),
        content: Container(width: 250, height: 300, child: CheckList()),
        isActive: true),
    Step(
        title: Text('Giao Hàng'),
        content: Container(width: 300, height: 350, child: GPSLocation()),
        isActive: true),

  ];

  @override
  Widget build(BuildContext context) {
    //double c_width = MediaQuery.of(context).size.width*0.75;
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              child: Padding(
                padding: const EdgeInsets.all(0.0),
                child: Stepper(
                  currentStep: this.currentStep,
                  steps: steps,
                  type: StepperType.vertical,
                  onStepTapped: (steps) {
                    setState(() {
                      currentStep = steps;
                    });
                  },
                  onStepContinue: () {
                    setState(() {
                      if (currentStep < steps.length - 1) {
                        currentStep = currentStep + 1;
                      } else {
                        MaterialPageRoute(builder: (context) => PickerImage());
                      }
                    });
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
