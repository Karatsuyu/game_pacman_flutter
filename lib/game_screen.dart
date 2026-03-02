import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'constants.dart';
import 'game_map.dart';
import 'game_painter.dart';
import 'score_display.dart';
import 'win_dialog.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  double pacmanX = 1.0;
  double pacmanY = 1.0;
  int score = 0;
  String direction = 'right';
  late Timer gameTimer;
  bool gameRunning = true;

  @override
  void initState() {
    super.initState();
    GameMap.resetMap();
    startGame();
  }

  void startGame() {
    gameTimer = Timer.periodic(
      const Duration(milliseconds: 200),
      (timer) {
        if (gameRunning) {
          movePacman();
        }
      },
    );
  }

  @override
  void dispose() {
    gameTimer.cancel();
    super.dispose();
  }

  void resetGame() {
    setState(() {
      pacmanX = 1.0;
      pacmanY = 1.0;
      score = 0;
      direction = 'right';
      gameRunning = true;
      GameMap.resetMap();
    });
  }

  void movePacman() {
    setState(() {
      double newX = pacmanX;
      double newY = pacmanY;

      switch (direction) {
        case 'right':
          newX += 0.5;
          break;
        case 'left':
          newX -= 0.5;
          break;
        case 'up':
          newY -= 0.5;
          break;
        case 'down':
          newY += 0.5;
          break;
      }

      int gridX = newX.round();
      int gridY = newY.round();

      if (!GameMap.isWall(gridX, gridY)) {
        pacmanX = newX;
        pacmanY = newY;

        final cell = GameMap.layout[gridY][gridX];
        if (cell == 2) {
          GameMap.layout[gridY][gridX] = 0;
          score += kNormalDotPoints;
        } else if (cell == 3) {
          GameMap.layout[gridY][gridX] = 0;
          score += kPowerDotPoints;
        }

        // Verificar si se comieron todos los puntos
        bool allDotsEaten = true;
        for (int y = 0; y < kMapHeight; y++) {
          for (int x = 0; x < kMapWidth; x++) {
            if (GameMap.layout[y][x] == 2 || GameMap.layout[y][x] == 3) {
              allDotsEaten = false;
              break;
            }
          }
          if (!allDotsEaten) break;
        }

        if (allDotsEaten) {
          gameRunning = false;
          showWinDialog(context, score, resetGame);
        }
      }
    });
  }

  void changeDirection(String newDirection) {
    setState(() {
      direction = newDirection;
    });
  }

  @override
  Widget build(BuildContext context) {
    return RawKeyboardListener(
      autofocus: true,
      focusNode: FocusNode()..requestFocus(),
      onKey: (RawKeyEvent event) {
        if (event is RawKeyDownEvent && gameRunning) {
          if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
            changeDirection('right');
          } else if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
            changeDirection('left');
          } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
            changeDirection('up');
          } else if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
            changeDirection('down');
          }
        }
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Column(
          children: [
            ScoreDisplay(score: score, onReset: resetGame),
            Expanded(
              child: Center(
                child: Container(
                  width: 450,
                  height: 300,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.blue, width: 3),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: CustomPaint(
                    painter: GamePainter(
                      pacmanX: pacmanX,
                      pacmanY: pacmanY,
                      direction: direction,
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  const Text(
                    'Usa las flechas del teclado para mover a Pac-Man',
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    gameRunning ? '🎮 Jugando...' : '⏸️ Juego pausado',
                    style: TextStyle(
                      color: gameRunning ? Colors.green : Colors.orange,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}