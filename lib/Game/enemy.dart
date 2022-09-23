import 'dart:math';
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/geometry.dart';
import 'package:flame/particles.dart';
import 'package:flutter/material.dart';
import 'package:ship_head/Game/gameWorld.dart';
import 'package:ship_head/Game/game_size.dart';
import 'package:ship_head/Game/player.dart';

import 'command.dart';

class Enemy extends SpriteComponent
    with GameSize, Hitbox, Collidable, HasGameRef<GameWorld> {
  final double _speed = 300;

  Enemy({
    Sprite? sprite,
    Vector2? position,
    Vector2? size,
  }) : super(sprite: sprite, position: position, size: size) {
    //todo currently enemy are only going dopDown, for later they will come from any direction, so this needs to be adjusted depending on the spawn position
    angle = pi; //180 degrees, which will rotate downwards
  }

  @override
  void onMount() {
    super.onMount();
    final circleShape = HitboxCircle();
    addShape(circleShape);
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, Collidable other) {
    super.onCollision(intersectionPoints, other);

    if (other is Player) {
      final particleComponent = ParticleComponent(
          particle: Particle.generate(
              count: 30,
              lifespan: 0.1,
              generator: (i) => AcceleratedParticle(
                    acceleration: getRandomVector().toOffset(),
                    position: position
                        .clone()
                        .toOffset(), //+ Vector2(0, size.y /3)).toOffset(),
                    child: CircleParticle(
                      paint: Paint()..color = Colors.red,
                      lifespan: 1,
                      radius: 1.5,
                    ),
                    //from: position.clone().toOffset(),
                    //to: position.clone().toOffset() + Vector2(0, size.y + 20).toOffset(),
                  )));
      gameRef.add(particleComponent);
      remove();
      final command = Command<Player>(action: (player) {
        player.addToScore(1);
      });
      gameRef.addCommand(command);
    }
  }

  @override
  void update(double dt) {
    position += Vector2(0, 1) *
        _speed *
        dt; //vector(0,1): movement is from top to bottom

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

  Vector2 getRandomVector() {
    //for the position and direction of the player particles
    Random random = Random();
    return (Vector2.random(Random()) - Vector2.random(random)) * 10000;
  }
}
