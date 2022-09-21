import 'dart:math';

import 'package:flame/components.dart';
import 'package:ship_head/Game/game_size.dart';

class Enemy extends SpriteComponent with GameSize {
  final double _speed = 300;

  Enemy({
    Sprite? sprite,
    Vector2? position,
    Vector2? size,
  }): super(sprite: sprite, position: position, size: size) {
    //todo currently enemy are only going dopDown, for later they will come from any direction, so this needs to be adjusted depending on the spawn position
    angle = pi; //180 degrees, which will rotate downwards
  }

  @override
  void update(double dt) {
    // TODO: implement update
    position +=  Vector2(0,1) * _speed * dt; //vector(0,1): movement is from top to bottom


    if ((position.y > gameSize.y || position.y < 0) ||
        (position.x > gameSize.x || position.x < 0)) {
      //if enemy leaves the borders, remove it
      remove();
    }
  }
  @override
  void onRemove() {
    super.onRemove();
  }


}