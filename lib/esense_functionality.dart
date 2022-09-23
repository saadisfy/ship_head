import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:esense_flutter/esense.dart';
import 'package:ship_head/Game/gameWorld.dart';

import 'Game/command.dart';
import 'Game/player.dart';

/*
 Saads SENSOR event, the avg of x is : 62.03
I/flutter (17813): Saads SENSOR event, the avg of y is : -54.16
I/flutter (17813): Saads SENSOR event, the avg of z is : -325.35333333333335
 */

class ESenseFunctionality with HasGameRef<GameWorld>{
  static int amount = 0;
  static double sumX = 0, sumY= 0, sumZ=0;
  static double avgX= 1, avgY = 1, avgZ=0;
  static String deviceName = 'Unknown';
  static double voltage = -1;
  static String deviceStatus = '';
  static bool sampling = false;
  static String eventString = '';
  static String button = 'not pressed';
  static int zAxis = 0;
  static double zAxisCalculated = 0;

  static double currentXGyro = 0;
  static double currentYGyro = 0;
  static double currentZGyro = 0;
  List<double> listXGyro = List<double>.empty(growable: true);
  List<double> listYGyro = List<double>.empty(growable: true);
  List<double> listZGyro = List<double>.empty(growable: true);


  // the name of the eSense device to connect to -- change this to your own device.
  static String eSenseName = 'eSense-0278';

  static Future<void> connectToESense() async {
    bool con = false;

    // if you want to get the connection events when connecting, set up the listener BEFORE connecting...
    ESenseManager().connectionEvents.listen((event) {
      print('CONNECTION event: $event');

      // when we're connected to the eSense device, we can start listening to events from it
      if (event.type == ConnectionType.connected) listenToESenseEvents();

      switch (event.type) {
        case ConnectionType.connected:
          deviceStatus = 'connected';
          break;
        case ConnectionType.unknown:
          deviceStatus = 'unknown';
          break;
        case ConnectionType.disconnected:
          deviceStatus = 'disconnected';
          break;
        case ConnectionType.device_found:
          deviceStatus = 'device_found';
          break;
        case ConnectionType.device_not_found:
          deviceStatus = 'device_not_found';
          break;
      }
    });

    con = await ESenseManager().connect(eSenseName);

    deviceStatus = con ? 'connecting' : 'connection failed';
  }

  static void listenToESenseEvents() async {
    ESenseManager().eSenseEvents.listen((event) {
      print('ESENSE event: $event');

      switch (event.runtimeType) {
        case DeviceNameRead:
          deviceName = (event as DeviceNameRead).deviceName!;
          break;
        case BatteryRead:
          voltage = (event as BatteryRead).voltage!;
          break;
        case ButtonEventChanged:
          button =
          (event as ButtonEventChanged).pressed ? 'pressed' : 'not pressed';
          break;
        case AccelerometerOffsetRead:
        // TODO
          break;
        case AdvertisementAndConnectionIntervalRead:
        // TODO
          break;
        case SensorConfigRead:
        // TODO
          break;
      }
    });

    //getESenseProperties();
  }

  /*static void getESenseProperties() async {
    // get the battery level every 10 secs
    Timer.periodic(Duration(seconds: 10),
            (timer) async => await ESenseManager().getBatteryVoltage());

    // wait 2, 3, 4, 5, ... secs before getting the name, offset, etc.
    // it seems like the eSense BTLE interface does NOT like to get called
    // several times in a row -- hence, delays are added in the following calls
    Timer(
        Duration(seconds: 2), () async => await ESenseManager().getDeviceName());
    Timer(Duration(seconds: 3),
            () async => await ESenseManager().getAccelerometerOffset());
    Timer(
        Duration(seconds: 4),
            () async =>
        await ESenseManager().getAdvertisementAndConnectionInterval());
    Timer(Duration(seconds: 5),
            () async => await ESenseManager().getSensorConfig());
  }*/

  static StreamSubscription? subscription;
  static void startListenToSensorEvents() async {
    // subscribe to sensor event from the eSense device
    subscription = ESenseManager().sensorEvents.listen((event) {
      //print('Saads SENSOR event: $event');
      if ( amount < 300) {
        if (amount % 10 == 0) print("current amount $amount");
        amount++;
        sumX+=event.gyro![0].toDouble();
        sumY+=event.gyro![1].toDouble();
        sumZ+=event.gyro![2].toDouble();

      } else {
        avgX = sumX / amount;
        avgY = sumY / amount;
        avgZ = sumZ / amount;

        print('Saads SENSOR event, the avg of x is : $avgX'); // x = 100, handy richtung kopf
        print('Saads SENSOR event, the avg of y is : $avgY'); // x = 100, handy richtung kopf
        print('Saads SENSOR event, the avg of z is : $avgZ'); // x = 100, handy richtung kopf

        amount = 0;
        sumX = 0; sumY=0; sumZ=0;
        avgX = 1; avgY=1; avgZ=1;

      }
      currentXGyro = event.gyro![0].toDouble();
      currentYGyro = event.gyro![1].toDouble();
      currentZGyro = event.gyro![2].toDouble();

    });
    sampling = true;
  }

  static void pauseListenToSensorEvents() {
    subscription?.cancel();
    sampling = false;
  }

  static void dispose() {
    pauseListenToSensorEvents();
    ESenseManager().disconnect();
    //super.dispose();
  }
}