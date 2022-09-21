import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flame/game.dart';
import 'package:flame/gestures.dart';
import 'package:flame/sprite.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:ship_head/Game/enemy.dart';
import 'package:ship_head/Game/enemy_manager.dart';
import 'package:ship_head/Game/game_size.dart';
import 'package:ship_head/Game/player.dart';

class GameWorld extends BaseGame with PanDetector {
  late Player player;
  Offset? _pointerStartPosition;
  Offset? _pointerCurrentPosition;

  final double joyStickRadius = 60;
  final double _joyStickInnerRadius = 20;
  @override
  Future<void> onLoad() async {
    const spreadsheetFileName = "simpleSpace_sheet@2.png";
    await images.load(spreadsheetFileName);
    final spriteSheet = SpriteSheet.fromColumnsAndRows(
        image: images.fromCache(spreadsheetFileName), columns: 9, rows: 6
    );
    player = Player(
      sprite: spriteSheet.getSpriteById(0),
      size: Vector2(64, 64),
      position: viewport.canvasSize / 2,
    );
    player.anchor = Anchor.center;
    add(player);

    EnemyManager enemyManager = EnemyManager(spriteSheet: spriteSheet);
    add(enemyManager );
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
  }

  @override
  void onPanStart(DragStartDetails details) {
    _pointerStartPosition = details.globalPosition;
    _pointerCurrentPosition = details.globalPosition;
  }
  @override
  void onPanUpdate(DragUpdateDetails details) {
    _pointerCurrentPosition = details.globalPosition;
    var delta = _pointerCurrentPosition! - _pointerStartPosition!;
    if (delta.distance > 10 ) {
      //deadzone of the joystick
      player.setMoveDirection(Vector2(delta.dx, delta.dy));
    } else {
      player.setMoveDirection(Vector2.zero());
    }
  }
  @override
  void onPanEnd(DragEndDetails details) {
    _pointerStartPosition = null;
    _pointerCurrentPosition = null;
    player.setMoveDirection(Vector2.zero());// after letting go set direction to 0
  }
  @override
  void onPanCancel() {
    _pointerStartPosition = null;
    _pointerCurrentPosition = null;
    player.setMoveDirection(Vector2.zero());
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
}