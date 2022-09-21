import 'package:flame/components.dart';

mixin GameSize on BaseComponent {
  late Vector2 gameSize;

  void onResize(Vector2 newGamesize) {
    gameSize = newGamesize;
  }
}