import 'package:flutter/material.dart';

// ============================================================================
// PAC-MAN NEON EDITION - CONSTANTES DEL JUEGO
// Estilo futurista, neón y cyberpunk
// ============================================================================

// === DIMENSIONES DEL MAPA ===
const int kMapWidth = 28;
const int kMapHeight = 31;

// === TIPOS DE BALDOSAS ===
const int kWall = 1;
const int kDot = 2;
const int kPowerPellet = 3;
const int kEmpty = 0;
const int kGhostDoor = 4;
const int kTunnel = 5;
const int kBonusItem = 6;
const int kSpeedBoost = 7;
const int kFreezeGhost = 8;

// ============================================================================
// PALETA DE COLORES NEÓN/FUTURISTA
// ============================================================================

// Colores principales del tema neón
class NeonColors {
  // Paleta principal - Azules y cyans neón
  static const Color primaryNeon = Color(0xFF00F5FF);      // Cyan eléctrico
  static const Color secondaryNeon = Color(0xFF0099FF);    // Azul brillante
  static const Color accentNeon = Color(0xFF7B2FFF);       // Violeta neón
  static const Color darkBg = Color(0xFF0A0A1A);           // Fondo oscuro azulado
  static const Color darkerBg = Color(0xFF050510);         // Fondo más oscuro
  
  // Gradientes para paredes
  static const List<Color> wallGradient = [
    Color(0xFF00D9FF),
    Color(0xFF0099FF),
    Color(0xFF0066FF),
  ];
  
  static const List<Color> wallGlowGradient = [
    Color(0x8000F5FF),
    Color(0x400099FF),
    Color(0x000066FF),
  ];
  
  // Pac-Man amarillo neón
  static const Color pacmanBody = Color(0xFFFFFF00);
  static const Color pacmanGlow = Color(0x80FFFF00);
  static const Color pacmanInner = Color(0xFFFFFF80);
  
  // Fantasmas - colores vibrantes
  static const Color blinkyNeon = Color(0xFFFF0040);       // Rojo neón
  static const Color pinkyNeon = Color(0xFFFF00FF);        // Magenta neón
  static const Color inkyNeon = Color(0xFF00FFFF);         // Cyan neón
  static const Color clydeNeon = Color(0xFFFF9900);        // Naranja neón
  
  // Estados especiales
  static const Color frightenedNeon = Color(0xFF0040FF);   // Azul oscuro neón
  static const Color frightenedFlash = Color(0xFFFFFFFF);  // Blanco flash
  static const Color eatenGhost = Color(0x60FFFFFF);       // Ojos solamente
  
  // Puntos y power-ups
  static const Color dotNeon = Color(0xFFFFB8AE);
  static const Color powerPelletNeon = Color(0xFFFF6B9D);
  static const Color powerPelletGlow = Color(0x80FF6B9D);
  
  // Bonus items
  static const Color cherryNeon = Color(0xFFFF0060);
  static const Color strawberryNeon = Color(0xFFFF3366);
  static const Color orangeNeon = Color(0xFFFF9933);
  static const Color appleNeon = Color(0xFF00FF60);
  static const Color melonNeon = Color(0xFF00FF99);
  static const Color galaxyNeon = Color(0xFF9900FF);
  
  // UI
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0x90FFFFFF);
  static const Color textAccent = Color(0xFF00F5FF);
  static const Color uiPanelBg = Color(0x400A0A1A);
  static const Color uiBorder = Color(0x6000F5FF);
  
  // Efectos
  static const Color particleDot = Color(0xFFFFB8AE);
  static const Color particlePower = Color(0xFFFF6B9D);
  static const Color particleEatGhost = Color(0xFF00F5FF);
  static const Color particleSpeed = Color(0xFF00FF60);
  static const Color particleFreeze = Color(0xFF0099FF);
}

// Alias para compatibilidad
const Color kWallColor = NeonColors.primaryNeon;
const Color kWallBorderColor = NeonColors.secondaryNeon;
const Color kDotColor = NeonColors.dotNeon;
const Color kPowerPelletColor = NeonColors.powerPelletNeon;
const Color kPacmanColor = NeonColors.pacmanBody;
const Color kBackgroundColor = NeonColors.darkBg;

const Color kBlinkyColor = NeonColors.blinkyNeon;
const Color kPinkyColor = NeonColors.pinkyNeon;
const Color kInkyColor = NeonColors.inkyNeon;
const Color kClydeColor = NeonColors.clydeNeon;
const Color kFrightenedColor = NeonColors.frightenedNeon;
const Color kFrightenedFlashColor = NeonColors.frightenedFlash;
const Color kGhostEyeWhite = Colors.white;
const Color kGhostEyePupil = NeonColors.primaryNeon;

// ============================================================================
// SISTEMA DE PUNTUACIÓN
// ============================================================================

const int kDotPoints = 10;
const int kPowerPelletPoints = 50;
const int kGhostBasePoints = 200;
const List<int> kGhostPoints = [200, 400, 800, 1600, 3200];
const int kExtraLifeScore = 10000;
const int kComboMultiplier = 2;

// Puntos de frutas bonus
const List<int> kFruitPoints = [100, 300, 500, 700, 1000, 2000, 3000, 5000];
const List<String> kFruitNames = [
  'CEREZA', 'FRESA', 'NARANJA', 'MANZANA', 
  'MELÓN', 'GALAXIA', 'DIAMANTE', 'CORONA'
];

// Power-ups especiales
const int kSpeedBoostPoints = 100;
const int kFreezeGhostPoints = 150;
const int kBonusItemPoints = 100;

// ============================================================================
// CONFIGURACIÓN DEL JUEGO
// ============================================================================

const int kInitialLives = 3;
const int kMaxLives = 5;
const int kMaxLevel = 99;

// Duraciones en milisegundos
const int kFrightenedDurationBase = 6000;
const int kFrightenedFlashTime = 2000;
const int kGhostRespawnMs = 3000;
const int kReadyDurationMs = 2500;
const int kDeathAnimationMs = 2000;
const int kLevelTransitionMs = 3000;
const int kGameCompleteDelay = 5000;

// Umbrales para frutas
const int kDotsForFirstFruit = 70;
const int kDotsForSecondFruit = 170;
const int kFruitDisplayDuration = 10000;

// ============================================================================
// DIRECCIONES
// ============================================================================

enum Direction { 
  up, 
  down, 
  left, 
  right, 
  none 
}

extension DirectionExtension on Direction {
  String get symbol {
    switch (this) {
      case Direction.up: return '▲';
      case Direction.down: return '▼';
      case Direction.left: return '◀';
      case Direction.right: return '▶';
      case Direction.none: return '•';
    }
  }
  
  Direction get opposite {
    switch (this) {
      case Direction.up: return Direction.down;
      case Direction.down: return Direction.up;
      case Direction.left: return Direction.right;
      case Direction.right: return Direction.left;
      case Direction.none: return Direction.none;
    }
  }
}

// ============================================================================
// MODOS DE FANTASMA
// ============================================================================

enum GhostMode { 
  chase,      // Persiguiendo a Pac-Man
  scatter,    // En las esquinas
  frightened, // Asustado (después de power pellet)
  eaten,      // Solo ojos, volviendo a casa
  inHouse,    // En la casa de fantasmas
  exitingHouse, // Saliendo de la casa
  frozen      // Congelado por power-up
}

// ============================================================================
// ESTADO DEL JUEGO
// ============================================================================

enum GameState { 
  menu,         // Pantalla principal
  ready,        // "READY!" antes de empezar
  playing,      // Jugando
  dying,        // Animación de muerte
  levelComplete, // Nivel completado
  gameOver,     // Juego terminado
  paused,       // Pausa
  gameComplete  // Todos los niveles completados
}

// ============================================================================
// CONFIGURACIÓN DE NIVELES
// ============================================================================

class LevelConfig {
  final double pacmanSpeed;
  final double ghostSpeed;
  final double frightenedGhostSpeed;
  final int frightenedDuration;
  final double tunnelGhostSpeed;
  final List<int> scatterDurations;
  final List<int> chaseDurations;
  final double ghostReleaseDelay;
  final int levelNumber;
  
  const LevelConfig({
    required this.pacmanSpeed,
    required this.ghostSpeed,
    required this.frightenedGhostSpeed,
    required this.frightenedDuration,
    required this.tunnelGhostSpeed,
    required this.scatterDurations,
    required this.chaseDurations,
    required this.ghostReleaseDelay,
    required this.levelNumber,
  });
  
  String get name => 'NIVEL $levelNumber';
}

// Configuraciones de niveles progresivos
const List<LevelConfig> kLevelConfigs = [
  // Nivel 1 - Introducción
  LevelConfig(
    pacmanSpeed: 1.5,
    ghostSpeed: 1.4,
    frightenedGhostSpeed: 0.9,
    frightenedDuration: 6000,
    tunnelGhostSpeed: 0.7,
    scatterDurations: [7000, 7000, 5000, 5000],
    chaseDurations: [20000, 20000, 20000, -1],
    ghostReleaseDelay: 200,
    levelNumber: 1,
  ),
  // Nivel 2
  LevelConfig(
    pacmanSpeed: 0.80,
    ghostSpeed: 0.75,
    frightenedGhostSpeed: 0.50,
    frightenedDuration: 5500,
    tunnelGhostSpeed: 0.40,
    scatterDurations: [7000, 7000, 5000, 0],
    chaseDurations: [20000, 20000, 1033, -1],
    ghostReleaseDelay: 180,
    levelNumber: 2,
  ),
  // Nivel 3
  LevelConfig(
    pacmanSpeed: 0.85,
    ghostSpeed: 0.80,
    frightenedGhostSpeed: 0.50,
    frightenedDuration: 5000,
    tunnelGhostSpeed: 0.40,
    scatterDurations: [7000, 7000, 5000, 0],
    chaseDurations: [20000, 20000, 1033, -1],
    ghostReleaseDelay: 160,
    levelNumber: 3,
  ),
  // Nivel 4
  LevelConfig(
    pacmanSpeed: 0.85,
    ghostSpeed: 0.80,
    frightenedGhostSpeed: 0.50,
    frightenedDuration: 5000,
    tunnelGhostSpeed: 0.40,
    scatterDurations: [7000, 7000, 5000, 0],
    chaseDurations: [20000, 20000, 1033, -1],
    ghostReleaseDelay: 140,
    levelNumber: 4,
  ),
  // Nivel 5 - Intermedio
  LevelConfig(
    pacmanSpeed: 0.90,
    ghostSpeed: 0.85,
    frightenedGhostSpeed: 0.55,
    frightenedDuration: 4500,
    tunnelGhostSpeed: 0.45,
    scatterDurations: [5000, 5000, 3000, 0],
    chaseDurations: [20000, 20000, 1033, -1],
    ghostReleaseDelay: 120,
    levelNumber: 5,
  ),
  // Nivel 6
  LevelConfig(
    pacmanSpeed: 0.90,
    ghostSpeed: 0.85,
    frightenedGhostSpeed: 0.55,
    frightenedDuration: 4000,
    tunnelGhostSpeed: 0.45,
    scatterDurations: [5000, 5000, 3000, 0],
    chaseDurations: [20000, 20000, 1033, -1],
    ghostReleaseDelay: 100,
    levelNumber: 6,
  ),
  // Nivel 7
  LevelConfig(
    pacmanSpeed: 0.95,
    ghostSpeed: 0.90,
    frightenedGhostSpeed: 0.55,
    frightenedDuration: 3500,
    tunnelGhostSpeed: 0.45,
    scatterDurations: [5000, 5000, 3000, 0],
    chaseDurations: [20000, 20000, 1033, -1],
    ghostReleaseDelay: 80,
    levelNumber: 7,
  ),
  // Nivel 8 - Avanzado
  LevelConfig(
    pacmanSpeed: 0.95,
    ghostSpeed: 0.90,
    frightenedGhostSpeed: 0.55,
    frightenedDuration: 3000,
    tunnelGhostSpeed: 0.45,
    scatterDurations: [5000, 5000, 3000, 0],
    chaseDurations: [20000, 20000, 1033, -1],
    ghostReleaseDelay: 60,
    levelNumber: 8,
  ),
  // Nivel 9+ - Experto
  LevelConfig(
    pacmanSpeed: 1.0,
    ghostSpeed: 0.95,
    frightenedGhostSpeed: 0.60,
    frightenedDuration: 2500,
    tunnelGhostSpeed: 0.50,
    scatterDurations: [3000, 3000, 2000, 0],
    chaseDurations: [20000, 20000, 1033, -1],
    ghostReleaseDelay: 40,
    levelNumber: 9,
  ),
];

LevelConfig getLevelConfig(int level) {
  if (level < 1) return kLevelConfigs[0];
  if (level <= kLevelConfigs.length) {
    return kLevelConfigs[level - 1];
  }
  // Para niveles más allá del 9, usar la configuración más difícil
  return kLevelConfigs.last;
}

// ============================================================================
// POSICIONES DE INICIO
// ============================================================================

class StartPositions {
  // Pac-Man
  static const double pacmanStartX = 13.5;
  static const double pacmanStartY = 23.0;
  
  // Fantasmas
  static const double blinkyStartX = 13.5;
  static const double blinkyStartY = 11.0;
  static const double pinkyStartX = 13.5;
  static const double pinkyStartY = 14.0;
  static const double inkyStartX = 11.5;
  static const double inkyStartY = 14.0;
  static const double clydeStartX = 15.5;
  static const double clydeStartY = 14.0;
  
  // Salida de la casa de fantasmas
  static const double ghostExitX = 13.5;
  static const double ghostExitY = 11.0;
  
  // Posición del túnel
  static const int tunnelY = 14;
  
  // Objetivos de scatter (esquinas)
  static const List<List<int>> scatterTargets = [
    [25, -3],  // Blinky - superior derecha
    [2, -3],   // Pinky - superior izquierda
    [27, 31],  // Inky - inferior derecha
    [0, 31],   // Clyde - inferior izquierda
  ];
}

// ============================================================================
// EFECTOS VISUALES
// ============================================================================

class EffectSettings {
  // Intensidad de brillo neón
  static const double wallGlowBlur = 8.0;
  static const double pacmanGlowBlur = 12.0;
  static const double ghostGlowBlur = 10.0;
  static const double pelletGlowBlur = 6.0;
  static const double powerPelletGlowBlur = 15.0;
  
  // Partículas
  static const int maxParticles = 200;
  static const double particleLifetime = 0.8;
  static const double particleFadeSpeed = 1.2;
  
  // Animaciones
  static const double pacmanMouthSpeed = 0.3;
  static const double pacmanMouthMax = 0.35;
  static const double pacmanMouthMin = 0.1;
  
  // Flash de power pellet
  static const int powerPelletFlashInterval = 200;
  
  // Temblor de pantalla al comer fantasma
  static const double screenShakeIntensity = 4.0;
  static const int screenShakeDuration = 300;
}

// ============================================================================
// CONFIGURACIÓN DE AUDIO
// ============================================================================

class AudioSettings {
  static const double masterVolume = 0.7;
  static const double sfxVolume = 0.8;
  static const double musicVolume = 0.5;
  
  // Archivos de sonido (se generarán programáticamente)
  static const String wakaSound = 'waka.wav';
  static const String eatGhostSound = 'eatghost.wav';
  static const String dieSound = 'die.wav';
  static const String powerupSound = 'powerup.wav';
  static const String fruitSound = 'fruit.wav';
  static const String readySound = 'ready.wav';
  static const String levelCompleteSound = 'levelcomplete.wav';
  static const String gameCompleteSound = 'gamecomplete.wav';
}

// ============================================================================
// CONFIGURACIÓN DE VIBRACIÓN
// ============================================================================

class HapticSettings {
  static const bool enableHaptics = true;
  static const Duration eatDotVibration = Duration(milliseconds: 5);
  static const Duration eatPowerPelletVibration = Duration(milliseconds: 50);
  static const Duration eatGhostVibration = Duration(milliseconds: 100);
  static const Duration dieVibration = Duration(milliseconds: 500);
  static const Duration levelCompleteVibration = Duration(milliseconds: 200);
}

// ============================================================================
// ESTILOS DE TEXTO
// ============================================================================

class TextStyles {
  static const String neonFont = 'Orbitron';
  static const String retroFont = 'PressStart2P';
  
  static TextStyle titleStyle({double size = 48}) => TextStyle(
    fontFamily: neonFont,
    fontSize: size,
    fontWeight: FontWeight.bold,
    color: NeonColors.textPrimary,
    letterSpacing: 8,
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
  );
  
  static TextStyle subtitleStyle({double size = 24}) => TextStyle(
    fontFamily: neonFont,
    fontSize: size,
    fontWeight: FontWeight.w600,
    color: NeonColors.textAccent,
    letterSpacing: 4,
    shadows: [
      Shadow(
        color: NeonColors.accentNeon,
        blurRadius: 10,
      ),
    ],
  );
  
  static TextStyle scoreStyle({double size = 18}) => TextStyle(
    fontFamily: neonFont,
    fontSize: size,
    fontWeight: FontWeight.bold,
    color: NeonColors.textPrimary,
    letterSpacing: 2,
  );
  
  static TextStyle buttonStyle({double size = 20}) => TextStyle(
    fontFamily: neonFont,
    fontSize: size,
    fontWeight: FontWeight.bold,
    color: NeonColors.textPrimary,
    letterSpacing: 3,
  );
}

// ============================================================================
// UTILIDADES
// ============================================================================

class GameUtils {
  static Color lerpColor(Color a, Color b, double t) {
    return Color.lerp(a, b, t) ?? a;
  }
  
  static double clamp(double value, double min, double max) {
    return value < min ? min : (value > max ? max : value);
  }
  
  static int clampInt(int value, int min, int max) {
    return value < min ? min : (value > max ? max : value);
  }
}
