import 'dart:math';
import 'package:flutter/material.dart';
import 'constants.dart';
import 'game_map.dart';
import 'ghost.dart';

class GamePainter extends CustomPainter {
  final GameMap gameMap;
  final double pacmanX;
  final double pacmanY;
  final Direction pacmanDir;
  final List<Ghost> ghosts;
  final int lives;
  final int score;
  final int level;
  final int highScore;
  final GameState gameState;
  final double animationTick;
  final int frightenedTimer;
  final int frightenedFlashTime;
  final bool showFruit;
  final int fruitIndex;

  GamePainter({
    required this.gameMap,
    required this.pacmanX,
    required this.pacmanY,
    required this.pacmanDir,
    required this.ghosts,
    required this.lives,
    required this.score,
    required this.level,
    required this.highScore,
    required this.gameState,
    required this.animationTick,
    this.frightenedTimer = 0,
    this.frightenedFlashTime = kFrightenedFlashTime,
    this.showFruit = false,
    this.fruitIndex = 0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;
    if (gameMap.layout.isEmpty) return;

    final cellSize = min(size.width / kMapWidth, (size.height - 80) / (kMapHeight + 2));
    if (cellSize <= 0) return;
    final offsetX = (size.width - cellSize * kMapWidth) / 2;
    final offsetY = 50.0; // top margin for scores

    // Draw background
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), Paint()..color = kBackgroundColor);

    // Draw score area
    _drawScoreArea(canvas, size, cellSize, offsetX);

    canvas.save();
    canvas.translate(offsetX, offsetY);

    // Draw map
    _drawMap(canvas, cellSize);

    // Draw fruit
    if (showFruit) {
      _drawFruit(canvas, cellSize);
    }

    // Draw ghosts
    for (var ghost in ghosts) {
      _drawGhost(canvas, cellSize, ghost);
    }

    // Draw Pac-Man
    if (gameState != GameState.dying || animationTick % 4 < 2) {
      _drawPacman(canvas, cellSize);
    }

    canvas.restore();

    // Draw lives
    _drawLives(canvas, cellSize, offsetX, offsetY + cellSize * kMapHeight + 5);

    // Draw level indicator
    _drawLevelIndicator(canvas, cellSize, offsetX, offsetY + cellSize * kMapHeight + 5, size.width);
  }

  void _drawScoreArea(Canvas canvas, Size size, double cellSize, double offsetX) {
    final textStyle = TextStyle(
      color: Colors.white,
      fontSize: cellSize * 0.9,
      fontWeight: FontWeight.bold,
      fontFamily: 'monospace',
    );
    final highScoreStyle = TextStyle(
      color: Colors.white,
      fontSize: cellSize * 0.7,
      fontFamily: 'monospace',
    );

    // "1UP" label
    _drawText(canvas, '1UP', offsetX + cellSize * 3, 2, textStyle);
    // Score
    _drawText(canvas, score.toString().padLeft(8, ' '), offsetX + cellSize * 0.5, 15, textStyle);

    // HIGH SCORE label
    _drawText(canvas, 'HIGH SCORE', size.width / 2 - cellSize * 3.5, 2, highScoreStyle);
    // High score value
    _drawText(canvas, highScore.toString().padLeft(8, ' '), size.width / 2 - cellSize * 2, 15, textStyle);
  }

  void _drawText(Canvas canvas, String text, double x, double y, TextStyle style) {
    final textPainter = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(x, y));
  }

  void _drawMap(Canvas canvas, double cellSize) {
    final wallPaint = Paint()..color = kWallColor;
    final wallBorderPaint = Paint()
      ..color = kWallBorderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    final dotPaint = Paint()..color = kDotColor;
    final ghostDoorPaint = Paint()
      ..color = const Color(0xFFFFB8AE)
      ..strokeWidth = 2;

    for (int y = 0; y < kMapHeight && y < gameMap.layout.length; y++) {
      for (int x = 0; x < kMapWidth && x < gameMap.layout[y].length; x++) {
        final rect = Rect.fromLTWH(
          x * cellSize, y * cellSize, cellSize, cellSize,
        );
        final center = rect.center;

        switch (gameMap.layout[y][x]) {
          case kWall:
            // Draw wall with rounded look
            canvas.drawRRect(
              RRect.fromRectAndRadius(
                rect.deflate(0.5),
                Radius.circular(cellSize * 0.15),
              ),
              wallPaint,
            );
            canvas.drawRRect(
              RRect.fromRectAndRadius(
                rect.deflate(1.0),
                Radius.circular(cellSize * 0.15),
              ),
              wallBorderPaint,
            );
            break;

          case kDot:
            canvas.drawCircle(center, cellSize * 0.08, dotPaint);
            break;

          case kPowerPellet:
            // Blinking effect for power pellets
            if (animationTick % 30 < 20) {
              canvas.drawCircle(center, cellSize * 0.25, dotPaint);
              // Glow
              canvas.drawCircle(center, cellSize * 0.3,
                Paint()..color = kPowerPelletColor.withAlpha(60)
                  ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3));
            }
            break;

          case kGhostDoor:
            canvas.drawLine(
              Offset(rect.left, rect.center.dy),
              Offset(rect.right, rect.center.dy),
              ghostDoorPaint,
            );
            break;
        }
      }
    }
  }

  void _drawPacman(Canvas canvas, double cellSize) {
    final center = Offset(
      (pacmanX + 0.5) * cellSize,
      (pacmanY + 0.5) * cellSize,
    );
    final radius = cellSize * 0.45;

    // Mouth animation
    double mouthAngle = 0.25 + sin(animationTick * 0.5) * 0.2;

    double startAngle;
    switch (pacmanDir) {
      case Direction.right:
        startAngle = mouthAngle;
        break;
      case Direction.left:
        startAngle = pi + mouthAngle;
        break;
      case Direction.up:
        startAngle = -pi / 2 + mouthAngle;
        break;
      case Direction.down:
        startAngle = pi / 2 + mouthAngle;
        break;
      case Direction.none:
        startAngle = mouthAngle;
    }

    final sweepAngle = 2 * pi - (mouthAngle * 2);
    final pacPaint = Paint()..color = kPacmanColor;

    if (gameState == GameState.dying) {
      // Death animation - mouth opens wide
      double deathProgress = (animationTick % 60) / 60.0;
      double deathSweep = 2 * pi * (1 - deathProgress);
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -pi / 2, deathSweep, true, pacPaint,
      );
    } else {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle, sweepAngle, true, pacPaint,
      );
    }
  }

  void _drawGhost(Canvas canvas, double cellSize, Ghost ghost) {
    if (ghost.mode == GhostMode.inHouse && !ghost.isActive && ghost.mode == GhostMode.inHouse) {
      // Still draw ghosts in house
    }

    final center = Offset(
      (ghost.x + 0.5) * cellSize,
      (ghost.y + 0.5) * cellSize,
    );
    final size = cellSize * 0.9;

    Color bodyColor;
    if (ghost.mode == GhostMode.eaten) {
      // Only draw eyes
      _drawGhostEyes(canvas, center, size, ghost.direction);
      return;
    } else if (ghost.mode == GhostMode.frightened) {
      // Flash between blue and white near end
      if (frightenedTimer < frightenedFlashTime) {
        bodyColor = (animationTick % 10 < 5) ? kFrightenedColor : kFrightenedFlashColor;
      } else {
        bodyColor = kFrightenedColor;
      }
    } else {
      bodyColor = ghost.color;
    }

    final bodyPaint = Paint()..color = bodyColor;

    // Ghost body - rounded top, wavy bottom
    final path = Path();
    final bottom = center.dy + size * 0.4;
    final left = center.dx - size * 0.45;
    final right = center.dx + size * 0.45;
    final width = right - left;

    // Top arc
    path.moveTo(left, bottom);
    path.lineTo(left, center.dy - size * 0.1);
    path.arcToPoint(
      Offset(right, center.dy - size * 0.1),
      radius: Radius.circular(width / 2),
      clockwise: true,
    );
    path.lineTo(right, bottom);

    // Wavy bottom
    int waves = 3;
    double waveWidth = width / waves;
    for (int i = waves; i >= 0; i--) {
      double wx = left + i * waveWidth;
      double wy = (i % 2 == 0) ? bottom : bottom - size * 0.15;
      path.lineTo(wx, wy);
    }

    path.close();
    canvas.drawPath(path, bodyPaint);

    // Draw eyes
    if (ghost.mode != GhostMode.frightened) {
      _drawGhostEyes(canvas, center, size, ghost.direction);
    } else {
      _drawFrightenedFace(canvas, center, size);
    }
  }

  void _drawGhostEyes(Canvas canvas, Offset center, double size, Direction dir) {
    final eyeWhitePaint = Paint()..color = kGhostEyeWhite;
    final pupilPaint = Paint()..color = kGhostEyePupil;

    double eyeRadius = size * 0.15;
    double pupilRadius = size * 0.08;

    // Eye positions
    Offset leftEyeCenter = Offset(center.dx - size * 0.18, center.dy - size * 0.15);
    Offset rightEyeCenter = Offset(center.dx + size * 0.18, center.dy - size * 0.15);

    // Pupil offset based on direction
    double pupilOffX = 0, pupilOffY = 0;
    switch (dir) {
      case Direction.left:
        pupilOffX = -size * 0.06;
        break;
      case Direction.right:
        pupilOffX = size * 0.06;
        break;
      case Direction.up:
        pupilOffY = -size * 0.06;
        break;
      case Direction.down:
        pupilOffY = size * 0.06;
        break;
      case Direction.none:
        break;
    }

    // White of eyes
    canvas.drawOval(
      Rect.fromCenter(center: leftEyeCenter, width: eyeRadius * 2, height: eyeRadius * 2.2),
      eyeWhitePaint,
    );
    canvas.drawOval(
      Rect.fromCenter(center: rightEyeCenter, width: eyeRadius * 2, height: eyeRadius * 2.2),
      eyeWhitePaint,
    );

    // Pupils
    canvas.drawCircle(
      Offset(leftEyeCenter.dx + pupilOffX, leftEyeCenter.dy + pupilOffY),
      pupilRadius, pupilPaint,
    );
    canvas.drawCircle(
      Offset(rightEyeCenter.dx + pupilOffX, rightEyeCenter.dy + pupilOffY),
      pupilRadius, pupilPaint,
    );
  }

  void _drawFrightenedFace(Canvas canvas, Offset center, double size) {
    final eyePaint = Paint()..color = kPowerPelletColor;
    double eyeSize = size * 0.06;

    // Small dot eyes
    canvas.drawCircle(
      Offset(center.dx - size * 0.15, center.dy - size * 0.12),
      eyeSize, eyePaint,
    );
    canvas.drawCircle(
      Offset(center.dx + size * 0.15, center.dy - size * 0.12),
      eyeSize, eyePaint,
    );

    // Squiggly mouth
    final mouthPaint = Paint()
      ..color = kPowerPelletColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    final mouthPath = Path();
    double mouthY = center.dy + size * 0.1;
    double mouthLeft = center.dx - size * 0.2;
    mouthPath.moveTo(mouthLeft, mouthY);
    for (int i = 0; i < 4; i++) {
      double x1 = mouthLeft + (i * 2 + 1) * size * 0.05;
      double y1 = mouthY + ((i % 2 == 0) ? -size * 0.05 : size * 0.05);
      mouthPath.lineTo(x1, y1);
    }
    canvas.drawPath(mouthPath, mouthPaint);
  }

  void _drawFruit(Canvas canvas, double cellSize) {
    final center = Offset(14 * cellSize, 17.5 * cellSize);
    final radius = cellSize * 0.4;

    // Simple fruit drawing (cherry)
    final fruitColors = [
      Colors.red, Colors.red, Colors.orange, Colors.red,
      Colors.green, Colors.green, Colors.yellow, Colors.yellow,
    ];
    Color fruitColor = fruitColors[fruitIndex.clamp(0, fruitColors.length - 1)];

    canvas.drawCircle(center, radius, Paint()..color = fruitColor);
    // Stem
    canvas.drawLine(
      center + Offset(0, -radius),
      center + Offset(radius * 0.3, -radius * 1.5),
      Paint()..color = Colors.green..strokeWidth = 2,
    );
  }

  void _drawLives(Canvas canvas, double cellSize, double offsetX, double y) {
    final pacPaint = Paint()..color = kPacmanColor;
    for (int i = 0; i < lives - 1; i++) {
      final cx = offsetX + (i + 1) * cellSize * 2;
      final cy = y + cellSize * 0.7;
      canvas.drawArc(
        Rect.fromCircle(center: Offset(cx, cy), radius: cellSize * 0.5),
        0.3 + pi, 2 * pi - 0.6, true, pacPaint,
      );
    }
  }

  void _drawLevelIndicator(Canvas canvas, double cellSize, double offsetX, double y, double width) {
    final textStyle = TextStyle(
      color: Colors.white,
      fontSize: cellSize * 0.8,
      fontWeight: FontWeight.bold,
      fontFamily: 'monospace',
    );
    _drawText(canvas, 'LVL $level', width - offsetX - cellSize * 5, y + cellSize * 0.2, textStyle);
  }

  @override
  bool shouldRepaint(covariant GamePainter oldDelegate) => true;
}
