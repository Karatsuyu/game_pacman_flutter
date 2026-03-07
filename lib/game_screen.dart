import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'constants.dart';
import 'game_map.dart';
import 'ghost.dart';
import 'game_painter.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with TickerProviderStateMixin {
  // Game state
  GameState gameState = GameState.menu;
  final GameMap gameMap = GameMap();
  int score = 0;
  int highScore = 0;
  int lives = kInitialLives;
  int level = 1;
  int ghostsEatenCombo = 0;
  bool extraLifeAwarded = false;

  // Pac-Man
  double pacmanX = GameMap.pacmanStartX;
  double pacmanY = GameMap.pacmanStartY;
  Direction pacmanDir = Direction.left;
  Direction pacmanNextDir = Direction.left;
  double pacmanSpeed = 0.08;

  // Ghosts
  late List<Ghost> ghosts;
  GhostMode globalGhostMode = GhostMode.scatter;
  int modePhaseIndex = 0;
  int modeTimer = 0;

  // Frightened mode
  int frightenedTimer = 0;

  // Fruit
  bool showFruit = false;
  int fruitTimer = 0;
  bool firstFruitShown = false;
  bool secondFruitShown = false;

  // Animation
  double animationTick = 0;
  Timer? gameTimer;
  int readyTimer = 0;
  int deathAnimTimer = 0;
  int levelCompleteTimer = 0;

  // Touch
  Offset? touchStart;

  @override
  void initState() {
    super.initState();
    gameMap.resetMap();
    _initGhosts();
  }

  void _initGhosts() {
    ghosts = [
      Ghost(x: GameMap.blinkyStartX, y: GameMap.blinkyStartY, color: kBlinkyColor, index: 0),
      Ghost(x: GameMap.pinkyStartX, y: GameMap.pinkyStartY, color: kPinkyColor, index: 1),
      Ghost(x: GameMap.inkyStartX, y: GameMap.inkyStartY, color: kInkyColor, index: 2),
      Ghost(x: GameMap.clydeStartX, y: GameMap.clydeStartY, color: kClydeColor, index: 3),
    ];
  }

  void _startGame() {
    gameMap.resetMap();
    score = 0;
    lives = kInitialLives;
    level = 1;
    extraLifeAwarded = false;
    _resetPositions();
    _startReady();
  }

  void _startReady() {
    gameState = GameState.ready;
    readyTimer = kReadyDurationMs;
    _startGameLoop();
  }

  void _resetPositions() {
    pacmanX = GameMap.pacmanStartX;
    pacmanY = GameMap.pacmanStartY;
    pacmanDir = Direction.left;
    pacmanNextDir = Direction.left;

    for (var ghost in ghosts) {
      ghost.reset();
    }

    globalGhostMode = GhostMode.scatter;
    modePhaseIndex = 0;
    modeTimer = 0;
    frightenedTimer = 0;
    ghostsEatenCombo = 0;
    showFruit = false;
    fruitTimer = 0;
    firstFruitShown = false;
    secondFruitShown = false;
  }

  void _startGameLoop() {
    gameTimer?.cancel();
    gameTimer = Timer.periodic(const Duration(milliseconds: 16), (timer) {
      setState(() {
        animationTick += 1;
        _update(16);
      });
    });
  }

  void _update(int deltaMs) {
    switch (gameState) {
      case GameState.ready:
        readyTimer -= deltaMs;
        if (readyTimer <= 0) {
          gameState = GameState.playing;
        }
        break;

      case GameState.playing:
        _updatePlaying(deltaMs);
        break;

      case GameState.dying:
        deathAnimTimer -= deltaMs;
        if (deathAnimTimer <= 0) {
          lives--;
          if (lives <= 0) {
            gameState = GameState.gameOver;
            if (score > highScore) highScore = score;
          } else {
            _resetPositionsOnly();
            _startReady();
          }
        }
        break;

      case GameState.levelComplete:
        levelCompleteTimer -= deltaMs;
        if (levelCompleteTimer <= 0) {
          level++;
          gameMap.resetMap();
          _resetPositions();
          _startReady();
        }
        break;

      case GameState.gameOver:
      case GameState.menu:
      case GameState.paused:
        break;
    }
  }

  void _resetPositionsOnly() {
    pacmanX = GameMap.pacmanStartX;
    pacmanY = GameMap.pacmanStartY;
    pacmanDir = Direction.left;
    pacmanNextDir = Direction.left;
    for (var ghost in ghosts) {
      ghost.reset();
    }
    globalGhostMode = GhostMode.scatter;
    modePhaseIndex = 0;
    modeTimer = 0;
    frightenedTimer = 0;
    ghostsEatenCombo = 0;
  }

  void _updatePlaying(int deltaMs) {
    final config = getLevelConfig(level);
    pacmanSpeed = config.pacmanSpeed * 0.08;

    // Update ghost mode timer
    _updateGhostMode(deltaMs, config);

    // Update frightened timer
    if (frightenedTimer > 0) {
      frightenedTimer -= deltaMs;
      if (frightenedTimer <= 0) {
        frightenedTimer = 0;
        ghostsEatenCombo = 0;
        for (var ghost in ghosts) {
          if (ghost.mode == GhostMode.frightened) {
            ghost.mode = globalGhostMode;
          }
        }
      }
    }

    // Move Pac-Man
    _movePacman();

    // Eat dots
    int gridX = pacmanX.round();
    int gridY = pacmanY.round();
    if (gridX >= 0 && gridX < kMapWidth && gridY >= 0 && gridY < kMapHeight) {
      bool wasPowerPellet = gameMap.isPowerPellet(gridX, gridY);
      int points = gameMap.eatDot(gridX, gridY);
      if (points > 0) {
        score += points;
        if (wasPowerPellet) {
          _activateFrightened(config);
        }
      }
    }

    // Check fruit
    _updateFruit(deltaMs);

    // Extra life
    if (!extraLifeAwarded && score >= kExtraLifeScore) {
      extraLifeAwarded = true;
      if (lives < kMaxLives) lives++;
    }

    // Update ghosts
    for (var ghost in ghosts) {
      ghost.update(
        gameMap, pacmanX, pacmanY, pacmanDir,
        ghosts[0], gameMap.dotsEaten, globalGhostMode,
        config.ghostSpeed * 0.08,
        config.frightenedGhostSpeed * 0.08,
        config.tunnelGhostSpeed * 0.08,
      );
    }

    // Check ghost collisions
    for (var ghost in ghosts) {
      if (ghost.checkCollision(pacmanX, pacmanY)) {
        if (ghost.mode == GhostMode.frightened) {
          // Eat ghost
          ghost.mode = GhostMode.eaten;
          int combo = ghostsEatenCombo.clamp(0, 3);
          score += kGhostPoints[combo];
          ghostsEatenCombo++;
        } else if (ghost.mode != GhostMode.eaten) {
          // Pac-Man dies
          _pacmanDie();
          return;
        }
      }
    }

    // Check level complete
    if (gameMap.allDotsEaten()) {
      gameState = GameState.levelComplete;
      levelCompleteTimer = kLevelTransitionMs;
    }
  }

  void _updateGhostMode(int deltaMs, LevelConfig config) {
    if (frightenedTimer > 0) return;

    modeTimer += deltaMs;

    List<int> scatterDurs = config.scatterDurations;
    List<int> chaseDurs = config.chaseDurations;

    int phaseIndex = modePhaseIndex;
    if (phaseIndex < scatterDurs.length) {
      bool isScatter = phaseIndex % 2 == 0;

      // Remap so even = scatter, odd = chase
      int scatterIdx = phaseIndex ~/ 2;
      int chaseIdx = phaseIndex ~/ 2;

      int duration;
      if (isScatter && scatterIdx < scatterDurs.length) {
        duration = scatterDurs[scatterIdx];
      } else if (!isScatter && chaseIdx < chaseDurs.length) {
        duration = chaseDurs[chaseIdx];
        if (duration == -1) return; // permanent chase
      } else {
        return;
      }

      if (modeTimer >= duration && duration > 0) {
        modeTimer = 0;
        modePhaseIndex++;
        globalGhostMode = (modePhaseIndex % 2 == 0) ? GhostMode.scatter : GhostMode.chase;
        // Reverse all active ghost directions
        for (var ghost in ghosts) {
          if (ghost.mode != GhostMode.frightened &&
              ghost.mode != GhostMode.eaten &&
              ghost.mode != GhostMode.inHouse &&
              ghost.mode != GhostMode.exitingHouse) {
            ghost.mode = globalGhostMode;
          }
        }
      }
    }
  }

  void _activateFrightened(LevelConfig config) {
    frightenedTimer = config.frightenedDuration;
    ghostsEatenCombo = 0;
    for (var ghost in ghosts) {
      ghost.setFrightened(config.frightenedDuration);
    }
  }

  void _updateFruit(int deltaMs) {
    if (showFruit) {
      fruitTimer -= deltaMs;
      if (fruitTimer <= 0) {
        showFruit = false;
      }
      // Check if Pac-Man eats fruit
      if ((pacmanX - 13.5).abs() < 1.0 && (pacmanY - 17.0).abs() < 1.0) {
        int fruitIdx = (level - 1).clamp(0, kFruitPoints.length - 1);
        score += kFruitPoints[fruitIdx];
        showFruit = false;
      }
    } else {
      if (!firstFruitShown && gameMap.dotsEaten >= kDotsForFirstFruit) {
        firstFruitShown = true;
        showFruit = true;
        fruitTimer = 9000;
      } else if (!secondFruitShown && gameMap.dotsEaten >= kDotsForSecondFruit) {
        secondFruitShown = true;
        showFruit = true;
        fruitTimer = 9000;
      }
    }
  }

  void _movePacman() {
    // Try next direction first
    if (pacmanNextDir != pacmanDir) {
      if (_canMoveInDir(pacmanNextDir)) {
        pacmanDir = pacmanNextDir;
      }
    }

    // Move in current direction
    if (_canMoveInDir(pacmanDir)) {
      switch (pacmanDir) {
        case Direction.right:
          pacmanX += pacmanSpeed;
          break;
        case Direction.left:
          pacmanX -= pacmanSpeed;
          break;
        case Direction.up:
          pacmanY -= pacmanSpeed;
          break;
        case Direction.down:
          pacmanY += pacmanSpeed;
          break;
        case Direction.none:
          break;
      }

      // Tunnel wrapping
      if (pacmanX < -1) pacmanX = kMapWidth.toDouble();
      if (pacmanX > kMapWidth) pacmanX = -1.0;
    }
  }

  bool _canMoveInDir(Direction dir) {
    double testX = pacmanX;
    double testY = pacmanY;
    double step = 0.5;

    switch (dir) {
      case Direction.right:
        testX += step;
        break;
      case Direction.left:
        testX -= step;
        break;
      case Direction.up:
        testY -= step;
        break;
      case Direction.down:
        testY += step;
        break;
      case Direction.none:
        return false;
    }

    int gx = testX.round();
    int gy = testY.round();

    // Tunnel
    if (gy == GameMap.tunnelY && (gx < 0 || gx >= kMapWidth)) return true;

    return !gameMap.isWall(gx, gy) && !gameMap.isGhostDoor(gx, gy);
  }

  void _pacmanDie() {
    gameState = GameState.dying;
    deathAnimTimer = kDeathAnimationMs;
  }

  void _changeDirection(Direction dir) {
    if (gameState == GameState.playing) {
      pacmanNextDir = dir;
    }
  }

  @override
  void dispose() {
    gameTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    switch (gameState) {
      case GameState.menu:
        return _buildMenu();
      case GameState.gameOver:
        return _buildGameOver();
      default:
        return _buildGameView();
    }
  }

  Widget _buildMenu() {
    return GestureDetector(
      onTap: () {
        setState(() {
          _startGame();
        });
      },
      child: Container(
        color: Colors.black,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'PAC-MAN',
                style: TextStyle(
                  color: kPacmanColor,
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 8,
                  shadows: [
                    Shadow(
                      color: kPacmanColor.withAlpha(128),
                      blurRadius: 20,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              // Ghost characters preview
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildGhostPreview(kBlinkyColor, 'BLINKY'),
                  const SizedBox(width: 16),
                  _buildGhostPreview(kPinkyColor, 'PINKY'),
                  const SizedBox(width: 16),
                  _buildGhostPreview(kInkyColor, 'INKY'),
                  const SizedBox(width: 16),
                  _buildGhostPreview(kClydeColor, 'CLYDE'),
                ],
              ),
              const SizedBox(height: 50),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                decoration: BoxDecoration(
                  border: Border.all(color: kPacmanColor, width: 2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'TOCA PARA JUGAR',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 3,
                  ),
                ),
              ),
              const SizedBox(height: 30),
              if (highScore > 0)
                Text(
                  'HIGH SCORE: $highScore',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                    letterSpacing: 2,
                  ),
                ),
              const SizedBox(height: 60),
              const Text(
                'DESLIZA PARA MOVER',
                style: TextStyle(
                  color: Colors.white38,
                  fontSize: 14,
                  letterSpacing: 2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGhostPreview(Color color, String name) {
    return Column(
      children: [
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: color,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(15),
              topRight: Radius.circular(15),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          name,
          style: TextStyle(color: color, fontSize: 8, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildGameOver() {
    return GestureDetector(
      onTap: () {
        setState(() {
          gameState = GameState.menu;
        });
      },
      child: Container(
        color: Colors.black,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'GAME OVER',
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 6,
                ),
              ),
              const SizedBox(height: 30),
              Text(
                'SCORE: $score',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  letterSpacing: 3,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'LEVEL: $level',
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 22,
                  letterSpacing: 3,
                ),
              ),
              const SizedBox(height: 10),
              if (score >= highScore && score > 0)
                const Text(
                  '★ NEW HIGH SCORE ★',
                  style: TextStyle(
                    color: kPacmanColor,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
              const SizedBox(height: 50),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white, width: 2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'TOCA PARA CONTINUAR',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    letterSpacing: 2,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGameView() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return KeyboardListener(
          focusNode: FocusNode()..requestFocus(),
          onKeyEvent: (event) {
            if (event is KeyDownEvent) {
              if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
                _changeDirection(Direction.right);
              } else if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
                _changeDirection(Direction.left);
              } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
                _changeDirection(Direction.up);
              } else if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
                _changeDirection(Direction.down);
              } else if (event.logicalKey == LogicalKeyboardKey.space) {
                if (gameState == GameState.playing) {
                  gameState = GameState.paused;
                } else if (gameState == GameState.paused) {
                  gameState = GameState.playing;
                }
              }
            }
          },
          child: GestureDetector(
            onPanStart: (details) {
              touchStart = details.localPosition;
            },
            onPanUpdate: (details) {
              if (touchStart == null) return;
              final delta = details.localPosition - touchStart!;
              if (delta.distance < 15) return;

              if (delta.dx.abs() > delta.dy.abs()) {
                _changeDirection(delta.dx > 0 ? Direction.right : Direction.left);
              } else {
                _changeDirection(delta.dy > 0 ? Direction.down : Direction.up);
              }
              touchStart = details.localPosition;
            },
            onPanEnd: (_) {
              touchStart = null;
            },
            child: Container(
              color: Colors.black,
              child: Stack(
                children: [
                  CustomPaint(
                    size: Size(constraints.maxWidth, constraints.maxHeight),
                    painter: GamePainter(
                      gameMap: gameMap,
                      pacmanX: pacmanX,
                      pacmanY: pacmanY,
                      pacmanDir: pacmanDir,
                      ghosts: ghosts,
                      lives: lives,
                      score: score,
                      level: level,
                      highScore: highScore,
                      gameState: gameState,
                      animationTick: animationTick,
                      frightenedTimer: frightenedTimer,
                      showFruit: showFruit,
                      fruitIndex: (level - 1).clamp(0, kFruitPoints.length - 1),
                    ),
                  ),
                  // READY! overlay
                  if (gameState == GameState.ready)
                    Center(
                      child: Text(
                        'READY!',
                        style: TextStyle(
                          color: kPacmanColor,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 4,
                          shadows: [
                            Shadow(
                              color: kPacmanColor.withAlpha(128),
                              blurRadius: 15,
                            ),
                          ],
                        ),
                      ),
                    ),
                  // PAUSED overlay
                  if (gameState == GameState.paused)
                    Container(
                      color: Colors.black54,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'PAUSA',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 40,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 6,
                              ),
                            ),
                            const SizedBox(height: 20),
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  gameState = GameState.playing;
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.white, width: 2),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Text(
                                  'CONTINUAR',
                                  style: TextStyle(color: Colors.white, fontSize: 20),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  // Pause button
                  if (gameState == GameState.playing)
                    Positioned(
                      top: 5,
                      right: 10,
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            gameState = GameState.paused;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          child: const Icon(
                            Icons.pause,
                            color: Colors.white54,
                            size: 28,
                          ),
                        ),
                      ),
                    ),
                  // D-pad controls at bottom
                  if (gameState == GameState.playing || gameState == GameState.ready)
                    Positioned(
                      bottom: 10,
                      left: 0,
                      right: 0,
                      child: _buildDPad(),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDPad() {
    const double btnSize = 56;
    const double iconSize = 32;
    final btnColor = Colors.white.withAlpha(25);
    final iconColor = Colors.white.withAlpha(150);

    return Center(
      child: SizedBox(
        width: btnSize * 3,
        height: btnSize * 3,
        child: Stack(
          children: [
            // Up
            Positioned(
              left: btnSize,
              top: 0,
              child: _dpadButton(Icons.keyboard_arrow_up, Direction.up, btnSize, iconSize, btnColor, iconColor),
            ),
            // Down
            Positioned(
              left: btnSize,
              top: btnSize * 2,
              child: _dpadButton(Icons.keyboard_arrow_down, Direction.down, btnSize, iconSize, btnColor, iconColor),
            ),
            // Left
            Positioned(
              left: 0,
              top: btnSize,
              child: _dpadButton(Icons.keyboard_arrow_left, Direction.left, btnSize, iconSize, btnColor, iconColor),
            ),
            // Right
            Positioned(
              left: btnSize * 2,
              top: btnSize,
              child: _dpadButton(Icons.keyboard_arrow_right, Direction.right, btnSize, iconSize, btnColor, iconColor),
            ),
          ],
        ),
      ),
    );
  }

  Widget _dpadButton(IconData icon, Direction dir, double size, double iconSize, Color bgColor, Color fgColor) {
    return GestureDetector(
      onTapDown: (_) => _changeDirection(dir),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withAlpha(30)),
        ),
        child: Icon(icon, color: fgColor, size: iconSize),
      ),
    );
  }
}
