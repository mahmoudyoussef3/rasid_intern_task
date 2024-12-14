import 'package:flutter/material.dart';
import 'package:one_clock/one_clock.dart';
class ShowAnalogClock extends StatelessWidget {
  const ShowAnalogClock({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      child: AnalogClock(
        digitalClockColor: Colors.white,
        tickColor: Colors.white,
        secondHandColor: Colors.white,
        decoration: BoxDecoration(
          border: Border.all(width: 2.0, color: Colors.blue[800]!),
          color: Colors.transparent,
          shape: BoxShape.circle,
        ),
        width: 150.0,
        isLive: true,
        hourHandColor: Colors.blue[800]!,
        minuteHandColor: Colors.blue[800]!,
        showSecondHand: true,
        numberColor: Colors.blue[800]!,
        showNumbers: true,
        showAllNumbers: true,
        showTicks: true,
        showDigitalClock: true,
        datetime: DateTime.now(),
      ),
    );
  }
}
