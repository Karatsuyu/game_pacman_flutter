import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'constants.dart';
import 'game_map.dart';
import 'ghost.dart';
import 'effects/particle_system.dart';

/// ============================================================================
/// ESTILOS DE EFECTOS
/// ============================================================================
class EffectStyles {
  static const double pacmanGlowBlur = 12.0;
  static const double ghostGlowBlur = 10.0;
  static const double pelletGlowBlur = 6.0;
  static const double powerPelletGlowBlur = 15.0;
  static const double wallGlowBlur = 8.0;

  static const double pacmanMouthSpeed = 0.4;
  static const double pacmanMouthMax = 0.35;
  static const double pacmanMouthMin = 0.1;
}

/// ============================================================================
/// GAME PAINTER - RENDERIZADO NEÓN CON EFECTOS ESPECTACULARES
/// Incluye brillos, partículas, animaciones y efectos de pantalla
/// ============================================================================
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
  final bool showFruit;
  final int fruitIndex;
  final int combo;
  final int? bonusFruitIndex;

  // Sistemas de efectos
  final ParticleSystem particleSystem;
  final ScreenShake screenShake;
  final Shockwave shockwave;

  // Configuración
  final bool enableGlow;
  final bool enableParticles;
  final bool enableScreenShake;

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
    this.showFruit = false,
    this.fruitIndex = 0,
    this.combo = 0,
    this.bonusFruitIndex,
    required this.particleSystem,
    required this.screenShake,
    required this.shockwave,
    this.enableGlow = true,
    this.enableParticles = true,
    this.enableScreenShake = true,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;
    if (gameMap.layout.isEmpty) return;

    // Calcular tamaño de celda
    final cellSize = min(size.width / kMapWidth, (size.height - 100) / (kMapHeight + 2));
    if (cellSize <= 0) return;

    final offsetX = (size.width - cellSize * kMapWidth) / 2;
    final offsetY = 70.0;

    // Aplicar temblor de pantalla
    Offset shakeOffset = Offset.zero;
    if (enableScreenShake && screenShake.isActive) {
      shakeOffset = screenShake.offset;
    }

    canvas.save();
    canvas.translate(shakeOffset.dx, shakeOffset.dy);

    // Dibujar fondo con gradiente
    _drawBackground(canvas, size);

    // Dibujar área de puntuación
    _drawScoreArea(canvas, size, cellSize, offsetX);

    canvas.save();
    canvas.translate(offsetX, offsetY);

    // Dibujar mapa con efectos neón
    _drawMap(canvas, cellSize);

    // Dibujar fruta bonus
    if (showFruit) {
      _drawFruit(canvas, cellSize);
    }

    // Dibujar power-ups especiales
    _drawBonusItems(canvas, cellSize);

    // Dibujar fantasmas
    for (var ghost in ghosts) {
      _drawGhost(canvas, cellSize, ghost);
    }

    // Dibujar Pac-Man
    if (gameState != GameState.dying || animationTick % 8 < 4) {
      _drawPacman(canvas, cellSize);
    }

    // Dibujar partículas
    if (enableParticles) {
      particleSystem.paint(canvas);
    }

    // Dibujar onda de choque
    shockwave.paint(canvas);

    canvas.restore();

    // Dibujar vidas
    _drawLives(canvas, cellSize, offsetX, offsetY + cellSize * kMapHeight + 10);

    // Dibujar indicador de nivel y combo
    _drawLevelIndicator(canvas, cellSize, offsetX, offsetY + cellSize * kMapHeight + 10, size.width);

    canvas.restore();
  }

  /// Dibuja el fondo con gradiente futurista
  void _drawBackground(Canvas canvas, Size size) {
    // Fondo base oscuro
    final bgPaint = Paint()..color = NeonColors.darkerBg;
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    // Gradiente radial sutil
    final gradient = RadialGradient(
      center: const Alignment(0, -0.3),
      radius: 1.2,
      colors: [
        NeonColors.darkBg.withOpacity(0.8),
        NeonColors.darkerBg,
        NeonColors.darkerBg,
      ],
    );

    final rectPaint = Paint()
      ..shader = gradient.createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), rectPaint);

    // Efecto de rejilla decorativa
    _drawGridPattern(canvas, size);
  }

  /// Dibuja un patrón de rejilla decorativo
  void _drawGridPattern(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = NeonColors.primaryNeon.withOpacity(0.03)
      ..strokeWidth = 1;

    const spacing = 40.0;

    // Líneas verticales
    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        gridPaint,
      );
    }

    // Líneas horizontales
    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        gridPaint,
      );
    }
  }

  /// Dibuja el área de puntuación con estilo neón
  void _drawScoreArea(Canvas canvas, Size size, double cellSize, double offsetX) {
    // Panel de puntuación
    final panelPaint = Paint()
      ..color = NeonColors.uiPanelBg
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = NeonColors.uiBorder.withOpacity(0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    // Panel izquierdo (1UP y score)
    final leftPanel = RRect.fromRectAndRadius(
      Rect.fromLTWH(offsetX - 10, 5, size.width * 0.35, 55),
      const Radius.circular(8),
    );
    canvas.drawRRect(leftPanel, panelPaint);
    canvas.drawRRect(leftPanel, borderPaint);

    // Panel central (HIGH SCORE)
    final centerPanel = RRect.fromRectAndRadius(
      Rect.fromLTWH(size.width * 0.325, 5, size.width * 0.35, 55),
      const Radius.circular(8),
    );
    canvas.drawRRect(centerPanel, panelPaint);
    canvas.drawRRect(centerPanel, borderPaint);

    // Panel derecho (nivel)
    final rightPanel = RRect.fromRectAndRadius(
      Rect.fromLTWH(size.width * 0.65, 5, size.width * 0.35 - offsetX + 10, 55),
      const Radius.circular(8),
    );
    canvas.drawRRect(rightPanel, panelPaint);
    canvas.drawRRect(rightPanel, borderPaint);

    // Textos
    final labelStyle = TextStyle(
      fontFamily: TextStyles.neonFont,
      fontSize: cellSize * 0.5,
      fontWeight: FontWeight.w600,
      color: NeonColors.textSecondary,
      letterSpacing: 2,
    );

    final scoreStyle = TextStyle(
      fontFamily: TextStyles.neonFont,
      fontSize: cellSize * 0.7,
      fontWeight: FontWeight.bold,
      color: NeonColors.textPrimary,
      letterSpacing: 2,
      shadows: [
        Shadow(
          color: NeonColors.primaryNeon.withOpacity(0.5),
          blurRadius: 8,
        ),
      ],
    );

    final highScoreStyle = TextStyle(
      fontFamily: TextStyles.neonFont,
      fontSize: cellSize * 0.5,
      fontWeight: FontWeight.bold,
      color: NeonColors.textAccent,
      letterSpacing: 3,
    );

    // 1UP
    _drawText(canvas, '1UP', offsetX + cellSize * 0.5, 12, labelStyle);
    _drawText(canvas, score.toString().padLeft(8, '0'), offsetX + cellSize * 0.5, 32, scoreStyle);

    // HIGH SCORE
    _drawText(canvas, 'HIGH SCORE', size.width / 2 - cellSize * 3, 12, highScoreStyle);
    _drawText(canvas, highScore.toString().padLeft(8, '0'), size.width / 2 - cellSize * 2.5, 32, scoreStyle);
  }

  /// Dibuja el mapa con efectos neón
  void _drawMap(Canvas canvas, double cellSize) {
    for (int y = 0; y < kMapHeight && y < gameMap.layout.length; y++) {
      for (int x = 0; x < kMapWidth && x < gameMap.layout[y].length; x++) {
        final rect = Rect.fromLTWH(
          x * cellSize, y * cellSize, cellSize, cellSize,
        );
        final center = rect.center;

        switch (gameMap.layout[y][x]) {
          case kWall:
            _drawWall(canvas, rect, cellSize);
            break;

          case kDot:
            _drawDot(canvas, center, cellSize);
            break;

          case kPowerPellet:
            _drawPowerPellet(canvas, center, cellSize);
            break;

          case kGhostDoor:
            _drawGhostDoor(canvas, rect, cellSize);
            break;

          case kSpeedBoost:
            _drawSpeedBoost(canvas, center, cellSize);
            break;

          case kFreezeGhost:
            _drawFreezeGhost(canvas, center, cellSize);
            break;
        }
      }
    }
  }

  /// Dibuja una pared con efecto neón
  void _drawWall(Canvas canvas, Rect rect, double cellSize) {
    if (!enableGlow) {
      // Sin brillo - versión simple
      final wallPaint = Paint()..color = NeonColors.primaryNeon;
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect.deflate(1), Radius.circular(cellSize * 0.15)),
        wallPaint,
      );
      return;
    }

    // Capa base
    final basePaint = Paint()..color = NeonColors.secondaryNeon;
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect.deflate(2), Radius.circular(cellSize * 0.15)),
      basePaint,
    );

    // Brillo interior
    final glowPaint = Paint()
      ..color = NeonColors.primaryNeon.withOpacity(0.8)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect.deflate(3), Radius.circular(cellSize * 0.12)),
      glowPaint,
    );

    // Núcleo brillante
    final corePaint = Paint()..color = Colors.white.withOpacity(0.3);
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect.deflate(5), Radius.circular(cellSize * 0.08)),
      corePaint,
    );
  }

  /// Dibuja un punto normal
  void _drawDot(Canvas canvas, Offset center, double cellSize) {
    final dotRadius = cellSize * 0.08;

    // Brillo exterior
    if (enableGlow) {
      final glowPaint = Paint()
        ..color = NeonColors.dotNeon.withOpacity(0.4)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
      canvas.drawCircle(center, dotRadius * 1.5, glowPaint);
    }

    // Punto central
    final dotPaint = Paint()..color = NeonColors.dotNeon;
    canvas.drawCircle(center, dotRadius, dotPaint);

    // Punto blanco interior (brillo)
    final highlightPaint = Paint()..color = Colors.white.withOpacity(0.5);
    canvas.drawCircle(center, dotRadius * 0.5, highlightPaint);
  }

  /// Dibuja un power pellet con animación
  void _drawPowerPellet(Canvas canvas, Offset center, double cellSize) {
    // Animación de parpadeo
    final pulse = (sin(animationTick * 0.3) + 1) / 2;
    final baseRadius = cellSize * 0.25;
    final radius = baseRadius * (0.9 + pulse * 0.2);

    // Brillo exterior grande
    if (enableGlow) {
      final outerGlow = Paint()
        ..color = NeonColors.powerPelletNeon.withOpacity(0.3 + pulse * 0.2)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, 8 + pulse * 4);
      canvas.drawCircle(center, radius * 2, outerGlow);

      final innerGlow = Paint()
        ..color = NeonColors.powerPelletNeon.withOpacity(0.6)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
      canvas.drawCircle(center, radius * 1.3, innerGlow);
    }

    // Círculo principal
    final pelletPaint = Paint()
      ..color = Color.lerp(NeonColors.powerPelletNeon, Colors.white, pulse * 0.5)!;
    canvas.drawCircle(center, radius, pelletPaint);

    // Núcleo blanco
    final corePaint = Paint()..color = Colors.white.withOpacity(0.7 + pulse * 0.3);
    canvas.drawCircle(center, radius * 0.5, corePaint);
  }

  /// Dibuja la puerta de la casa de fantasmas
  void _drawGhostDoor(Canvas canvas, Rect rect, double cellSize) {
    final doorPaint = Paint()
      ..color = NeonColors.accentNeon.withOpacity(0.6)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    // Línea superior
    canvas.drawLine(
      Offset(rect.left, rect.center.dy - 3),
      Offset(rect.right, rect.center.dy - 3),
      doorPaint,
    );

    // Línea inferior
    canvas.drawLine(
      Offset(rect.left, rect.center.dy + 3),
      Offset(rect.right, rect.center.dy + 3),
      doorPaint,
    );
  }

  /// Dibuja un power-up de velocidad
  void _drawSpeedBoost(Canvas canvas, Offset center, double cellSize) {
    final boltPaint = Paint()
      ..color = NeonColors.particleSpeed
      ..style = PaintingStyle.fill;

    if (enableGlow) {
      final glowPaint = Paint()
        ..color = NeonColors.particleSpeed.withOpacity(0.5)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
      canvas.drawCircle(center, cellSize * 0.2, glowPaint);
    }

    // Dibujar rayo
    final path = Path();
    final size = cellSize * 0.15;
    path.moveTo(center.dx + size * 0.3, center.dy - size);
    path.lineTo(center.dx - size * 0.5, center.dy);
    path.lineTo(center.dx + size * 0.2, center.dy);
    path.lineTo(center.dx - size * 0.3, center.dy + size);
    path.lineTo(center.dx + size * 0.5, center.dy);
    path.lineTo(center.dx - size * 0.2, center.dy);
    path.close();

    canvas.drawPath(path, boltPaint);
  }

  /// Dibuja un power-up de congelar fantasmas
  void _drawFreezeGhost(Canvas canvas, Offset center, double cellSize) {
    final icePaint = Paint()
      ..color = NeonColors.particleFreeze
      ..style = PaintingStyle.fill;

    if (enableGlow) {
      final glowPaint = Paint()
        ..color = NeonColors.particleFreeze.withOpacity(0.5)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
      canvas.drawCircle(center, cellSize * 0.2, glowPaint);
    }

    // Dibujar copo de nieve
    final size = cellSize * 0.15;
    final strokePaint = Paint()
      ..color = NeonColors.particleFreeze
      ..strokeWidth = 2;

    for (int i = 0; i < 6; i++) {
      final angle = (i * pi / 3) - pi / 2;
      final end = Offset(
        center.dx + cos(angle) * size,
        center.dy + sin(angle) * size,
      );
      canvas.drawLine(center, end, strokePaint);
    }
  }

  /// Dibuja Pac-Man con efectos neón
  void _drawPacman(Canvas canvas, double cellSize) {
    final center = Offset(
      (pacmanX + 0.5) * cellSize,
      (pacmanY + 0.5) * cellSize,
    );
    final radius = cellSize * 0.42;

    // Animación de la boca
    double mouthAngle = EffectStyles.pacmanMouthMin +
        sin(animationTick * EffectStyles.pacmanMouthSpeed) *
        (EffectStyles.pacmanMouthMax - EffectStyles.pacmanMouthMin);

    double rotationOffset = 0;

    switch (pacmanDir) {
      case Direction.right:
        rotationOffset = 0;
        break;
      case Direction.left:
        rotationOffset = pi;
        break;
      case Direction.up:
        rotationOffset = -pi / 2;
        break;
      case Direction.down:
        rotationOffset = pi / 2;
        break;
      case Direction.none:
        rotationOffset = 0;
    }

    // Brillo exterior (glow) - solo si está habilitado
    if (enableGlow) {
      final glowPaint = Paint()
        ..color = NeonColors.pacmanGlow
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, EffectStyles.pacmanGlowBlur);
      canvas.drawCircle(center, radius * 0.85, glowPaint);
    }

    // Cuerpo principal
    final pacPaint = Paint()
      ..color = NeonColors.pacmanBody
      ..style = PaintingStyle.fill;

    if (gameState == GameState.dying) {
      // Animación de muerte
      double deathProgress = (animationTick % 60) / 60.0;
      double deathSweep = 2 * pi * (1 - deathProgress);

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -pi / 2, deathSweep, true, pacPaint,
      );
    } else {
      // Pac-Man normal - rotar el canvas para la dirección
      canvas.save();
      canvas.translate(center.dx, center.dy);
      canvas.rotate(rotationOffset);

      // Dibujar Pac-Man como un círculo con la boca recortada
      final path = Path();
      path.moveTo(0, 0);
      path.arcTo(
        Rect.fromCircle(center: Offset.zero, radius: radius),
        mouthAngle,
        2 * pi - (mouthAngle * 2),
        false, // Changed to false to ensure the path is not closed automatically
      );
      path.close();

      canvas.drawPath(path, pacPaint);

      // Dibujar ojo
      final eyePaint = Paint()..color = Colors.black;
      final eyeRadius = radius * 0.12;
      final eyeOffset = Offset(radius * 0.1, -radius * 0.4);
      canvas.drawCircle(eyeOffset, eyeRadius, eyePaint);

      canvas.restore();
    }
  }

  /// Dibuja un fantasma con efectos neón
  void _drawGhost(Canvas canvas, double cellSize, Ghost ghost) {
    if (ghost.mode == GhostMode.inHouse && !ghost.isActive) {
      // Dibujar fantasmas en la casa
    }

    final center = Offset(
      (ghost.x + 0.5) * cellSize,
      (ghost.y + 0.5) * cellSize,
    );
    final size = cellSize * 0.9 * ghost.scale;

    // Si está comido, solo dibujar ojos
    if (ghost.mode == GhostMode.eaten) {
      _drawGhostEyes(canvas, center, size, ghost.direction, true);
      return;
    }

    // Determinar color
    Color bodyColor;
    if (ghost.mode == GhostMode.frightened) {
      // Parpadeo cuando está por terminar el efecto
      if (frightenedTimer < kFrightenedFlashTime) {
        bodyColor = (animationTick % 10 < 5) ? NeonColors.frightenedNeon : NeonColors.frightenedFlash;
      } else {
        bodyColor = NeonColors.frightenedNeon;
      }
    } else if (ghost.mode == GhostMode.frozen) {
      bodyColor = NeonColors.particleFreeze;
    } else {
      bodyColor = ghost.color;
    }

    // Brillo exterior
    if (enableGlow) {
      final glowPaint = Paint()
        ..color = bodyColor.withOpacity(0.4)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, EffectStyles.ghostGlowBlur * ghost.glowIntensity);
      canvas.drawCircle(center, size * 0.6, glowPaint);
    }

    // Cuerpo del fantasma
    _drawGhostBody(canvas, center, size, bodyColor);

    // Dibujar cara
    if (ghost.mode == GhostMode.frightened) {
      _drawFrightenedFace(canvas, center, size);
    } else if (ghost.mode == GhostMode.frozen) {
      _drawFrozenFace(canvas, center, size);
    } else {
      _drawGhostEyes(canvas, center, size, ghost.direction, false);
    }
  }

  /// Dibuja el cuerpo del fantasma
  void _drawGhostBody(Canvas canvas, Offset center, double size, Color color) {
    final bodyPaint = Paint()
      ..shader = RadialGradient(
        center: Alignment.topCenter,
        radius: 1.2,
        colors: [
          color.withOpacity(0.8),
          color,
        ],
      ).createShader(Rect.fromCircle(center: center, radius: size * 0.5));

    final path = Path();
    final bottom = center.dy + size * 0.4;
    final left = center.dx - size * 0.45;
    final right = center.dx + size * 0.45;
    final width = right - left;

    // Parte superior redondeada
    path.moveTo(left, bottom);
    path.lineTo(left, center.dy - size * 0.1);
    path.arcToPoint(
      Offset(right, center.dy - size * 0.1),
      radius: Radius.circular(width / 2),
      clockwise: true,
    );
    path.lineTo(right, bottom);

    // Ondas en la parte inferior
    int waves = 3;
    double waveWidth = width / waves;
    for (int i = waves; i >= 0; i--) {
      double wx = left + i * waveWidth;
      double wy = (i % 2 == 0) ? bottom : bottom - size * 0.12;
      path.lineTo(wx, wy);
    }

    path.close();
    canvas.drawPath(path, bodyPaint);

    // Brillo interior para efecto 3D
    final highlightPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          Colors.white.withOpacity(0.3),
          Colors.white.withOpacity(0.0),
        ],
      ).createShader(Rect.fromCircle(center: center.translate(-size * 0.1, -size * 0.1), radius: size * 0.3));

    canvas.drawCircle(center.translate(-size * 0.1, -size * 0.1), size * 0.3, highlightPaint);
  }

  /// Dibuja los ojos del fantasma
  void _drawGhostEyes(Canvas canvas, Offset center, double size, Direction dir, bool isEaten) {
    final eyeWhitePaint = Paint()..color = Colors.white;
    final pupilPaint = Paint()..color = NeonColors.primaryNeon;

    double eyeRadius = size * 0.15;
    double pupilRadius = size * 0.08;

    // Posiciones de los ojos
    Offset leftEyeCenter = Offset(center.dx - size * 0.18, center.dy - size * 0.12);
    Offset rightEyeCenter = Offset(center.dx + size * 0.18, center.dy - size * 0.12);

    // Pupilas se mueven según la dirección
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

    // Parte blanca de los ojos
    canvas.drawOval(
      Rect.fromCenter(center: leftEyeCenter, width: eyeRadius * 2, height: eyeRadius * 2.2),
      eyeWhitePaint,
    );
    canvas.drawOval(
      Rect.fromCenter(center: rightEyeCenter, width: eyeRadius * 2, height: eyeRadius * 2.2),
      eyeWhitePaint,
    );

    // Pupilas
    canvas.drawCircle(
      Offset(leftEyeCenter.dx + pupilOffX, leftEyeCenter.dy + pupilOffY),
      pupilRadius, pupilPaint,
    );
    canvas.drawCircle(
      Offset(rightEyeCenter.dx + pupilOffX, rightEyeCenter.dy + pupilOffY),
      pupilRadius, pupilPaint,
    );
  }

  /// Dibuja la cara de fantasma asustado
  void _drawFrightenedFace(Canvas canvas, Offset center, double size) {
    final eyePaint = Paint()..color = Colors.white;
    double eyeSize = size * 0.06;

    // Ojos pequeños
    canvas.drawCircle(
      Offset(center.dx - size * 0.15, center.dy - size * 0.1),
      eyeSize, eyePaint,
    );
    canvas.drawCircle(
      Offset(center.dx + size * 0.15, center.dy - size * 0.1),
      eyeSize, eyePaint,
    );

    // Boca ondulada
    final mouthPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final mouthPath = Path();
    double mouthY = center.dy + size * 0.15;
    double mouthLeft = center.dx - size * 0.2;
    mouthPath.moveTo(mouthLeft, mouthY);

    for (int i = 0; i < 4; i++) {
      double x = mouthLeft + (i * 2 + 1) * size * 0.05;
      double y = mouthY + ((i % 2 == 0) ? -size * 0.06 : size * 0.06);
      mouthPath.lineTo(x, y);
    }

    canvas.drawPath(mouthPath, mouthPaint);
  }

  /// Dibuja la cara de fantasma congelado
  void _drawFrozenFace(Canvas canvas, Offset center, double size) {
    final mouthPath = Path();
    double mouthY = center.dy + size * 0.15;
    mouthPath.moveTo(center.dx - size * 0.15, mouthY);

    for (int i = 0; i < 6; i++) {
      double x = center.dx - size * 0.15 + i * size * 0.05;
      double y = mouthY + ((i % 2 == 0) ? -size * 0.03 : size * 0.03);
      mouthPath.lineTo(x, y);
    }

  }

  /// Dibuja la fruta bonus
  void _drawFruit(Canvas canvas, double cellSize) {
    final center = Offset(14 * cellSize, 17.5 * cellSize);
    final radius = cellSize * 0.35;

    // Colores de frutas según nivel
    final fruitColors = [
      NeonColors.cherryNeon,
      NeonColors.strawberryNeon,
      NeonColors.orangeNeon,
      NeonColors.appleNeon,
      NeonColors.melonNeon,
      NeonColors.galaxyNeon,
      Colors.white,
      Colors.amber,
    ];

    Color fruitColor = fruitColors[fruitIndex.clamp(0, fruitColors.length - 1)];

    // Brillo
    if (enableGlow) {
      final glowPaint = Paint()
        ..color = fruitColor.withOpacity(0.4)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
      canvas.drawCircle(center, radius * 1.2, glowPaint);
    }

    // Fruta
    final fruitPaint = Paint()..color = fruitColor;
    canvas.drawCircle(center, radius, fruitPaint);

    // Brillo en la fruta
    final highlightPaint = Paint()..color = Colors.white.withOpacity(0.4);
    canvas.drawCircle(
      Offset(center.dx - radius * 0.3, center.dy - radius * 0.3),
      radius * 0.3, highlightPaint,
    );

    // Tallo
    final stemPaint = Paint()
      ..color = Colors.green
      ..strokeWidth = 2;
    canvas.drawLine(
      Offset(center.dx, center.dy - radius),
      Offset(center.dx + radius * 0.3, center.dy - radius * 1.4),
      stemPaint,
    );
  }

  /// Dibuja items bonus
  void _drawBonusItems(Canvas canvas, double cellSize) {
    if (bonusFruitIndex == null) return;

    final center = Offset(14 * cellSize, 17.5 * cellSize);
    final size = cellSize * 0.4;

    // Dibujar según el tipo
    switch (bonusFruitIndex) {
      case 0: // Cereza
      case 1: // Fresa
      case 2: // Naranja
      case 3: // Manzana
      case 4: // Melón
      case 5: // Galaxia
        _drawFruit(canvas, cellSize);
        break;
      case 6: // Diamante
        _drawDiamond(canvas, center, size);
        break;
      case 7: // Corona
        _drawCrown(canvas, center, size);
        break;
    }
  }

  void _drawDiamond(Canvas canvas, Offset center, double size) {
    final diamondPaint = Paint()
      ..color = Colors.cyan
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(center.dx, center.dy - size);
    path.lineTo(center.dx + size * 0.7, center.dy);
    path.lineTo(center.dx, center.dy + size);
    path.lineTo(center.dx - size * 0.7, center.dy);
    path.close();

    canvas.drawPath(path, diamondPaint);
  }

  void _drawCrown(Canvas canvas, Offset center, double size) {
    final crownPaint = Paint()
      ..color = Colors.amber
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(center.dx - size, center.dy + size * 0.5);
    path.lineTo(center.dx - size, center.dy - size * 0.3);
    path.lineTo(center.dx - size * 0.5, center.dy - size * 0.5);
    path.lineTo(center.dx, center.dy - size * 0.8);
    path.lineTo(center.dx + size * 0.5, center.dy - size * 0.5);
    path.lineTo(center.dx + size, center.dy - size * 0.3);
    path.lineTo(center.dx + size, center.dy + size * 0.5);
    path.close();

    canvas.drawPath(path, crownPaint);
  }

  /// Dibuja las vidas restantes
  void _drawLives(Canvas canvas, double cellSize, double offsetX, double y) {
    final pacPaint = Paint()..color = NeonColors.pacmanBody;

    for (int i = 0; i < lives - 1 && i < 4; i++) {
      final cx = offsetX + (i + 1) * cellSize * 1.8;
      final cy = y + cellSize * 0.7;
      final radius = cellSize * 0.4;

      // Mini Pac-Man
      canvas.drawArc(
        Rect.fromCircle(center: Offset(cx, cy), radius: radius),
        0.3 + pi, 2 * pi - 0.6, true, pacPaint,
      );
    }
  }

  /// Dibuja el indicador de nivel y combo
  void _drawLevelIndicator(Canvas canvas, double cellSize, double offsetX, double y, double width) {
    final levelStyle = TextStyle(
      fontFamily: TextStyles.neonFont,
      fontSize: cellSize * 0.6,
      fontWeight: FontWeight.bold,
      color: NeonColors.textAccent,
      letterSpacing: 2,
    );

    final mapNameStyle = TextStyle(
      fontFamily: TextStyles.neonFont,
      fontSize: cellSize * 0.4,
      color: NeonColors.textSecondary,
      letterSpacing: 1,
    );

    // Nivel
    _drawText(canvas, 'NIVEL $level', width - offsetX - cellSize * 6, y + cellSize * 0.2, levelStyle);

    // Nombre del mapa
    _drawText(canvas, GameMap.getMapNameStatic(0), width - offsetX - cellSize * 6, y + cellSize * 0.6, mapNameStyle);

    // Combo (si hay)
    if (combo > 1) {
      final comboStyle = TextStyle(
        fontFamily: TextStyles.neonFont,
        fontSize: cellSize * 0.8,
        fontWeight: FontWeight.bold,
        color: Colors.orange,
        letterSpacing: 3,
        shadows: [
          Shadow(
            color: Colors.orange.withOpacity(0.5),
            blurRadius: 10,
          ),
        ],
      );

      _drawText(canvas, 'COMBO x$combo!', width / 2 - cellSize * 3, y + cellSize * 0.2, comboStyle);
    }
  }

  /// Dibuja texto en el canvas
  void _drawText(Canvas canvas, String text, double x, double y, TextStyle style) {
    final textPainter = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(x, y));
  }

  @override
  bool shouldRepaint(covariant GamePainter oldDelegate) {
    // La optimización clave: solo repintar si algo realmente ha cambiado.
    // Esto evita repintados innecesarios y mejora drásticamente el rendimiento.
    return oldDelegate.pacmanX != pacmanX ||
        oldDelegate.pacmanY != pacmanY ||
        oldDelegate.pacmanDir != pacmanDir ||
        oldDelegate.animationTick != animationTick ||
        oldDelegate.gameState != gameState ||
        oldDelegate.score != score ||
        oldDelegate.lives != lives ||
        oldDelegate.frightenedTimer != frightenedTimer ||
        !listEquals(oldDelegate.ghosts, ghosts) ||
        (enableParticles && particleSystem.isActive) ||
        (enableScreenShake && screenShake.isActive) ||
        shockwave.isActive;
  }
}
