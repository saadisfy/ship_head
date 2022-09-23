
import 'dart:async';
import 'dart:async';
import 'dart:async';
import 'dart:collection';

import 'package:esense_flutter/esense.dart';
import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flame/game.dart';
import 'package:flame/gestures.dart';
import 'package:flame/sprite.dart';
import 'package:flutter/material.dart';
import 'package:ship_head/Game/enemy_manager.dart';
import 'package:ship_head/Game/esenseStuff.dart';
import 'package:ship_head/Game/game_size.dart';
import 'package:ship_head/Game/player.dart';
import 'package:ship_head/esense_functionality.dart';
import 'command.dart';

class GameWorld extends BaseGame with PanDetector, HasCollidables {
  late Player _player;
  late EnemyManager enemyManager;
  Offset? _pointerStartPosition;
  Offset? _pointerCurrentPosition;
  final double joyStickRadius = 60;
  final double _joyStickInnerRadius = 20;

  late TextComponent _playerScore;
  late TextComponent _playerHealth;

  final _commandList = List<Command>.empty(growable: true);
  final _addLaterCommandList = List<Command>.empty(growable: true); //while the first List is processed new Comands are added to this list
  @override
  Future<void> onLoad() async {
    await ESenseFunctionality.connectToESense();
    const spreadsheetFileName = "simpleSpace_sheet@2.png";
    camera.shakeIntensity = 10;
    await images.load(spreadsheetFileName);
    final spriteSheet = SpriteSheet.fromColumnsAndRows(
        image: images.fromCache(spreadsheetFileName), columns: 9, rows: 6
    );
    _player = Player(
      sprite: spriteSheet.getSpriteById(0),
      size: Vector2(64, 64),
      position: viewport.canvasSize / 2,
    );
    _player.anchor = Anchor.center;
    add(_player);

    enemyManager = EnemyManager(spriteSheet: spriteSheet);
    add(enemyManager );

    _playerScore = TextComponent(
      'Score: 0',
      position: Vector2(10,10),
      config: TextConfig(color: Colors.white, fontSize: 16),
    );
    add(_playerScore);


    _playerHealth = TextComponent(
      'Health: 100%',
      position: Vector2(size.x-10,10),
      config: TextConfig(color: Colors.white, fontSize: 16),
    );
    _playerHealth.anchor = Anchor.topRight;
    add(_playerHealth);
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    //draw Joystick outer circle
    if (_pointerStartPosition != null) {
      //user touching the screen
      canvas.drawCircle(
          _pointerStartPosition!,
          joyStickRadius,
          Paint()..color= Colors.grey.withAlpha(100)
      );
    }
    //draw joystick inner circle
    if (_pointerCurrentPosition != null && _pointerStartPosition!= null) {
      var delta =  _pointerCurrentPosition! - _pointerStartPosition!;
      if (delta.distance > joyStickRadius) {
        delta = (_pointerStartPosition! +
            (Vector2(delta.dx, delta.dy).normalized() * joyStickRadius).toOffset());
      } else {
        delta = _pointerCurrentPosition!;
      }
      canvas.drawCircle(
          delta,
          _joyStickInnerRadius,
          Paint()..color= Colors.white.withAlpha(100)
      );
    }

    canvas.drawRect(Rect.fromLTWH(size.x-100, 10, _player.health.toDouble(), 20 ), Paint()..color = Colors.blue.withAlpha(3000));


  }



  @override
  void update(double dt) {
    super.update(dt);
    /*x = 62.03
    I/flutter (17813): Saads SENSOR event, the avg of y is : -54.16
    I/flutter (17813): Saads SENSOR event, the avg of z is : -325.35333333333335*/

    double x = 0;
    double y = 0;
    double percentage = 1;
    if (- 300 < ESenseFunctionality.currentXGyro &&  ESenseFunctionality.currentXGyro < 400) {
      x = 0;
      //_player.setMoveDirection(Vector2.zero());
    } else {
      x = (ESenseFunctionality.currentXGyro - 62.5) * percentage;
      //_player.setMoveDirection(Vector2(ESenseFunctionality.currentXGyro, 0));
    }
    if (- 1000 < ESenseFunctionality.currentZGyro &&  ESenseFunctionality.currentZGyro < 1000) {
      y = 0;
      //_player.setMoveDirection(Vector2.zero());
    } else {
      y =  (ESenseFunctionality.currentZGyro - 1.35333333333) * percentage;
      //_player.setMoveDirection(Vector2(0, - ESenseFunctionality.currentYGyro));
    }
    _player.setMoveDirection(Vector2(x, y ));

    _commandList.forEach((command) {
      components.forEach((component) {
        command.run(component);
      });
    });
    _commandList.clear(); //after done with processing all commands, clear the list
    _commandList.addAll(_addLaterCommandList);
    _addLaterCommandList.clear();

    _playerScore.text = 'Score: ${_player.score}';
    _playerHealth.text = 'Health: ${_player.health}';


  }
  @override
  void onPanStart(DragStartDetails details) {
    _pointerStartPosition = details.globalPosition;
    _pointerCurrentPosition = details.globalPosition;
  }
  @override
  void onPanUpdate(DragUpdateDetails details) {
    if (ESenseFunctionality.deviceStatus == 'connected' ) {
      if (!ESenseFunctionality.sampling) {
        print ("start listening");
        ESenseFunctionality.startListenToSensorEvents();
      } else {
        print("already listening");
      }

    } else {
      print("not connected yet");
    }

    _pointerCurrentPosition = details.globalPosition;
    var delta = _pointerCurrentPosition! - _pointerStartPosition!;
    if (delta.distance > 10 ) {
      //dead-zone of the joystick
      _player.setMoveDirection(Vector2(delta.dx, delta.dy));
    } else {
      _player.setMoveDirection(Vector2.zero());
    }
  }
  @override
  void onPanEnd(DragEndDetails details) {
    _pointerStartPosition = null;
    _pointerCurrentPosition = null;
    _player.setMoveDirection(Vector2.zero());// after letting go set direction to 0
  }
  @override
  void onPanCancel() {
    _pointerStartPosition = null;
    _pointerCurrentPosition = null;
    _player.setMoveDirection(Vector2.zero());
  }

  @override
  void prepare(Component c) {
    super.prepare(c);
    if (c is GameSize) {
      c.onResize(size);
    }
  }

  @override
  void onResize(Vector2 canvasSize) {
    super.onResize(canvasSize);
    //updates all components with Game Size  mixin everytime Game size is updated
    components.whereType<GameSize>().forEach((element) {
      element.onResize(size);
    });
  }

  void addCommand(Command command) {
    _addLaterCommandList.add(command);
  }
}