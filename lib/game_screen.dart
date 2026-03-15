import 'package:flutter/scheduler.dart';
import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'constants.dart';
import 'game_map.dart';
import 'ghost.dart';
import 'game_painter.dart';
import 'effects/particle_system.dart';

/// ============================================================================
/// GAME SCREEN - PANTALLA DE JUEGO PRINCIPAL
/// Con UI futurista, menús animados, controles táctiles y de teclado
/// ============================================================================

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  // ============================================================================
  // ESTADO DEL JUEGO
  // ============================================================================
  
  GameState gameState = GameState.menu;
  final GameMap gameMap = GameMap();
  int score = 0;
  int highScore = 0;
  int lives = kInitialLives;
  int level = 1;
  int ghostsEatenCombo = 0;
  int combo = 1;
  bool extraLifeAwarded = false;
  
  // Power-ups
  bool speedBoostActive = false;
  int speedBoostTimer = 0;
  bool freezeActive = false;
  int freezeTimer = 0;
  
  // Fruta bonus
  bool showFruit = false;
  int fruitTimer = 0;
  bool firstFruitShown = false;
  bool secondFruitShown = false;
  int? bonusFruitIndex;
  
  // ============================================================================
  // PAC-MAN
  // ============================================================================
  
  double pacmanX = GameMap.pacmanStartX;
  double pacmanY = GameMap.pacmanStartY;
  Direction pacmanDir = Direction.left;
  Direction pacmanNextDir = Direction.left;
  double pacmanSpeed = 0.08;
  
  // ============================================================================
  // FANTASMAS
  // ============================================================================
  
  late List<Ghost> ghosts;
  GhostMode globalGhostMode = GhostMode.scatter;
  int modePhaseIndex = 0;
  int modeTimer = 0;
  
  // Modo asustado
  int frightenedTimer = 0;
  
  // ============================================================================
  // ANIMACIÓN Y EFECTOS
  // ============================================================================
  
  Timer? _timer;
  double animationTick = 0;
  int readyTimer = 0;
  int deathAnimTimer = 0;
  int levelCompleteTimer = 0;
  int gameCompleteTimer = 0;
  
  // Sistemas de efectos
  late ParticleSystem particleSystem;
  late ScreenShake screenShake;
  late Shockwave shockwave;
  
  // ============================================================================
  // CONTROLES TÁCTILES
  // ============================================================================
  
  Offset? touchStart;
  bool showControls = true;
  
  // ============================================================================
  // CONFIGURACIÓN
  // ============================================================================
  
  bool soundEnabled = true;
  bool hapticsEnabled = true;
  bool glowEnabled = true;
  bool particlesEnabled = true;
  
  // ============================================================================
  // INICIALIZACIÓN
  // ============================================================================
  
  @override
  void initState() {
    super.initState();
    _initializeGame();
    _loadHighScore();

    _timer = Timer.periodic(const Duration(milliseconds: 16), (timer) {
      if (mounted) {
        setState(() {
          animationTick += 1;
          _update(16);
        });
      }
    });
  }
  
  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _initializeGame() {
    particleSystem = ParticleSystem(maxParticles: 300);
    screenShake = ScreenShake();
    shockwave = Shockwave(x: 0, y: 0);
    
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
  
  void _loadHighScore() async {
    // Aquí se podría usar SharedPreferences para cargar el high score
    // Por ahora usamos un valor por defecto
    setState(() {
      highScore = 0;
    });
  }
  
  void _saveHighScore() async {
    // Guardar high score
    if (score > highScore) {
      setState(() {
        highScore = score;
      });
    }
  }
  
  // ============================================================================
  // CONTROL DEL JUEGO
  // ============================================================================
  
  void _startGame() {
    gameMap.resetMap();
    score = 0;
    lives = kInitialLives;
    level = 1;
    extraLifeAwarded = false;
    combo = 1;
    speedBoostActive = false;
    freezeActive = false;
    _resetPositions();
    _startReady();
  }
  
  void _startReady() {
    gameState = GameState.ready;
    readyTimer = kReadyDurationMs;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(milliseconds: 16), (timer) {
      if (mounted) {
        setState(() {
          animationTick += 1;
          _update(16);
        });
      }
    });
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
    combo = 1;
    showFruit = false;
    fruitTimer = 0;
    firstFruitShown = false;
    secondFruitShown = false;
    speedBoostActive = false;
    freezeActive = false;
  }
  

  
  // ============================================================================
  // ACTUALIZACIÓN DEL JUEGO
  // ============================================================================
  
  void _update(int deltaMs) {
    // Actualizar efectos
    particleSystem.update(deltaMs / 1000.0);
    screenShake.update(deltaMs / 1000.0);
    shockwave.update(deltaMs / 1000.0);
    
    // Actualizar temporizadores de power-ups
    if (speedBoostActive) {
      speedBoostTimer -= deltaMs;
      if (speedBoostTimer <= 0) {
        speedBoostActive = false;
      }
    }
    
    if (freezeActive) {
      freezeTimer -= deltaMs;
      if (freezeTimer <= 0) {
        freezeActive = false;
        for (var ghost in ghosts) {
          if (ghost.mode == GhostMode.frozen) {
            ghost.mode = globalGhostMode;
          }
        }
      }
    }
    
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
            _gameOver();
          } else {
            _resetPositionsOnly();
            _startReady();
          }
        }
        break;

      case GameState.levelComplete:
        levelCompleteTimer -= deltaMs;
        if (levelCompleteTimer <= 0) {
          _nextLevel();
        }
        break;
        
      case GameState.gameComplete:
        gameCompleteTimer -= deltaMs;
        if (gameCompleteTimer <= 0) {
          _goToMenu();
        }
        break;

      case GameState.gameOver:
      case GameState.menu:
      case GameState.paused:
        break;
    }
  }
  
  void _updatePlaying(int deltaMs) {
    final config = getLevelConfig(level);

    // Velocidad de Pac-Man con boost - CORREGIDO: sin multiplicador 0.08
    double speedMultiplier = speedBoostActive ? 1.3 : 1.0;
    pacmanSpeed = config.pacmanSpeed * speedMultiplier * 0.15;

    // Actualizar modo de fantasmas
    if (frightenedTimer == 0 && !freezeActive) {
      _updateGhostMode(deltaMs, config);
    }

    // Actualizar temporizador asustado
    if (frightenedTimer > 0) {
      frightenedTimer -= deltaMs;
      if (frightenedTimer <= 0) {
        frightenedTimer = 0;
        ghostsEatenCombo = 0;
        combo = 1;
        for (var ghost in ghosts) {
          if (ghost.mode == GhostMode.frightened) {
            ghost.mode = globalGhostMode;
          }
        }
      }
    }

    // Mover Pac-Man
    _movePacman();

    // Comer puntos - CORREGIDO: usar posición centrada
    double centerX = pacmanX;
    double centerY = pacmanY;
    int gridX = centerX.round();
    int gridY = centerY.round();
    
    // Solo comer si está cerca del centro de la celda
    if ((centerX - gridX).abs() < 0.3 && (centerY - gridY).abs() < 0.3) {
      if (gridX >= 0 && gridX < kMapWidth && gridY >= 0 && gridY < kMapHeight) {
        bool wasPowerPellet = gameMap.isPowerPellet(gridX, gridY);
        bool wasSpeedBoost = gameMap.layout[gridY][gridX] == kSpeedBoost;
        bool wasFreezeGhost = gameMap.layout[gridY][gridX] == kFreezeGhost;

        int points = gameMap.eatDot(gridX, gridY);
        if (points > 0) {
          score += points * combo;

          // Emitir partículas
          particleSystem.emit(
            x: (gridX + 0.5) * 20,
            y: (gridY + 0.5) * 20,
            type: wasPowerPellet ? ParticleType.powerPellet : ParticleType.dot,
            count: wasPowerPellet ? 15 : 3,
          );

          if (wasPowerPellet) {
            _activateFrightened(config);
            _triggerHaptic(HapticSettings.eatPowerPelletVibration);
          } else if (wasSpeedBoost) {
            speedBoostActive = true;
            speedBoostTimer = 8000;
          } else if (wasFreezeGhost) {
            freezeActive = true;
            freezeTimer = 5000;
            for (var ghost in ghosts) {
              ghost.setFrozen(freezeTimer);
            }
          } else {
            _triggerHaptic(HapticSettings.eatDotVibration);
          }
        }
      }
    }

    // Verificar fruta
    _updateFruit(deltaMs);

    // Vida extra
    if (!extraLifeAwarded && score >= kExtraLifeScore) {
      extraLifeAwarded = true;
      if (lives < kMaxLives) {
        lives++;
        _showFloatingText('¡VIDA EXTRA!', Colors.green);
      }
    }

    // Actualizar fantasmas
    double freezeSpeedMultiplier = freezeActive ? 0.3 : 1.0;
    for (var ghost in ghosts) {
      ghost.update(
        gameMap, 
        pacmanX, 
        pacmanY, 
        pacmanDir,
        ghosts[0], 
        gameMap.dotsEaten, 
        globalGhostMode,
        config.ghostSpeed * 0.08,
        config.frightenedGhostSpeed * 0.08,
        config.tunnelGhostSpeed * 0.08,
        config.frightenedGhostSpeed * 0.08 * freezeSpeedMultiplier,
      );
    }

    // Verificar colisiones con fantasmas
    for (var ghost in ghosts) {
      if (ghost.checkCollision(pacmanX, pacmanY)) {
        if (ghost.mode == GhostMode.frightened) {
          // Comer fantasma
          _eatGhost(ghost);
        } else if (ghost.mode != GhostMode.eaten && 
                   ghost.mode != GhostMode.frozen) {
          // Pac-Man muere
          _pacmanDie();
          return;
        }
      }
    }

    // Verificar nivel completado
    if (gameMap.allDotsEaten()) {
      _levelComplete();
    }
  }
  
  void _eatGhost(Ghost ghost) {
    ghost.mode = GhostMode.eaten;
    int comboClamped = ghostsEatenCombo.clamp(0, 4);
    int points = kGhostPoints[comboClamped] * combo;
    score += points;
    ghostsEatenCombo++;
    combo = (combo * 2).clamp(1, 8);
    
    // Efectos
    particleSystem.emit(
      x: (ghost.x + 0.5) * 20,
      y: (ghost.y + 0.5) * 20,
      type: ParticleType.eatGhost,
      count: 20,
      speed: 80,
    );
    
    shockwave.trigger(
      x: (ghost.x + 0.5) * 20,
      y: (ghost.y + 0.5) * 20,
    );
    
    screenShake.trigger(intensity: 3, durationMs: 200);
    _triggerHaptic(HapticSettings.eatGhostVibration);
    
    // Texto flotante
    _showFloatingText('+$points', NeonColors.primaryNeon);
  }
  
  void _updateGhostMode(int deltaMs, LevelConfig config) {
    modeTimer += deltaMs;

    List<int> scatterDurs = config.scatterDurations;
    List<int> chaseDurs = config.chaseDurations;

    int totalPhases = scatterDurs.length + chaseDurs.length;
    if (modePhaseIndex >= totalPhases) {
      globalGhostMode = GhostMode.chase; // Chase permanente al final
      return;
    }

    bool isScatter = modePhaseIndex % 2 == 0;
    int duration;

    if (isScatter) {
      int scatterIdx = modePhaseIndex ~/ 2;
      duration = scatterDurs[scatterIdx];
    } else {
      int chaseIdx = (modePhaseIndex - 1) ~/ 2;
      duration = chaseDurs[chaseIdx];
    }

    if (duration == -1) { // -1 significa fase infinita
      globalGhostMode = GhostMode.chase;
      return;
    }

    if (modeTimer >= duration) {
      modeTimer = 0;
      modePhaseIndex++;
      globalGhostMode = (modePhaseIndex % 2 == 0) 
          ? GhostMode.scatter 
          : GhostMode.chase;
    }
  }
  
  void _activateFrightened(LevelConfig config) {
    frightenedTimer = config.frightenedDuration;
    ghostsEatenCombo = 0;
    combo = 1;
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
      // Verificar si Pac-Man come la fruta
      if ((pacmanX - 13.5).abs() < 1.0 && (pacmanY - 17.0).abs() < 1.0) {
        int fruitIdx = (level - 1).clamp(0, kFruitPoints.length - 1);
        int points = kFruitPoints[fruitIdx] * combo;
        score += points;
        showFruit = false;
        
        // Efectos
        particleSystem.emit(
          x: 14 * 20,
          y: 17.5 * 20,
          type: ParticleType.fruit,
          count: 10,
        );
        
        _showFloatingText('+$points', Colors.orange);
        _triggerHaptic(Duration(milliseconds: 50));
      }
    } else {
      if (!firstFruitShown && gameMap.dotsEaten >= kDotsForFirstFruit) {
        firstFruitShown = true;
        showFruit = true;
        fruitTimer = kFruitDisplayDuration;
      } else if (!secondFruitShown && gameMap.dotsEaten >= kDotsForSecondFruit) {
        secondFruitShown = true;
        showFruit = true;
        fruitTimer = kFruitDisplayDuration;
      }
    }
  }
  
  void _movePacman() {
    // Intentar siguiente dirección
    if (pacmanNextDir != pacmanDir) {
      if (_canMoveInDir(pacmanNextDir)) {
        pacmanDir = pacmanNextDir;
      }
    }

    // Mover en dirección actual
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

      // Túnel
      if (pacmanX < -1) pacmanX = kMapWidth.toDouble();
      if (pacmanX > kMapWidth) pacmanX = -1.0;
    }
    
    // Emitir estela de partículas
    if (gameState == GameState.playing && animationTick % 3 == 0) {
      particleSystem.emitTrail(
        x: (pacmanX + 0.5) * 20,
        y: (pacmanY + 0.5) * 20,
        direction: pacmanDir,
      );
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

    // Túnel
    if (gy == GameMap.tunnelY && (gx < 0 || gx >= kMapWidth)) return true;

    return !gameMap.isWall(gx, gy) && !gameMap.isGhostDoor(gx, gy);
  }
  
  void _pacmanDie() {
    gameState = GameState.dying;
    deathAnimTimer = kDeathAnimationMs;
    screenShake.trigger(intensity: 5, durationMs: 500);
    _triggerHaptic(HapticSettings.dieVibration);
    
    // Partículas de muerte
    particleSystem.emit(
      x: (pacmanX + 0.5) * 20,
      y: (pacmanY + 0.5) * 20,
      type: ParticleType.explosion,
      count: 30,
      speed: 100,
    );
  }
  
  void _levelComplete() {
    gameState = GameState.levelComplete;
    levelCompleteTimer = kLevelTransitionMs;
    _triggerHaptic(HapticSettings.levelCompleteVibration);
  }
  
  void _nextLevel() {
    level++;
    if (level > kMaxLevel) {
      _gameComplete();
      return;
    }
    
    // Cambiar mapa cada 5 niveles
    if (level % 5 == 0) {
      gameMap.nextMap();
    }
    
    gameMap.resetMap();
    _resetPositions();
    _startReady();
  }
  
  void _gameOver() {
    _timer?.cancel();
    gameState = GameState.gameOver;
    _saveHighScore();
  }
  
  void _gameComplete() {
    gameState = GameState.gameComplete;
    gameCompleteTimer = kGameCompleteDelay;
    _saveHighScore();
  }
  
  void _goToMenu() {
    gameState = GameState.menu;
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
    combo = 1;
  }
  
  void _changeDirection(Direction dir) {
    if (gameState == GameState.playing || gameState == GameState.ready) {
      pacmanNextDir = dir;
    }
  }
  
  // ============================================================================
  // EFECTOS
  // ============================================================================
  
  void _triggerHaptic(Duration duration) {
    if (hapticsEnabled) {
      // HapticFeedback.vibrate();
    }
  }
  
  void _showFloatingText(String text, Color color) {
    // Se podría implementar con un overlay
  }
  
  // ============================================================================
  // BUILD
  // ============================================================================
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NeonColors.darkerBg,
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
      case GameState.gameComplete:
        return _buildGameComplete();
      default:
        return _buildGameView();
    }
  }

  // ============================================================================
  // PANTALLA DE MENÚ
  // ============================================================================
  
  Widget _buildMenu() {
    return GestureDetector(
      onTap: () {
        setState(() {
          _startGame();
        });
      },
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              NeonColors.darkerBg,
              NeonColors.darkBg,
              NeonColors.darkerBg,
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Título con efecto neón
              _buildNeonTitle(),
              
              const SizedBox(height: 40),
              
              // Animación de fantasmas
              _buildGhostAnimation(),
              
              const SizedBox(height: 50),
              
              // Botón de jugar
              _buildPlayButton(),
              
              const SizedBox(height: 30),
              
              // High score
              if (highScore > 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  decoration: BoxDecoration(
                    border: Border.all(color: NeonColors.accentNeon, width: 1.5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'HIGH SCORE: $highScore',
                    style: TextStyle(
                      color: NeonColors.textAccent,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                ),
              
              const SizedBox(height: 60),
              
              // Instrucciones
              const Text(
                'DESLIZA O USA LAS FLECHAS PARA MOVER',
                style: TextStyle(
                  color: Colors.white38,
                  fontSize: 12,
                  letterSpacing: 2,
                ),
              ),
              
              const SizedBox(height: 10),
              
              const Text(
                'ESPACIO PARA PAUSA',
                style: TextStyle(
                  color: Colors.white38,
                  fontSize: 12,
                  letterSpacing: 2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildNeonTitle() {
    return ShaderMask(
      shaderCallback: (bounds) => LinearGradient(
        colors: [
          NeonColors.primaryNeon,
          NeonColors.secondaryNeon,
          NeonColors.accentNeon,
        ],
      ).createShader(bounds),
      child: const Text(
        'PAC-MAN',
        style: TextStyle(
          fontSize: 64,
          fontWeight: FontWeight.bold,
          letterSpacing: 12,
          color: Colors.white,
          shadows: [
            Shadow(
              color: NeonColors.primaryNeon,
              blurRadius: 20,
            ),
            Shadow(
              color: NeonColors.secondaryNeon,
              blurRadius: 40,
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildGhostAnimation() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildAnimatedGhost(kBlinkyColor, 'BLINKY'),
        const SizedBox(width: 12),
        _buildAnimatedGhost(kPinkyColor, 'PINKY'),
        const SizedBox(width: 12),
        _buildAnimatedGhost(kInkyColor, 'INKY'),
        const SizedBox(width: 12),
        _buildAnimatedGhost(kClydeColor, 'CLYDE'),
      ],
    );
  }
  
  Widget _buildAnimatedGhost(Color color, String name) {
    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0, end: 1),
      duration: Duration(milliseconds: 500 + name.length * 100),
      builder: (context, double value, child) {
        return Transform.translate(
          offset: Offset(0, math.sin(animationTick * 0.1 + name.length) * 5 * value),
          child: child,
        );
      },
      child: Column(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(18),
                topRight: Radius.circular(18),
              ),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.5),
                  blurRadius: 15,
                  spreadRadius: 2,
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          Text(
            name,
            style: TextStyle(
              color: color,
              fontSize: 9,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildPlayButton() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            NeonColors.primaryNeon,
            NeonColors.secondaryNeon,
          ],
        ),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: NeonColors.primaryNeon.withOpacity(0.5),
            blurRadius: 20,
            spreadRadius: 3,
          ),
        ],
      ),
      child: const Text(
        'TOCA PARA JUGAR',
        style: TextStyle(
          color: Colors.black,
          fontSize: 24,
          fontWeight: FontWeight.bold,
          letterSpacing: 3,
        ),
      ),
    );
  }
  
  // ============================================================================
  // PANTALLA DE GAME OVER
  // ============================================================================
  
  Widget _buildGameOver() {
    return GestureDetector(
      onTap: () {
        setState(() {
          gameState = GameState.menu;
        });
      },
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black.withOpacity(0.9),
              Colors.red.withOpacity(0.1),
              Colors.black,
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'GAME OVER',
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 56,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 8,
                  shadows: [
                    Shadow(
                      color: Colors.red,
                      blurRadius: 20,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              Text(
                'PUNTUACIÓN: $score',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  letterSpacing: 3,
                ),
              ),
              const SizedBox(height: 15),
              Text(
                'NIVEL: $level',
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 24,
                  letterSpacing: 3,
                ),
              ),
              const SizedBox(height: 20),
              if (score >= highScore && score > 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    border: Border.all(color: NeonColors.pacmanBody, width: 2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    '★ NUEVO HIGH SCORE ★',
                    style: TextStyle(
                      color: NeonColors.pacmanBody,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
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
                  'TOCA PARA VOLVER AL MENÚ',
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
  
  // ============================================================================
  // PANTALLA DE GAME COMPLETE
  // ============================================================================
  
  Widget _buildGameComplete() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            NeonColors.darkBg,
            NeonColors.accentNeon.withOpacity(0.2),
            NeonColors.darkBg,
          ],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              '¡FELICIDADES!',
              style: TextStyle(
                color: Colors.white,
                fontSize: 48,
                fontWeight: FontWeight.bold,
                letterSpacing: 6,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              '¡COMPLETASTE TODOS LOS NIVELES!',
              style: TextStyle(
                color: NeonColors.primaryNeon,
                fontSize: 24,
                letterSpacing: 3,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            Text(
              'PUNTUACIÓN FINAL: $score',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 28,
                letterSpacing: 3,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  // ============================================================================
  // VISTA DE JUEGO
  // ============================================================================
  
  Widget _buildGameView() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return KeyboardListener(
          focusNode: FocusNode()..requestFocus(),
          onKeyEvent: (event) {
            if (event is KeyDownEvent) {
              _handleKeyPress(event.logicalKey);
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
              color: NeonColors.darkerBg,
              child: Stack(
                children: [
                  // Canvas del juego
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
                      combo: combo,
                      particleSystem: particleSystem,
                      screenShake: screenShake,
                      shockwave: shockwave,
                      enableGlow: glowEnabled,
                      enableParticles: particlesEnabled,
                      enableScreenShake: true,
                    ),
                  ),
                  
                  // Overlay de READY!
                  if (gameState == GameState.ready)
                    Center(
                      child: Text(
                        '¡READY!',
                        style: TextStyle(
                          color: NeonColors.primaryNeon,
                          fontSize: 42,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 6,
                          shadows: [
                            Shadow(
                              color: NeonColors.primaryNeon.withOpacity(0.5),
                              blurRadius: 20,
                            ),
                          ],
                        ),
                      ),
                    ),
                  
                  // Overlay de PAUSA
                  if (gameState == GameState.paused)
                    _buildPauseOverlay(),
                  
                  // Botón de pausa
                  if (gameState == GameState.playing || gameState == GameState.ready)
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
                          decoration: BoxDecoration(
                            color: NeonColors.uiPanelBg,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: NeonColors.uiBorder),
                          ),
                          child: const Icon(
                            Icons.pause,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                      ),
                    ),
                  
                  // Controles D-Pad
                  if (gameState == GameState.playing || gameState == GameState.ready)
                    Positioned(
                      bottom: 15,
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
  
  Widget _buildPauseOverlay() {
    return Container(
      color: Colors.black54,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'PAUSA',
              style: TextStyle(
                color: Colors.white,
                fontSize: 48,
                fontWeight: FontWeight.bold,
                letterSpacing: 6,
              ),
            ),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildPauseButton(
                  'CONTINUAR',
                  () {
                    setState(() {
                      gameState = GameState.playing;
                    });
                  },
                ),
                const SizedBox(width: 15),
                _buildPauseButton(
                  'MENÚ',
                  () {
                    setState(() {
                      gameState = GameState.menu;
                    });
                  },
                  isSecondary: true,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildPauseButton(String label, VoidCallback onTap, {bool isSecondary = false}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          gradient: isSecondary 
              ? null 
              : LinearGradient(
                  colors: [NeonColors.primaryNeon, NeonColors.secondaryNeon],
                ),
          border: Border.all(color: isSecondary ? Colors.white : Colors.transparent, width: 2),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSecondary ? Colors.white : Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
  
  Widget _buildDPad() {
    const double btnSize = 60;
    final btnColor = NeonColors.uiPanelBg;
    final iconColor = NeonColors.primaryNeon;

    return Center(
      child: SizedBox(
        width: btnSize * 3,
        height: btnSize * 3,
        child: Stack(
          children: [
            // Arriba
            Positioned(
              left: btnSize,
              top: 0,
              child: _dpadButton(Icons.keyboard_arrow_up, Direction.up, btnSize, btnColor, iconColor),
            ),
            // Abajo
            Positioned(
              left: btnSize,
              top: btnSize * 2,
              child: _dpadButton(Icons.keyboard_arrow_down, Direction.down, btnSize, btnColor, iconColor),
            ),
            // Izquierda
            Positioned(
              left: 0,
              top: btnSize,
              child: _dpadButton(Icons.keyboard_arrow_left, Direction.left, btnSize, btnColor, iconColor),
            ),
            // Derecha
            Positioned(
              left: btnSize * 2,
              top: btnSize,
              child: _dpadButton(Icons.keyboard_arrow_right, Direction.right, btnSize, btnColor, iconColor),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _dpadButton(IconData icon, Direction dir, double size, Color bgColor, Color fgColor) {
    return GestureDetector(
      onTapDown: (_) => _changeDirection(dir),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: NeonColors.uiBorder.withOpacity(0.5)),
          boxShadow: [
            BoxShadow(
              color: fgColor.withOpacity(0.2),
              blurRadius: 10,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Icon(icon, color: fgColor, size: 36),
      ),
    );
  }
  
  void _handleKeyPress(LogicalKeyboardKey key) {
    if (key == LogicalKeyboardKey.arrowRight) {
      _changeDirection(Direction.right);
    } else if (key == LogicalKeyboardKey.arrowLeft) {
      _changeDirection(Direction.left);
    } else if (key == LogicalKeyboardKey.arrowUp) {
      _changeDirection(Direction.up);
    } else if (key == LogicalKeyboardKey.arrowDown) {
      _changeDirection(Direction.down);
    } else if (key == LogicalKeyboardKey.space) {
      if (gameState == GameState.playing) {
        setState(() {
          gameState = GameState.paused;
        });
      } else if (gameState == GameState.paused) {
        setState(() {
          gameState = GameState.playing;
        });
      }
    }
  }
}
