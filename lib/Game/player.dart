
import 'dart:math';
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/geometry.dart';
import 'package:flame/particles.dart';
import 'package:flutter/material.dart';
import 'package:ship_head/Game/enemy.dart';
import 'package:ship_head/Game/gameWorld.dart';
import 'package:ship_head/Game/game_size.dart';

class Player extends SpriteComponent with GameSize, Hitbox, Collidable, HasGameRef<GameWorld>{
  Vector2 _moveDirection = Vector2.zero();
  final double _speed = 300;
  final Random _random = Random();
  int _score = 0;
  int get score => _score;
  int _health = 100;
  int get health => _health;


  Player({
    Sprite? sprite,
    Vector2? position,
    Vector2? size,
  }): super(sprite: sprite, position: position, size: size);

@override
  void render(Canvas canvas) {
    super.render(canvas);

}
  @override//this method is called by game class for every frame
  void update(double dt) {
    super.update(dt);
    position += _moveDirection.normalized() * _speed * dt;
    position.clamp(
        Vector2.zero() + size / 2,
        // without adjustment trough size , part of player would go outside of boarder
        gameSize - size / 2
    ); //boundaries for the player

    final particleComponent = ParticleComponent(
        particle: Particle.generate(
            count: 30,
            lifespan: 0.1,
            generator: (i) => AcceleratedParticle(
              acceleration: getRandomVector().toOffset(),
              position: (position.clone() + Vector2(0, size.y /3)).toOffset(),
              child: CircleParticle(
                paint: Paint()..color= Colors.white,
                lifespan: 1,
                radius: 2,
              ),
              //from: position.clone().toOffset(),
              //to: position.clone().toOffset() + Vector2(0, size.y + 20).toOffset(),
            )
        )
    );
    gameRef.add(particleComponent);


  }

  @override
  void onMount() {
    super.onMount();
    var circleHitbox = HitboxCircle();
    addShape(circleHitbox);
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, Collidable other) {
    super.onCollision(intersectionPoints, other);
    if (other is Enemy) {
      gameRef.camera.shake();
      _health -= 20;
      if (_health <= 0) {
        _health = 0;
      }
    }
  }

  void setMoveDirection (Vector2 newMoveDirection) {
    _moveDirection = newMoveDirection;
  }

  Vector2 getRandomVector() {
    //for the position and direction of the player particles
    return (Vector2.random(_random) - Vector2(0.5, -1)) * 10000;
  }

  void addToScore(int points) {
    _score += points;
  }

}