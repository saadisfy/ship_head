import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/sprite.dart';
import 'package:ship_head/Game/gameWorld.dart';
import 'package:ship_head/Game/game_size.dart';

import 'enemy.dart';

class EnemyManager extends BaseComponent with GameSize, HasGameRef<GameWorld>{
  late Timer timer; //to spawn the enemies in a fixed intervall
  SpriteSheet spriteSheet;
  final Random random = Random();

  EnemyManager({required this.spriteSheet}) : super() {
    timer = Timer(1, callback: _spawnEnemy, repeat: true);
  }

  void _spawnEnemy() {
    Vector2 initSize = Vector2(64, 64);
    Vector2 position = Vector2(random.nextDouble() * gameSize.x, 0);

    position.clamp(Vector2.zero(), gameSize - initSize /
        2); //clamp the randomness, so it will always spawn between the borders
    Enemy enemy = Enemy(
      sprite: spriteSheet.getSpriteById(2),
      size: initSize,
      position: position,
    );
    enemy.anchor = Anchor
        .center; //so that the starting position at the spawning doesn't go over the borders
    //instead of adding it as a child of enemy, they will be direct child of the game instance
    //the game instance checks for collisions, so the components need to be direct child
    gameRef?.add(enemy); //todo ensure gameRef is not null
  }

  @override
  void onMount() { // to init the component before its added to the game instance
    super.onMount();
    timer.start();
  }
  @override
  void onRemove(){
    super.onRemove();
    timer.stop();
  }

  @override
  void update(double dt) {
    super.update(dt);
    timer.update(dt);

  }

}

