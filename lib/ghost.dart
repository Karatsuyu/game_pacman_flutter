import 'dart:math';
import 'package:flutter/material.dart';
import 'constants.dart';
import 'game_map.dart';

class Ghost {
  double x, y;
  double startX, startY;
  Direction direction;
  Direction nextDirection;
  GhostMode mode;
  final Color color;
  final int index; // 0=Blinky, 1=Pinky, 2=Inky, 3=Clyde
  int frightenedTimer = 0;
  int respawnTimer = 0;
  int dotCounter = 0;
  bool isActive = false;
  final Random _random = Random();

  // Dot limits for ghost to leave house
  static const List<int> dotLimitsToLeave = [0, 0, 30, 60];

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

  void reset() {
    x = startX;
    y = startY;
    direction = Direction.up;
    nextDirection = Direction.up;
    mode = index == 0 ? GhostMode.scatter : GhostMode.inHouse;
    frightenedTimer = 0;
    respawnTimer = 0;
    isActive = index == 0;
    dotCounter = 0;
  }

  void setFrightened(int durationMs) {
    if (mode != GhostMode.eaten && mode != GhostMode.inHouse) {
      mode = GhostMode.frightened;
      frightenedTimer = durationMs;
      // Reverse direction when frightened
      direction = _reverseDirection(direction);
    }
  }

  void update(GameMap gameMap, double pacmanX, double pacmanY,
      Direction pacmanDir, Ghost? blinky, int totalDotsEaten, GhostMode globalMode,
      double speed, double frightenedSpeed, double tunnelSpeed) {

    if (mode == GhostMode.inHouse) {
      _handleInHouse(totalDotsEaten);
      return;
    }

    if (mode == GhostMode.exitingHouse) {
      _exitHouse(gameMap);
      return;
    }

    // Determine actual speed
    double currentSpeed = speed;
    if (mode == GhostMode.frightened) {
      currentSpeed = frightenedSpeed;
    } else if (mode == GhostMode.eaten) {
      currentSpeed = speed * 1.5; // eaten ghosts move faster
    }

    // Check if in tunnel
    if ((x < 5 || x > 22) && y.round() == GameMap.tunnelY) {
      if (mode != GhostMode.eaten) {
        currentSpeed = tunnelSpeed;
      }
    }

    // Get target tile
    List<int> target = _getTarget(pacmanX, pacmanY, pacmanDir, blinky, globalMode);

    // Move ghost
    _moveTowardsTarget(gameMap, target[0], target[1], currentSpeed);

    // Handle tunnel wrapping
    if (x < -1) x = kMapWidth.toDouble();
    if (x > kMapWidth) x = -1.0;

    // Check if eaten ghost reached home
    if (mode == GhostMode.eaten) {
      if ((x - GameMap.ghostExitX).abs() < 0.5 && (y - GameMap.ghostExitY).abs() < 0.5) {
        x = GameMap.ghostExitX;
        y = GameMap.ghostExitY;
        mode = GhostMode.exitingHouse;
      }
    }
  }

  void _handleInHouse(int totalDotsEaten) {
    int limit = dotLimitsToLeave[index.clamp(0, 3)];
    if (totalDotsEaten >= limit) {
      mode = GhostMode.exitingHouse;
    }
    // Bob up and down in house
    double bobSpeed = 0.03;
    if (direction == Direction.up) {
      y -= bobSpeed;
      if (y < 13.0) direction = Direction.down;
    } else {
      y += bobSpeed;
      if (y > 15.0) direction = Direction.up;
    }
  }

  void _exitHouse(GameMap gameMap) {
    double targetX = GameMap.ghostExitX;
    double targetY = GameMap.ghostExitY;
    double moveSpeed = 0.05;

    // Move to center first
    if ((x - targetX).abs() > 0.1) {
      x += (targetX - x).sign * moveSpeed;
    } else if ((y - targetY).abs() > 0.1) {
      y += (targetY - y).sign * moveSpeed;
    } else {
      x = targetX;
      y = targetY;
      mode = GhostMode.scatter;
      direction = Direction.left;
      isActive = true;
    }
  }

  List<int> _getTarget(double pacmanX, double pacmanY, Direction pacmanDir,
      Ghost? blinky, GhostMode globalMode) {

    if (mode == GhostMode.eaten) {
      return [GameMap.ghostExitX.round(), GameMap.ghostExitY.round()];
    }

    if (mode == GhostMode.frightened) {
      return [_random.nextInt(kMapWidth), _random.nextInt(kMapHeight)];
    }

    if (mode == GhostMode.scatter || globalMode == GhostMode.scatter) {
      return GameMap.scatterTargets[index];
    }

    // Chase mode - each ghost has different targeting
    int px = pacmanX.round();
    int py = pacmanY.round();

    switch (index) {
      case 0: // Blinky - directly targets Pac-Man
        return [px, py];

      case 1: // Pinky - targets 4 tiles ahead of Pac-Man
        int targetX = px;
        int targetY = py;
        switch (pacmanDir) {
          case Direction.up:
            targetY -= 4;
            targetX -= 4; // Original bug recreation
            break;
          case Direction.down:
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
        return [targetX, targetY];

      case 2: // Inky - complex targeting using Blinky's position
        if (blinky != null) {
          int aheadX = px;
          int aheadY = py;
          switch (pacmanDir) {
            case Direction.up:
              aheadY -= 2;
              break;
            case Direction.down:
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
          int targetX = aheadX + (aheadX - blinky.x.round());
          int targetY = aheadY + (aheadY - blinky.y.round());
          return [targetX, targetY];
        }
        return [px, py];

      case 3: // Clyde - targets Pac-Man when far, scatter when close
        double dist = sqrt(pow(x - pacmanX, 2) + pow(y - pacmanY, 2));
        if (dist > 8) {
          return [px, py];
        } else {
          return GameMap.scatterTargets[3];
        }

      default:
        return [px, py];
    }
  }

  void _moveTowardsTarget(GameMap gameMap, int targetX, int targetY, double speed) {
    int cx = x.round();
    int cy = y.round();

    // Only make decisions at grid intersections
    bool atIntersection = (x - cx).abs() < 0.1 && (y - cy).abs() < 0.1;

    if (atIntersection) {
      x = cx.toDouble();
      y = cy.toDouble();

      // Find best direction
      Direction bestDir = direction;
      double bestDist = double.infinity;
      Direction reverse = _reverseDirection(direction);

      for (Direction dir in [Direction.up, Direction.left, Direction.down, Direction.right]) {
        if (dir == reverse) continue; // Can't reverse

        int nx = cx + _dirX(dir);
        int ny = cy + _dirY(dir);

        bool canGo = gameMap.canMove(nx, ny,
            isGhost: mode != GhostMode.frightened,
            isEaten: mode == GhostMode.eaten);

        if (canGo) {
          double dist = pow(nx - targetX, 2).toDouble() + pow(ny - targetY, 2).toDouble();
          if (dist < bestDist) {
            bestDist = dist;
            bestDir = dir;
          }
        }
      }

      direction = bestDir;
    }

    // Apply movement
    x += _dirX(direction) * speed;
    y += _dirY(direction) * speed;
  }

  Direction _reverseDirection(Direction dir) {
    switch (dir) {
      case Direction.up: return Direction.down;
      case Direction.down: return Direction.up;
      case Direction.left: return Direction.right;
      case Direction.right: return Direction.left;
      case Direction.none: return Direction.none;
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

  bool checkCollision(double pacX, double pacY) {
    if (mode == GhostMode.inHouse || mode == GhostMode.exitingHouse) return false;
    double dist = sqrt(pow(x - pacX, 2) + pow(y - pacY, 2));
    return dist < 0.8;
  }
}
