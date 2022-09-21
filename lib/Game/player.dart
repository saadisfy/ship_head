import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:ship_head/Game/game_size.dart';

class Player extends SpriteComponent with GameSize{
  Vector2 _moveDirection = Vector2.zero();
  double _speed = 200;

  Player({
    Sprite? sprite,
    Vector2? position,
    Vector2? size,
  }): super(sprite: sprite, position: position, size: size);

  @override
  void update(double dt) {
    super.update(dt);
    position += _moveDirection.normalized() * _speed * dt;
    position.clamp(
        Vector2.zero() + size / 2,
        // without adjustment trough size , part of player would go outside of boarder
        gameSize - size / 2
    ); //boundaries for the player
  }
  void setMoveDirection (Vector2 newMoveDirection) {
    _moveDirection = newMoveDirection;
  }
}