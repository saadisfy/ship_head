import 'dart:async';

import 'package:esense_flutter/esense.dart';
import 'package:flame/components.dart';
import 'package:flutter/scheduler.dart';
import 'package:ship_head/Game/player.dart';

import 'command.dart';
import 'gameWorld.dart';
import 'package:ship_head/esense_functionality.dart';

class EsenseStuff with HasGameRef<GameWorld>{
  final ESenseManager eSenseManager = ESenseManager();
  final deviceName = "eSense-0278";
  Future<void> script() async {


  }
  Future<void> _connectToESense() async {

    await eSenseManager.disconnect();
    /// first listen to connection events before trying to connect
    eSenseManager.connectionEvents.listen((event) {
      print('CONNECTION event: $event');

      if (event.type == ConnectionType.device_not_found) {
        for(int i = 0; i< 10 ; i++) {
          print (i);
        }
        print("try connecting again");
        eSenseManager.connect(deviceName);
      }
      if (event.type == ConnectionType.disconnected) {
        print("disconnected so we will try connect again");
        eSenseManager.connect(deviceName);
      }

      if (event.type == ConnectionType.connected) {
        print("Finally connected");

       ESenseManager().eSenseEvents.listen((event) {
          print("e sense Events $event");
        });
        ESenseManager().sensorEvents.listen((event) {
          print('SENSOR event234523523452345: $event');
          print("double try");
          print(_handleGyro(event));
        });


      }

    });

    eSenseManager.connect(deviceName);

    /*print("BATTERY VOLTAGE ${await eSenseManager.getBatteryVoltage()}");
    // set up a event listener
    eSenseManager.eSenseEvents.listen((event) {
      print("other Events $event");

    });
    eSenseManager.sensorEvents.listen((event) {
      print('ESENSE event: $event');
      print(_handleAccel(event));
      print(_handleGyro(event));
    });*/
  }
  List<double> _handleAccel(SensorEvent event) {
    if (event.accel != null) {
      return [
        event.accel![0].toDouble(),
        event.accel![1].toDouble(),
        event.accel![2].toDouble(),
      ];
    } else {
      return [0.0, 0.0, 0.0];
    }
  }

  List<double> _handleGyro(SensorEvent event) {
    if (event.gyro != null) {

      /*final command = Command<Player>(action: (player) {
        player.setMoveDirection(Vector2(event.gyro![2].toDouble() / 500, 0));
      });
      gameRef.addCommand(command);*/
      return [
        event.gyro![0].toDouble(),
        event.gyro![1].toDouble(),
        event.gyro![2].toDouble(),
      ];
    } else {
      return [0.0, 0.0, 0.0];
    }
  }

}