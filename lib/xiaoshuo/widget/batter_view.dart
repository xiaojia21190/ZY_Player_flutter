import 'package:ZY_Player_flutter/res/colors.dart';
import 'package:flutter/material.dart';
import 'package:battery/battery.dart';

class BatteryView extends StatefulWidget {
  @override
  _BatteryViewState createState() => _BatteryViewState();
}

class _BatteryViewState extends State<BatteryView> {
  double batteryLevel = 0;

  @override
  void initState() {
    super.initState();

    getBatteryLevel();
  }

  getBatteryLevel() async {
    var level = await Battery().batteryLevel;
    setState(() {
      this.batteryLevel = level / 100.0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 27,
      height: 12,
      child: Stack(
        children: <Widget>[
          Image.asset('assets/images/book/reader_battery.png'),
          Container(
            margin: EdgeInsets.fromLTRB(2, 2, 2, 2),
            width: 20 * batteryLevel,
            color: Colours.golden,
          )
        ],
      ),
    );
  }
}
