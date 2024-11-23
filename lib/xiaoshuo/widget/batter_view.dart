import 'dart:async';

import 'package:ZY_Player_flutter/res/colors.dart';
import 'package:battery_plus/battery_plus.dart';
import 'package:flutter/material.dart';

class BatteryView extends StatefulWidget {
  const BatteryView({Key? key}) : super(key: key);

  @override
  _BatteryViewState createState() => _BatteryViewState();
}

class _BatteryViewState extends State<BatteryView> {
  double batteryLevel = 0;

  Timer? _timer;

  @override
  void initState() {
    super.initState();

    _timer = Timer.periodic(const Duration(seconds: 10), (timer) {
      getBatteryLevel();
    });
    getBatteryLevel();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  getBatteryLevel() async {
    var level = await Battery().batteryLevel;
    setState(() {
      batteryLevel = level / 100.0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 27,
      height: 12,
      child: Stack(
        children: <Widget>[
          Image.asset('assets/images/book/reader_battery.png'),
          Container(
            margin: const EdgeInsets.fromLTRB(2, 2, 2, 2),
            width: 20 * batteryLevel,
            color: Colours.app_main,
          ),
          Center(
            child: Text("${(batteryLevel * 100).toInt()}%", style: const TextStyle(color: Colors.white60, fontSize: 8)),
          )
        ],
      ),
    );
  }
}
