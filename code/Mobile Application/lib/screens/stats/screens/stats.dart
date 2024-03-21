import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sm_iot_lab/constants/colors.dart';
import 'package:sm_iot_lab/mqtt/mqtt_service.dart';

class Stats extends StatefulWidget {
  const Stats({super.key});

  @override
  State<Stats> createState() => _StatsState();
}

class _StatsState extends State<Stats>
    with AutomaticKeepAliveClientMixin<Stats> {
  bool _scanner0Up = false;
  bool _scanner1Up = false;
  bool _pickupPoint0Up = false;
  bool _pickupPoint1Up = false;

  late StreamSubscription<ComponentStatusMessage> _componentStatusSubscription;

  @override
  void initState() {
    super.initState();

    var statuses = MQTTService.getLastComponentStatusMessages();
    for (var stat in statuses) {
      switch (stat.type) {
        case ComponentType.scanner:
          if (stat.position == 0) {
            setState(() {
              _scanner0Up = stat.message == "up";
            });
          }
          if (stat.position == 1) {
            setState(() {
              _scanner1Up = stat.message == "up";
            });
          }
          break;
        case ComponentType.pickupPoint:
          if (stat.position == 0) {
            setState(() {
              _pickupPoint0Up = stat.message == "up";
            });
          }
          if (stat.position == 1) {
            setState(() {
              _pickupPoint1Up = stat.message == "up";
            });
          }
          break;
        default:
      }
    }

    _componentStatusSubscription =
        MQTTService.componentsStatus.stream.asBroadcastStream().listen((event) {
      bool isUp = event.message == "up";
      setState(() {
        switch (event.type) {
          case ComponentType.scanner:
            if (event.position == 0) {
              setState(() {
                _scanner0Up = isUp;
              });
            }
            if (event.position == 1) {
              setState(() {
                _scanner1Up = isUp;
              });
            }
            break;
          case ComponentType.pickupPoint:
            if (event.position == 0) {
              setState(() {
                _pickupPoint0Up = isUp;
              });
            }
            if (event.position == 1) {
              setState(() {
                _pickupPoint1Up = isUp;
              });
            }
            break;
          default:
        }
      });
    });
  }

  @override
  void dispose() {
    _componentStatusSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: AppColors.bgGray,
            ),
            height: ScreenUtil().setHeight(60),
            padding: const EdgeInsets.only(left: 20, right: 20),
            margin: const EdgeInsets.only(bottom: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Cube Scanner 1",
                  style: TextStyle(
                    fontSize: ScreenUtil().setSp(20),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  _scanner0Up ? "up" : "down",
                  style: TextStyle(
                    fontSize: ScreenUtil().setSp(18),
                    fontWeight: FontWeight.w500,
                    color: _scanner0Up ? Colors.green : Colors.red,
                  ),
                ),
              ],
            ),
          ),
          // Container(
          //   decoration: BoxDecoration(
          //     borderRadius: BorderRadius.circular(10),
          //     color: AppColors.bgGray,
          //   ),
          //   height: ScreenUtil().setHeight(60),
          //   padding: const EdgeInsets.only(left: 20, right: 20),
          //   margin: const EdgeInsets.only(bottom: 20),
          //   child: Row(
          //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //     children: [
          //       Text(
          //         "Scanner 1",
          //         style: TextStyle(
          //           fontSize: ScreenUtil().setSp(20),
          //           fontWeight: FontWeight.w500,
          //         ),
          //       ),
          //       Text(
          //         _scanner1Up ? "up" : "down",
          //         style: TextStyle(
          //           fontSize: ScreenUtil().setSp(18),
          //           fontWeight: FontWeight.w500,
          //           color: _scanner1Up ? Colors.green : Colors.red,
          //         ),
          //       ),
          //     ],
          //   ),
          // ),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: AppColors.bgGray,
            ),
            height: ScreenUtil().setHeight(60),
            padding: const EdgeInsets.only(left: 20, right: 20),
            margin: const EdgeInsets.only(bottom: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Pickup Point 0",
                  style: TextStyle(
                    fontSize: ScreenUtil().setSp(20),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  // _pickupPoint0Up ? "up" : "down",
                  "up",
                  style: TextStyle(
                    fontSize: ScreenUtil().setSp(18),
                    fontWeight: FontWeight.w500,
                    // color: _pickupPoint0Up ? Colors.green : Colors.red,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: AppColors.bgGray,
            ),
            height: ScreenUtil().setHeight(60),
            padding: const EdgeInsets.only(left: 20, right: 20),
            margin: const EdgeInsets.only(bottom: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Pickup Point 1",
                  style: TextStyle(
                    fontSize: ScreenUtil().setSp(20),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  // _pickupPoint1Up ? "up" : "down",
                  "up",
                  style: TextStyle(
                    fontSize: ScreenUtil().setSp(18),
                    fontWeight: FontWeight.w500,
                    // color: _pickupPoint1Up ? Colors.green : Colors.red,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
