import 'package:flutter/foundation.dart';

/// ============================================================================
/// SISTEMA DE AUDIO SINTETIZADO
/// Genera efectos de sonido programáticamente sin archivos externos
/// Usa la API de AudioContext del navegador (web) o flutter_sound
/// ============================================================================

class SoundEffect {
  final String name;
  final List<Note> notes;
  final Duration duration;
  
  SoundEffect({
    required this.name,
    required this.notes,
    required this.duration,
  });
}

class Note {
  final double frequency;
  final Duration startTime;
  final Duration duration;
  final String waveform; // 'sine', 'square', 'sawtooth', 'triangle'
  final double volume;
  
  Note({
    required this.frequency,
    required this.startTime,
    required this.duration,
    this.waveform = 'sine',
    this.volume = 0.5,
  });
}

/// ============================================================================
/// GENERADOR DE SONIDO
/// ============================================================================

class SoundGenerator {
  static final SoundGenerator _instance = SoundGenerator._internal();
  factory SoundGenerator() => _instance;
  SoundGenerator._internal();
  
  bool _isInitialized = false;
  double _masterVolume = 0.7;
  double _sfxVolume = 0.8;
  
  // Efectos de sonido predefinidos
  late SoundEffect wakaSound;
  late SoundEffect eatGhostSound;
  late SoundEffect dieSound;
  late SoundEffect powerupSound;
  late SoundEffect fruitSound;
  late SoundEffect readySound;
  late SoundEffect levelCompleteSound;
  late SoundEffect gameCompleteSound;
  late SoundEffect moveSound;
  late SoundEffect pauseSound;
  
  void initialize() {
    if (_isInitialized) return;
    
    _generateSounds();
    _isInitialized = true;
  }
  
  void _generateSounds() {
    // Sonido "Waka Waka" - comer puntos
    wakaSound = SoundEffect(
      name: 'waka',
      notes: [
        Note(frequency: 200, startTime: Duration.zero, duration: const Duration(milliseconds: 80), waveform: 'triangle'),
        Note(frequency: 400, startTime: const Duration(milliseconds: 100), duration: const Duration(milliseconds: 80), waveform: 'triangle'),
      ],
      duration: const Duration(milliseconds: 200),
    );
    
    // Comer fantasma
    eatGhostSound = SoundEffect(
      name: 'eatGhost',
      notes: [
        Note(frequency: 800, startTime: Duration.zero, duration: const Duration(milliseconds: 100), waveform: 'square', volume: 0.6),
        Note(frequency: 1200, startTime: const Duration(milliseconds: 80), duration: const Duration(milliseconds: 100), waveform: 'square', volume: 0.6),
        Note(frequency: 1600, startTime: const Duration(milliseconds: 160), duration: const Duration(milliseconds: 150), waveform: 'square', volume: 0.5),
      ],
      duration: const Duration(milliseconds: 350),
    );
    
    // Muerte de Pac-Man
    dieSound = SoundEffect(
      name: 'die',
      notes: [
        Note(frequency: 500, startTime: Duration.zero, duration: const Duration(milliseconds: 200), waveform: 'sawtooth'),
        Note(frequency: 400, startTime: const Duration(milliseconds: 180), duration: const Duration(milliseconds: 200), waveform: 'sawtooth'),
        Note(frequency: 300, startTime: const Duration(milliseconds: 360), duration: const Duration(milliseconds: 200), waveform: 'sawtooth'),
        Note(frequency: 200, startTime: const Duration(milliseconds: 540), duration: const Duration(milliseconds: 300), waveform: 'sawtooth'),
        Note(frequency: 100, startTime: const Duration(milliseconds: 800), duration: const Duration(milliseconds: 400), waveform: 'sawtooth'),
      ],
      duration: const Duration(milliseconds: 1200),
    );
    
    // Power-up (power pellet)
    powerupSound = SoundEffect(
      name: 'powerup',
      notes: [
        Note(frequency: 400, startTime: Duration.zero, duration: const Duration(milliseconds: 100), waveform: 'sine'),
        Note(frequency: 500, startTime: const Duration(milliseconds: 80), duration: const Duration(milliseconds: 100), waveform: 'sine'),
        Note(frequency: 600, startTime: const Duration(milliseconds: 160), duration: const Duration(milliseconds: 100), waveform: 'sine'),
        Note(frequency: 800, startTime: const Duration(milliseconds: 240), duration: const Duration(milliseconds: 150), waveform: 'sine'),
        Note(frequency: 1000, startTime: const Duration(milliseconds: 380), duration: const Duration(milliseconds: 200), waveform: 'sine'),
      ],
      duration: const Duration(milliseconds: 600),
    );
    
    // Comer fruta
    fruitSound = SoundEffect(
      name: 'fruit',
      notes: [
        Note(frequency: 600, startTime: Duration.zero, duration: const Duration(milliseconds: 80), waveform: 'triangle'),
        Note(frequency: 900, startTime: const Duration(milliseconds: 60), duration: const Duration(milliseconds: 80), waveform: 'triangle'),
        Note(frequency: 1200, startTime: const Duration(milliseconds: 120), duration: const Duration(milliseconds: 120), waveform: 'triangle'),
      ],
      duration: const Duration(milliseconds: 280),
    );
    
    // READY!
    readySound = SoundEffect(
      name: 'ready',
      notes: [
        Note(frequency: 523, startTime: Duration.zero, duration: const Duration(milliseconds: 150), waveform: 'square'), // C5
        Note(frequency: 659, startTime: const Duration(milliseconds: 120), duration: const Duration(milliseconds: 150), waveform: 'square'), // E5
        Note(frequency: 784, startTime: const Duration(milliseconds: 240), duration: const Duration(milliseconds: 200), waveform: 'square'), // G5
      ],
      duration: const Duration(milliseconds: 500),
    );
    
    // Nivel completado
    levelCompleteSound = SoundEffect(
      name: 'levelComplete',
      notes: [
        Note(frequency: 523, startTime: Duration.zero, duration: const Duration(milliseconds: 150), waveform: 'square'),
        Note(frequency: 659, startTime: const Duration(milliseconds: 120), duration: const Duration(milliseconds: 150), waveform: 'square'),
        Note(frequency: 784, startTime: const Duration(milliseconds: 240), duration: const Duration(milliseconds: 150), waveform: 'square'),
        Note(frequency: 1047, startTime: const Duration(milliseconds: 360), duration: const Duration(milliseconds: 300), waveform: 'square'),
      ],
      duration: const Duration(milliseconds: 700),
    );
    
    // Juego completado
    gameCompleteSound = SoundEffect(
      name: 'gameComplete',
      notes: [
        Note(frequency: 523, startTime: Duration.zero, duration: const Duration(milliseconds: 200), waveform: 'square'),
        Note(frequency: 659, startTime: const Duration(milliseconds: 180), duration: const Duration(milliseconds: 200), waveform: 'square'),
        Note(frequency: 784, startTime: const Duration(milliseconds: 360), duration: const Duration(milliseconds: 200), waveform: 'square'),
        Note(frequency: 1047, startTime: const Duration(milliseconds: 540), duration: const Duration(milliseconds: 200), waveform: 'square'),
        Note(frequency: 1319, startTime: const Duration(milliseconds: 720), duration: const Duration(milliseconds: 200), waveform: 'square'),
        Note(frequency: 1568, startTime: const Duration(milliseconds: 900), duration: const Duration(milliseconds: 400), waveform: 'square'),
      ],
      duration: const Duration(milliseconds: 1400),
    );
    
    // Sonido de movimiento (opcional, muy suave)
    moveSound = SoundEffect(
      name: 'move',
      notes: [
        Note(frequency: 100, startTime: Duration.zero, duration: const Duration(milliseconds: 30), waveform: 'sine', volume: 0.1),
      ],
      duration: const Duration(milliseconds: 50),
    );
    
    // Pausa
    pauseSound = SoundEffect(
      name: 'pause',
      notes: [
        Note(frequency: 440, startTime: Duration.zero, duration: const Duration(milliseconds: 100), waveform: 'sine'),
        Note(frequency: 440, startTime: const Duration(milliseconds: 150), duration: const Duration(milliseconds: 100), waveform: 'sine'),
      ],
      duration: const Duration(milliseconds: 300),
    );
  }
  
  /// Reproduce un efecto de sonido
  void play(SoundEffect effect, {double? volume}) {
    if (!_isInitialized) initialize();
    
    double actualVolume = (volume ?? _sfxVolume) * _masterVolume;
    
    // En web, usar Web Audio API
    if (kIsWeb) {
      _playWeb(effect, actualVolume);
    } else {
      // En móvil, se podría usar audioplayers o flutter_sound
      // Por ahora, usamos una implementación básica
      _playBasic(effect, actualVolume);
    }
  }
  
  void _playWeb(SoundEffect effect, double volume) {
    // JavaScript interop para Web Audio API
    // Esto se ejecutaría en el navegador
    try {
      // El código JS se inyectaría aquí
      // Por simplicidad, no lo implementamos completamente
    } catch (e) {
      debugPrint('Error playing sound: $e');
    }
  }
  
  void _playBasic(SoundEffect effect, double volume) {
    // Implementación básica para plataformas móviles
    // Se podría expandir usando audioplayers
    for (var note in effect.notes) {
      // Simulación básica - en producción usar audioplayers
      debugPrint('Playing note: ${note.frequency}Hz at ${note.startTime}');
    }
  }
  
  // Métodos convenientes para reproducir efectos específicos
  void playWaka() => play(wakaSound);
  void playEatGhost() => play(eatGhostSound);
  void playDie() => play(dieSound);
  void playPowerup() => play(powerupSound);
  void playFruit() => play(fruitSound);
  void playReady() => play(readySound);
  void playLevelComplete() => play(levelCompleteSound);
  void playGameComplete() => play(gameCompleteSound);
  void playPause() => play(pauseSound);
  
  /// Ajusta el volumen maestro
  void setMasterVolume(double volume) {
    _masterVolume = volume.clamp(0.0, 1.0);
  }
  
  /// Ajusta el volumen de efectos
  void setSfxVolume(double volume) {
    _sfxVolume = volume.clamp(0.0, 1.0);
  }
  
  /// Obtiene el volumen maestro
  double get masterVolume => _masterVolume;
  
  /// Obtiene el volumen de efectos
  double get sfxVolume => _sfxVolume;
  
  /// Activa/desactiva el sonido
  void setEnabled(bool enabled) {
    _masterVolume = enabled ? 0.7 : 0.0;
  }
  
  bool get isEnabled => _masterVolume > 0;
}

/// ============================================================================
/// SERVICIO DE AUDIO
/// Gestiona el audio del juego de forma centralizada
/// ============================================================================

class AudioService {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal();
  
  final SoundGenerator _soundGenerator = SoundGenerator();
  
  bool _soundEnabled = true;
  bool _musicEnabled = true;
  double _masterVolume = 0.7;
  double _sfxVolume = 0.8;
  double _musicVolume = 0.5;
  
  void initialize() {
    _soundGenerator.initialize();
  }
  
  // Efectos de sonido
  void playWaka() {
    if (_soundEnabled) _soundGenerator.playWaka();
  }
  
  void playEatGhost() {
    if (_soundEnabled) _soundGenerator.playEatGhost();
  }
  
  void playDie() {
    if (_soundEnabled) _soundGenerator.playDie();
  }
  
  void playPowerup() {
    if (_soundEnabled) _soundGenerator.playPowerup();
  }
  
  void playFruit() {
    if (_soundEnabled) _soundGenerator.playFruit();
  }
  
  void playReady() {
    if (_soundEnabled) _soundGenerator.playReady();
  }
  
  void playLevelComplete() {
    if (_soundEnabled) _soundGenerator.playLevelComplete();
  }
  
  void playGameComplete() {
    if (_soundEnabled) _soundGenerator.playGameComplete();
  }
  
  void playPause() {
    if (_soundEnabled) _soundGenerator.playPause();
  }
  
  // Configuración
  void setSoundEnabled(bool enabled) {
    _soundEnabled = enabled;
    _soundGenerator.setEnabled(enabled);
  }
  
  void setMusicEnabled(bool enabled) {
    _musicEnabled = enabled;
  }
  
  void setMasterVolume(double volume) {
    _masterVolume = volume.clamp(0.0, 1.0);
    _soundGenerator.setMasterVolume(_masterVolume);
  }
  
  void setSfxVolume(double volume) {
    _sfxVolume = volume.clamp(0.0, 1.0);
    _soundGenerator.setSfxVolume(_sfxVolume);
  }
  
  void setMusicVolume(double volume) {
    _musicVolume = volume.clamp(0.0, 1.0);
  }
  
  // Getters
  bool get soundEnabled => _soundEnabled;
  bool get musicEnabled => _musicEnabled;
  double get masterVolume => _masterVolume;
  double get sfxVolume => _sfxVolume;
  double get musicVolume => _musicVolume;
  
  /// Guarda la configuración
  Map<String, dynamic> toJson() {
    return {
      'soundEnabled': _soundEnabled,
      'musicEnabled': _musicEnabled,
      'masterVolume': _masterVolume,
      'sfxVolume': _sfxVolume,
      'musicVolume': _musicVolume,
    };
  }
  
  /// Carga la configuración
  void fromJson(Map<String, dynamic> data) {
    _soundEnabled = data['soundEnabled'] ?? true;
    _musicEnabled = data['musicEnabled'] ?? true;
    _masterVolume = (data['masterVolume'] ?? 0.7).toDouble();
    _sfxVolume = (data['sfxVolume'] ?? 0.8).toDouble();
    _musicVolume = (data['musicVolume'] ?? 0.5).toDouble();
    
    _soundGenerator.setMasterVolume(_masterVolume);
    _soundGenerator.setSfxVolume(_sfxVolume);
    _soundGenerator.setEnabled(_soundEnabled);
  }
}
