import 'constants.dart';

class GameMap {
  // Classic Pac-Man map layout (28x31)
  // 0=empty, 1=wall, 2=dot, 3=power pellet, 4=ghost door, 5=tunnel
  static const List<List<int>> originalLayout = [
    [1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1],
    [1,2,2,2,2,2,2,2,2,2,2,2,2,1,1,2,2,2,2,2,2,2,2,2,2,2,2,1],
    [1,2,1,1,1,1,2,1,1,1,1,1,2,1,1,2,1,1,1,1,1,2,1,1,1,1,2,1],
    [1,3,1,1,1,1,2,1,1,1,1,1,2,1,1,2,1,1,1,1,1,2,1,1,1,1,3,1],
    [1,2,1,1,1,1,2,1,1,1,1,1,2,1,1,2,1,1,1,1,1,2,1,1,1,1,2,1],
    [1,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,1],
    [1,2,1,1,1,1,2,1,1,2,1,1,1,1,1,1,1,1,2,1,1,2,1,1,1,1,2,1],
    [1,2,1,1,1,1,2,1,1,2,1,1,1,1,1,1,1,1,2,1,1,2,1,1,1,1,2,1],
    [1,2,2,2,2,2,2,1,1,2,2,2,2,1,1,2,2,2,2,1,1,2,2,2,2,2,2,1],
    [1,1,1,1,1,1,2,1,1,1,1,1,0,1,1,0,1,1,1,1,1,2,1,1,1,1,1,1],
    [0,0,0,0,0,1,2,1,1,1,1,1,0,1,1,0,1,1,1,1,1,2,1,0,0,0,0,0],
    [0,0,0,0,0,1,2,1,1,0,0,0,0,0,0,0,0,0,0,1,1,2,1,0,0,0,0,0],
    [0,0,0,0,0,1,2,1,1,0,1,1,1,4,4,1,1,1,0,1,1,2,1,0,0,0,0,0],
    [1,1,1,1,1,1,2,1,1,0,1,0,0,0,0,0,0,1,0,1,1,2,1,1,1,1,1,1],
    [5,0,0,0,0,0,2,0,0,0,1,0,0,0,0,0,0,1,0,0,0,2,0,0,0,0,0,5],
    [1,1,1,1,1,1,2,1,1,0,1,0,0,0,0,0,0,1,0,1,1,2,1,1,1,1,1,1],
    [0,0,0,0,0,1,2,1,1,0,1,1,1,1,1,1,1,1,0,1,1,2,1,0,0,0,0,0],
    [0,0,0,0,0,1,2,1,1,0,0,0,0,0,0,0,0,0,0,1,1,2,1,0,0,0,0,0],
    [0,0,0,0,0,1,2,1,1,0,1,1,1,1,1,1,1,1,0,1,1,2,1,0,0,0,0,0],
    [1,1,1,1,1,1,2,1,1,0,1,1,1,1,1,1,1,1,0,1,1,2,1,1,1,1,1,1],
    [1,2,2,2,2,2,2,2,2,2,2,2,2,1,1,2,2,2,2,2,2,2,2,2,2,2,2,1],
    [1,2,1,1,1,1,2,1,1,1,1,1,2,1,1,2,1,1,1,1,1,2,1,1,1,1,2,1],
    [1,2,1,1,1,1,2,1,1,1,1,1,2,1,1,2,1,1,1,1,1,2,1,1,1,1,2,1],
    [1,3,2,2,1,1,2,2,2,2,2,2,2,0,0,2,2,2,2,2,2,2,1,1,2,2,3,1],
    [1,1,1,2,1,1,2,1,1,2,1,1,1,1,1,1,1,1,2,1,1,2,1,1,2,1,1,1],
    [1,1,1,2,1,1,2,1,1,2,1,1,1,1,1,1,1,1,2,1,1,2,1,1,2,1,1,1],
    [1,2,2,2,2,2,2,1,1,2,2,2,2,1,1,2,2,2,2,1,1,2,2,2,2,2,2,1],
    [1,2,1,1,1,1,1,1,1,1,1,1,2,1,1,2,1,1,1,1,1,1,1,1,1,1,2,1],
    [1,2,1,1,1,1,1,1,1,1,1,1,2,1,1,2,1,1,1,1,1,1,1,1,1,1,2,1],
    [1,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,1],
    [1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1],
  ];

  List<List<int>> layout = [];
  int totalDots = 0;
  int dotsEaten = 0;

  GameMap() {
    resetMap();
  }

  // Pac-Man start position
  static const double pacmanStartX = 13.5;
  static const double pacmanStartY = 23.0;

  // Ghost start positions (inside ghost house)
  static const double blinkyStartX = 13.5;
  static const double blinkyStartY = 11.0; // Blinky starts outside
  static const double pinkyStartX = 13.5;
  static const double pinkyStartY = 14.0;
  static const double inkyStartX = 11.5;
  static const double inkyStartY = 14.0;
  static const double clydeStartX = 15.5;
  static const double clydeStartY = 14.0;

  // Ghost house exit
  static const double ghostExitX = 13.5;
  static const double ghostExitY = 11.0;

  // Ghost scatter targets (corners)
  static const List<List<int>> scatterTargets = [
    [25, -3],  // Blinky - top right
    [2, -3],   // Pinky - top left
    [27, 31],  // Inky - bottom right
    [0, 31],   // Clyde - bottom left
  ];

  // Tunnel positions
  static const int tunnelY = 14;
  static const int tunnelLeftX = 0;
  static const int tunnelRightX = 27;

  void resetMap() {
    layout = originalLayout.map((row) => List<int>.from(row)).toList();
    totalDots = 0;
    dotsEaten = 0;
    for (var row in layout) {
      for (var cell in row) {
        if (cell == kDot || cell == kPowerPellet) {
          totalDots++;
        }
      }
    }
  }

  bool isWall(int x, int y) {
    if (y < 0 || y >= kMapHeight) return true;
    // Tunnel wrapping
    if (x < 0 || x >= kMapWidth) {
      if (y == tunnelY) return false;
      return true;
    }
    return layout[y][x] == kWall;
  }

  bool isGhostDoor(int x, int y) {
    if (x < 0 || x >= kMapWidth || y < 0 || y >= kMapHeight) return false;
    return layout[y][x] == kGhostDoor;
  }

  bool canMove(int x, int y, {bool isGhost = false, bool isEaten = false}) {
    if (y < 0 || y >= kMapHeight) return false;
    // Tunnel wrapping
    if (x < 0 || x >= kMapWidth) {
      if (y == tunnelY) return true;
      return false;
    }
    int tile = layout[y][x];
    if (tile == kWall) return false;
    if (tile == kGhostDoor) return isGhost || isEaten;
    return true;
  }

  int eatDot(int x, int y) {
    if (x < 0 || x >= kMapWidth || y < 0 || y >= kMapHeight) return 0;
    int tile = layout[y][x];
    if (tile == kDot) {
      layout[y][x] = kEmpty;
      dotsEaten++;
      return kDotPoints;
    } else if (tile == kPowerPellet) {
      layout[y][x] = kEmpty;
      dotsEaten++;
      return kPowerPelletPoints;
    }
    return 0;
  }

  bool isPowerPellet(int x, int y) {
    if (x < 0 || x >= kMapWidth || y < 0 || y >= kMapHeight) return false;
    return layout[y][x] == kPowerPellet;
  }

  bool allDotsEaten() => dotsEaten >= totalDots;

  int wrapX(int x) {
    if (x < 0) return kMapWidth - 1;
    if (x >= kMapWidth) return 0;
    return x;
  }
}
