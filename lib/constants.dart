import 'package:flutter/material.dart';

// === MAP DIMENSIONS (Classic Pac-Man 28x31) ===
const int kMapWidth = 28;
const int kMapHeight = 31;

// === TILE TYPES ===
const int kWall = 1;
const int kDot = 2;
const int kPowerPellet = 3;
const int kEmpty = 0;
const int kGhostDoor = 4;
const int kTunnel = 5;

// === COLORS ===
const Color kWallColor = Color(0xFF1919A6);
const Color kWallBorderColor = Color(0xFF2121DE);
const Color kDotColor = Color(0xFFFFB8AE);
const Color kPowerPelletColor = Color(0xFFFFB8AE);
const Color kPacmanColor = Color(0xFFFFFF00);
const Color kBackgroundColor = Colors.black;

// Ghost colors
const Color kBlinkyColor = Color(0xFFFF0000);
const Color kPinkyColor = Color(0xFFFFB8FF);
const Color kInkyColor = Color(0xFF00FFFF);
const Color kClydeColor = Color(0xFFFFB852);
const Color kFrightenedColor = Color(0xFF2121FF);
const Color kFrightenedFlashColor = Color(0xFFFFFFFF);
const Color kGhostEyeWhite = Colors.white;
const Color kGhostEyePupil = Color(0xFF2121DE);

// === SCORING ===
const int kDotPoints = 10;
const int kPowerPelletPoints = 50;
const List<int> kGhostPoints = [200, 400, 800, 1600];
const int kExtraLifeScore = 10000;

// Fruit points per level
const List<int> kFruitPoints = [100, 300, 500, 500, 700, 700, 1000, 1000, 2000, 2000, 3000, 3000, 5000];

// === GAME SETTINGS ===
const int kInitialLives = 3;
const int kMaxLives = 5;
const int kFrightenedDurationBase = 6000;
const int kFrightenedFlashTime = 2000;
const int kGhostRespawnMs = 3000;
const int kReadyDurationMs = 2000;
const int kDeathAnimationMs = 1500;
const int kLevelTransitionMs = 2000;
const int kDotsForFirstFruit = 70;
const int kDotsForSecondFruit = 170;

// === DIRECTIONS ===
enum Direction { up, down, left, right, none }

// === GHOST MODES ===
enum GhostMode { chase, scatter, frightened, eaten, inHouse, exitingHouse }

// === GAME STATE ===
enum GameState { menu, ready, playing, dying, levelComplete, gameOver, paused }

// === LEVEL CONFIGURATION ===
class LevelConfig {
  final double pacmanSpeed; // cells per tick
  final double ghostSpeed;
  final double frightenedGhostSpeed;
  final int frightenedDuration; // ms
  final double tunnelGhostSpeed;
  final List<int> scatterDurations; // ms
  final List<int> chaseDurations; // ms

  const LevelConfig({
    required this.pacmanSpeed,
    required this.ghostSpeed,
    required this.frightenedGhostSpeed,
    required this.frightenedDuration,
    required this.tunnelGhostSpeed,
    required this.scatterDurations,
    required this.chaseDurations,
  });
}

// Levels get progressively harder
const List<LevelConfig> kLevelConfigs = [
  // Level 1
  LevelConfig(
    pacmanSpeed: 0.8,
    ghostSpeed: 0.75,
    frightenedGhostSpeed: 0.5,
    frightenedDuration: 6000,
    tunnelGhostSpeed: 0.4,
    scatterDurations: [7000, 7000, 5000, 5000],
    chaseDurations: [20000, 20000, 20000, -1],
  ),
  // Level 2-4
  LevelConfig(
    pacmanSpeed: 0.9,
    ghostSpeed: 0.85,
    frightenedGhostSpeed: 0.55,
    frightenedDuration: 5000,
    tunnelGhostSpeed: 0.45,
    scatterDurations: [7000, 7000, 5000, 0],
    chaseDurations: [20000, 20000, 1033, -1],
  ),
  // Level 5+
  LevelConfig(
    pacmanSpeed: 1.0,
    ghostSpeed: 0.95,
    frightenedGhostSpeed: 0.6,
    frightenedDuration: 4000,
    tunnelGhostSpeed: 0.5,
    scatterDurations: [5000, 5000, 3000, 0],
    chaseDurations: [20000, 20000, 1033, -1],
  ),
];

LevelConfig getLevelConfig(int level) {
  if (level <= 1) return kLevelConfigs[0];
  if (level <= 4) return kLevelConfigs[1];
  return kLevelConfigs[2];
}
