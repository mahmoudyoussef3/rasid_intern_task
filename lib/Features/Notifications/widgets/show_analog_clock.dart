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
        secondHandColor: Colors.redAccent,
        decoration: BoxDecoration(
          border: Border.all(width: 2.0, color: Colors.white),
          color: Colors.transparent,
          shape: BoxShape.circle,
        ),
        width: 150.0,
        isLive: true,
        hourHandColor: Colors.white,
        minuteHandColor: Colors.white,
        showSecondHand: true,
        showNumbers: true,
        showAllNumbers: true,
        numberColor: Colors.white,
        showTicks: true,
        showDigitalClock: true,
        datetime: DateTime.now(),
      ),
    );
  }
}
