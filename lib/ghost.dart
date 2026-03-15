import 'dart:math';
import 'package:flutter/material.dart';
import 'constants.dart';
import 'game_map.dart';

/// ============================================================================
/// GHOST - FANTASMAS CON COMPORTAMIENTOS MEJORADOS
/// Cada fantasma tiene personalidad única y estrategias de persecución
/// ============================================================================

class Ghost {
  // Posición
  double x, y;
  double startX, startY;

  // Dirección y movimiento
  Direction direction;
  Direction nextDirection;

  // Estado
  GhostMode mode;
  final Color color;
  final int index; // 0=Blinky, 1=Pinky, 2=Inky, 3=Clyde

  // Temporizadores
  int frightenedTimer = 0;
  int respawnTimer = 0;
  int freezeTimer = 0;
  int houseWaitTimer = 0;

  // Contadores
  int dotCounter = 0;

  // Estado de actividad
  bool isActive = false;
  bool hasExitedHouse = false;

  // Efectos visuales
  double bounceOffset = 0;
  double glowIntensity = 1.0;

  // Random
  final Random _random = Random();

  // Límites de puntos para salir de la casa
  static const List<int> dotLimitsToLeave = [0, 0, 30, 60];

  // Nombres de los fantasmas
  static const List<String> ghostNames = ['BLINKY', 'PINKY', 'INKY', 'CLYDE'];

  Ghost({
    required this.x,
    required this.y,
    required this.color,
    required this.index,
  })  : startX = x,
        startY = y,
        direction = Direction.up,
        nextDirection = Direction.up,
        mode = index == 0 ? GhostMode.scatter : GhostMode.inHouse;

  /// Reinicia el fantasma a su posición inicial
  void reset() {
    x = startX;
    y = startY;
    direction = Direction.up;
    nextDirection = Direction.up;
    mode = index == 0 ? GhostMode.scatter : GhostMode.inHouse;
    frightenedTimer = 0;
    respawnTimer = 0;
    freezeTimer = 0;
    houseWaitTimer = 0;
    isActive = index == 0;
    hasExitedHouse = false;
    dotCounter = 0;
    bounceOffset = 0;
    glowIntensity = 1.0;
  }

  /// Obtiene el nombre del fantasma
  String get name => Ghost.ghostNames[index];

  /// Establece el modo asustado
  void setFrightened(int durationMs) {
    if (mode != GhostMode.eaten &&
        mode != GhostMode.inHouse &&
        mode != GhostMode.exitingHouse &&
        mode != GhostMode.frozen) {
      mode = GhostMode.frightened;
      frightenedTimer = durationMs;
      // Revertir dirección
      direction = _reverseDirection(direction);
    }
  }

  /// Establece el modo congelado
  void setFrozen(int durationMs) {
    if (mode != GhostMode.eaten &&
        mode != GhostMode.inHouse &&
        mode != GhostMode.exitingHouse) {
      mode = GhostMode.frozen;
      freezeTimer = durationMs;
    }
  }

  /// Actualiza el estado del fantasma
  void update(
    GameMap gameMap,
    double pacmanX,
    double pacmanY,
    Direction pacmanDir,
    Ghost? blinky,
    int totalDotsEaten,
    GhostMode globalMode,
    double speed,
    double frightenedSpeed,
    double tunnelSpeed,
    double frozenSpeed,
  ) {
    // Manejar estado en la casa
    if (mode == GhostMode.inHouse) {
      _handleInHouse(totalDotsEaten);
      return;
    }

    // Manejar salida de la casa
    if (mode == GhostMode.exitingHouse) {
      _exitHouse(speed);
      return;
    }

    // Manejar congelamiento
    if (mode == GhostMode.frozen) {
      freezeTimer -= 16;
      if (freezeTimer <= 0) {
        mode = globalMode;
      }
      return;
    }

    // Determinar velocidad actual
    double currentSpeed = _calculateSpeed(
      speed,
      frightenedSpeed,
      tunnelSpeed,
      frozenSpeed,
    );

    // Obtener objetivo
    List<int> target = _getTarget(
      pacmanX,
      pacmanY,
      pacmanDir,
      blinky,
      globalMode,
    );

    // Mover hacia el objetivo
    _moveTowardsTarget(gameMap, target[0], target[1], currentSpeed);

    // Verificar si llegó a casa (fantasma comido)
    if (mode == GhostMode.eaten) {
      _checkReachedHome();
    }
  }

  /// Calcula la velocidad actual basada en el estado
  double _calculateSpeed(
    double baseSpeed,
    double frightenedSpeed,
    double tunnelSpeed,
    double frozenSpeed,
  ) {
    if (mode == GhostMode.frozen) return frozenSpeed;
    if (mode == GhostMode.frightened) return frightenedSpeed;
    if (mode == GhostMode.eaten) return baseSpeed * 1.5;
    // Blinky es más rápido
    if (index == 0) return baseSpeed * 1.1;
    return baseSpeed;
  }

  /// Maneja el movimiento en la casa de fantasmas
  void _handleInHouse(int totalDotsEaten) {
    int limit = dotLimitsToLeave[index.clamp(0, 3)];

    if (totalDotsEaten >= limit) {
      mode = GhostMode.exitingHouse;
      return;
    }

    // Animación de espera en la casa
    houseWaitTimer++;
    double bobSpeed = 0.02;
    double bobAmount = sin(houseWaitTimer * 0.1) * bobSpeed;
    y += bobAmount;

    // Límites de movimiento vertical en la casa
    double minY = 13.5;
    double maxY = 14.5;
    y = y.clamp(minY, maxY);
  }

  /// Maneja la salida de la casa
  void _exitHouse(double speed) {
    double targetX = GameMap.ghostExitX;
    double targetY = GameMap.ghostExitY;
    double moveSpeed = speed * 0.8;

    // Mover hacia la salida
    double dx = targetX - x;
    double dy = targetY - y;
    double distance = sqrt(dx * dx + dy * dy);

    if (distance > 0.3) {
      x += (dx / distance) * moveSpeed;
      y += (dy / distance) * moveSpeed;
    } else {
      x = targetX;
      y = targetY;
      mode = GhostMode.scatter;
      direction = Direction.left;
      isActive = true;
      hasExitedHouse = true;
    }
  }

  /// Obtiene el objetivo de movimiento
  List<int> _getTarget(
    double pacmanX,
    double pacmanY,
    Direction pacmanDir,
    Ghost? blinky,
    GhostMode globalMode,
  ) {
    // Si fue comido, volver a casa
    if (mode == GhostMode.eaten) {
      return [GameMap.ghostExitX.round(), GameMap.ghostExitY.round()];
    }

    // Si está asustado, objetivo aleatorio
    if (mode == GhostMode.frightened) {
      return [_random.nextInt(kMapWidth), _random.nextInt(kMapHeight)];
    }

    // Si está congelado, quedarse quieto
    if (mode == GhostMode.frozen) {
      return [x.round(), y.round()];
    }

    // Modo scatter (esquinas)
    if (mode == GhostMode.scatter || globalMode == GhostMode.scatter) {
      return GameMap.scatterTargets[index];
    }

    // Modo chase - cada fantasma tiene estrategia única
    return _getChaseTarget(pacmanX, pacmanY, pacmanDir, blinky);
  }

  /// Obtiene el objetivo en modo persecución
  List<int> _getChaseTarget(
    double pacmanX,
    double pacmanY,
    Direction pacmanDir,
    Ghost? blinky,
  ) {
    int px = pacmanX.round();
    int py = pacmanY.round();

    switch (index) {
      case 0: // BLINKY - Perseguidor directo
        return [px, py];

      case 1: // PINKY - Emboscador (4 casillas adelante)
        int targetX = px;
        int targetY = py;
        switch (pacmanDir) {
          case Direction.up:
            targetX -= 4;
            targetY -= 4;
            break;
          case Direction.down:
            targetX += 4;
            targetY += 4;
            break;
          case Direction.left:
            targetX -= 4;
            break;
          case Direction.right:
            targetX += 4;
            break;
          case Direction.none:
            break;
        }
        return [
          targetX.clamp(0, kMapWidth - 1),
          targetY.clamp(0, kMapHeight - 1)
        ];

      case 2: // INKY - Impredecible (usa posición de Blinky)
        int aheadX = px;
        int aheadY = py;
        switch (pacmanDir) {
          case Direction.up:
            aheadX -= 2;
            aheadY -= 2;
            break;
          case Direction.down:
            aheadX += 2;
            aheadY += 2;
            break;
          case Direction.left:
            aheadX -= 2;
            break;
          case Direction.right:
            aheadX += 2;
            break;
          case Direction.none:
            break;
        }
        if (blinky != null) {
          int finalX = aheadX + (aheadX - blinky.x.round());
          int finalY = aheadY + (aheadY - blinky.y.round());
          return [
            finalX.clamp(0, kMapWidth - 1),
            finalY.clamp(0, kMapHeight - 1)
          ];
        }
        return [aheadX, aheadY];

      case 3: // CLYDE - Aleatorio (persigue si lejos, scatter si cerca)
        double dist = sqrt(
          pow(x - pacmanX, 2) + pow(y - pacmanY, 2),
        );
        if (dist > 8) {
          return [px, py];
        } else {
          return GameMap.scatterTargets[3];
        }

      default:
        return [px, py];
    }
  }

  /// Mueve el fantasma hacia el objetivo
  void _moveTowardsTarget(
    GameMap gameMap,
    int targetX,
    int targetY,
    double speed,
  ) {
    // Solo tomar decisiones en intersecciones (cuando está cerca del centro de una celda)
    int cx = x.round();
    int cy = y.round();

    // Verificar si está lo suficientemente cerca del centro de la celda
    bool atIntersection = (x - cx).abs() < 0.1 && (y - cy).abs() < 0.1;

    if (atIntersection) {
      // Centrar exactamente en la celda
      x = cx.toDouble();
      y = cy.toDouble();

      // Encontrar la mejor dirección
      Direction bestDir = direction;
      double bestDist = double.infinity;
      Direction reverse = _reverseDirection(direction);

      List<Direction> validDirs = [
        Direction.up,
        Direction.left,
        Direction.down,
        Direction.right,
      ];

      for (Direction dir in validDirs) {
        if (dir == reverse) continue; // No puede reversar

        int nx = cx + _dirX(dir);
        int ny = cy + _dirY(dir);

        // Manejo especial para el túnel
        if (ny == GameMap.tunnelY && (nx < 0 || nx >= kMapWidth)) {
            // Permite el movimiento en el túnel
        } else if (!gameMap.canMove(
          nx,
          ny,
          isGhost: mode != GhostMode.frightened && mode != GhostMode.frozen,
          isEaten: mode == GhostMode.eaten,
        )) {
            continue; // No puede moverse a esta celda
        }

        double dist = pow(nx - targetX, 2).toDouble() +
            pow(ny - targetY, 2).toDouble();

        // Añadir algo de aleatoriedad para Inky cuando está asustado
        if (mode == GhostMode.frightened && index == 2) {
          dist += _random.nextDouble() * 10;
        }

        if (dist < bestDist) {
          bestDist = dist;
          bestDir = dir;
        }
      }

      direction = bestDir;
    }

    // Aplicar movimiento
    double dx = _dirX(direction) * speed;
    double dy = _dirY(direction) * speed;
    
    x += dx;
    y += dy;

    // Manejar túnel
    if (y.round() == GameMap.tunnelY) {
      if (x < -1) {
        x = kMapWidth.toDouble();
      } else if (x > kMapWidth) {
        x = -1.0;
      }
    } else {
      // Mantener dentro de los límites del mapa
      x = x.clamp(0.0, kMapWidth - 1.0);
      y = y.clamp(0.0, kMapHeight - 1.0);
    }
  }

  /// Verifica si el fantasma comido llegó a casa
  void _checkReachedHome() {
    double distToHome = sqrt(
      pow(x - GameMap.ghostExitX, 2) + pow(y - GameMap.ghostExitY, 2),
    );

    if (distToHome < 0.5) {
      x = GameMap.ghostExitX;
      y = GameMap.ghostExitY;
      mode = GhostMode.exitingHouse;
    }
  }

  /// Revierte la dirección
  Direction _reverseDirection(Direction dir) {
    switch (dir) {
      case Direction.up:
        return Direction.down;
      case Direction.down:
        return Direction.up;
      case Direction.left:
        return Direction.right;
      case Direction.right:
        return Direction.left;
      case Direction.none:
        return Direction.none;
    }
  }

  int _dirX(Direction dir) {
    if (dir == Direction.left) return -1;
    if (dir == Direction.right) return 1;
    return 0;
  }

  int _dirY(Direction dir) {
    if (dir == Direction.up) return -1;
    if (dir == Direction.down) return 1;
    return 0;
  }

  /// Verifica colisión con Pac-Man
  bool checkCollision(double pacX, double pacY) {
    if (mode == GhostMode.inHouse ||
        mode == GhostMode.exitingHouse ||
        mode == GhostMode.frozen) {
      return false;
    }

    double dist = sqrt(pow(x - pacX, 2) + pow(y - pacY, 2));
    return dist < 0.7;
  }

  /// Obtiene el radio de colisión
  double get collisionRadius => 0.5;

  /// Obtiene el factor de escala para animación
  double get scale => 1.0 + (bounceOffset * 0.05);
}
