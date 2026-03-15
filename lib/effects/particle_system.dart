import 'dart:math';
import 'package:flutter/material.dart';
import '../constants.dart';

/// ============================================================================
/// SISTEMA DE PARTÍCULAS NEÓN
/// Para efectos visuales al comer puntos, fantasmas, power-ups, etc.
/// ============================================================================

enum ParticleType {
  dot,           // Partícula de punto normal
  powerPellet,   // Partícula de power pellet
  eatGhost,      // Partícula al comer fantasma
  speedBoost,    // Partícula de velocidad
  freezeGhost,   // Partícula de congelar
  fruit,         // Partícula de fruta
  explosion,     // Partícula de explosión
  spark,         // Chispa decorativa
  trail,         // Estela de movimiento
}

class Particle {
  double x, y;
  double vx, vy;
  double lifetime;
  double maxLifetime;
  Color color;
  ParticleType type;
  double size;
  double rotation;
  double rotationSpeed;
  bool useGlow;
  
  Particle({
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    required this.color,
    required this.type,
    this.size = 3.0,
    this.lifetime = 1.0,
    this.useGlow = true,
  })  : maxLifetime = lifetime,
        rotation = Random().nextDouble() * 2 * pi,
        rotationSpeed = (Random().nextDouble() - 0.5) * 4;
  
  /// Actualiza la partícula
  void update(double dt) {
    x += vx * dt;
    y += vy * dt;
    lifetime -= dt;
    rotation += rotationSpeed * dt;
    
    // Fricción
    vx *= 0.98;
    vy *= 0.98;
    
    // Gravedad ligera para algunas partículas
    if (type == ParticleType.explosion) {
      vy += 5 * dt;
    }
  }
  
  /// Verifica si la partícula sigue viva
  bool get isAlive => lifetime > 0;
  
  /// Obtiene la opacidad basada en la vida restante
  double get opacity => (lifetime / maxLifetime).clamp(0.0, 1.0);
  
  /// Obtiene el tamaño actual (se encoge al morir)
  double get currentSize => size * opacity;
}

class ParticleSystem {
  final List<Particle> particles = [];
  final int maxParticles;
  final Random _random = Random();
  
  ParticleSystem({this.maxParticles = 200});
  
  bool get isActive => particles.isNotEmpty;
  
  /// Emite partículas en una posición
  void emit({
    required double x,
    required double y,
    required ParticleType type,
    int count = 5,
    double speed = 50.0,
    double spread = 2 * pi,
    double? minSpeed,
    double? maxSpeed,
    Color? colorOverride,
    double? sizeOverride,
    double lifetime = 0.8,
  }) {
    for (int i = 0; i < count; i++) {
      if (particles.length >= maxParticles) {
        // Eliminar la partícula más vieja
        particles.removeAt(0);
      }
      
      // Determinar color
      Color color = colorOverride ?? _getColorForType(type);
      
      // Determinar velocidad
      double actualSpeed = speed;
      if (minSpeed != null && maxSpeed != null) {
        actualSpeed = minSpeed + _random.nextDouble() * (maxSpeed - minSpeed);
      }
      
      // Ángulo de dispersión
      double angle;
      if (spread >= 2 * pi) {
        angle = _random.nextDouble() * 2 * pi;
      } else {
        angle = _random.nextDouble() * spread - spread / 2;
      }
      
      double vx = cos(angle) * actualSpeed;
      double vy = sin(angle) * actualSpeed;
      
      // Tamaño
      double size = sizeOverride ?? _getSizeForType(type);
      
      particles.add(Particle(
        x: x,
        y: y,
        vx: vx,
        vy: vy,
        color: color,
        type: type,
        size: size,
        lifetime: lifetime * (0.8 + _random.nextDouble() * 0.4),
        useGlow: type != ParticleType.trail,
      ));
    }
  }
  
  /// Emite partículas en una dirección (para estelas)
  void emitTrail({
    required double x,
    required double y,
    required Direction direction,
    Color? color,
    double speed = 20.0,
  }) {
    Color particleColor = color ?? NeonColors.pacmanBody;
    
    double vx = 0, vy = 0;
    switch (direction) {
      case Direction.left: vx = -speed; break;
      case Direction.right: vx = speed; break;
      case Direction.up: vy = -speed; break;
      case Direction.down: vy = speed; break;
      case Direction.none: break;
    }
    
    particles.add(Particle(
      x: x,
      y: y,
      vx: vx,
      vy: vy,
      color: particleColor.withOpacity(0.6),
      type: ParticleType.trail,
      size: 2.0 + _random.nextDouble() * 2,
      lifetime: 0.3,
      useGlow: false,
    ));
  }
  
  /// Actualiza todas las partículas
  void update(double dt) {
    particles.removeWhere((p) => !p.isAlive);
    for (var particle in particles) {
      particle.update(dt);
    }
  }
  
  /// Dibuja todas las partículas
  void paint(Canvas canvas) {
    for (var particle in particles) {
      _drawParticle(canvas, particle);
    }
  }
  
  void _drawParticle(Canvas canvas, Particle particle) {
    final paint = Paint()
      ..color = particle.color.withOpacity(particle.opacity)
      ..style = PaintingStyle.fill;
    
    if (particle.useGlow && particle.opacity > 0.3) {
      // Efecto de brillo neón
      paint.maskFilter = MaskFilter.blur(
        BlurStyle.normal, 
        particle.currentSize * 1.5
      );
    }
    
    // Dibujar la partícula
    canvas.save();
    canvas.translate(particle.x, particle.y);
    canvas.rotate(particle.rotation);
    
    switch (particle.type) {
      case ParticleType.dot:
      case ParticleType.trail:
        canvas.drawCircle(Offset.zero, particle.currentSize, paint);
        break;
        
      case ParticleType.powerPellet:
        // Círculo más grande con brillo
        canvas.drawCircle(Offset.zero, particle.currentSize * 1.5, paint);
        break;
        
      case ParticleType.eatGhost:
        // Forma de estrella
        _drawStar(canvas, particle.currentSize * 1.5, 5, paint);
        break;
        
      case ParticleType.explosion:
        // Círculo que se expande
        canvas.drawCircle(Offset.zero, particle.currentSize * 2, paint);
        break;
        
      case ParticleType.spark:
        // Forma de diamante
        _drawDiamond(canvas, particle.currentSize, paint);
        break;
        
      case ParticleType.fruit:
        // Círculo pequeño
        canvas.drawCircle(Offset.zero, particle.currentSize, paint);
        break;
        
      case ParticleType.speedBoost:
      case ParticleType.freezeGhost:
        // Triángulo
        _drawTriangle(canvas, particle.currentSize, paint);
        break;
    }
    
    canvas.restore();
  }
  
  void _drawStar(Canvas canvas, double radius, int points, Paint paint) {
    final path = Path();
    for (int i = 0; i < points * 2; i++) {
      double r = (i % 2 == 0) ? radius : radius * 0.5;
      double angle = (i * pi / points) - pi / 2;
      Offset point = Offset(cos(angle) * r, sin(angle) * r);
      if (i == 0) {
        path.moveTo(point.dx, point.dy);
      } else {
        path.lineTo(point.dx, point.dy);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }
  
  void _drawDiamond(Canvas canvas, double size, Paint paint) {
    final path = Path();
    path.moveTo(0, -size);
    path.lineTo(size * 0.7, 0);
    path.lineTo(0, size);
    path.lineTo(-size * 0.7, 0);
    path.close();
    canvas.drawPath(path, paint);
  }
  
  void _drawTriangle(Canvas canvas, double size, Paint paint) {
    final path = Path();
    path.moveTo(0, -size);
    path.lineTo(size * 0.866, size * 0.5);
    path.lineTo(-size * 0.866, size * 0.5);
    path.close();
    canvas.drawPath(path, paint);
  }
  
  Color _getColorForType(ParticleType type) {
    switch (type) {
      case ParticleType.dot:
        return NeonColors.dotNeon;
      case ParticleType.powerPellet:
        return NeonColors.powerPelletNeon;
      case ParticleType.eatGhost:
        return NeonColors.primaryNeon;
      case ParticleType.speedBoost:
        return NeonColors.particleSpeed;
      case ParticleType.freezeGhost:
        return NeonColors.particleFreeze;
      case ParticleType.fruit:
        return Colors.redAccent;
      case ParticleType.explosion:
        return Colors.orange;
      case ParticleType.spark:
        return Colors.yellow;
      case ParticleType.trail:
        return NeonColors.pacmanBody;
    }
  }
  
  double _getSizeForType(ParticleType type) {
    switch (type) {
      case ParticleType.dot:
        return 2.0;
      case ParticleType.powerPellet:
        return 3.0;
      case ParticleType.eatGhost:
        return 4.0;
      case ParticleType.speedBoost:
      case ParticleType.freezeGhost:
        return 3.0;
      case ParticleType.fruit:
        return 2.5;
      case ParticleType.explosion:
        return 5.0;
      case ParticleType.spark:
        return 2.0;
      case ParticleType.trail:
        return 2.0;
    }
  }
  
  /// Limpia todas las partículas
  void clear() {
    particles.clear();
  }
  
  /// Obtiene el número de partículas activas
  int get count => particles.length;
}

/// ============================================================================
/// EFECTO DE TEMBLOR DE PANTALLA
/// ============================================================================

class ScreenShake {
  double intensity = 0;
  double duration = 0;
  double elapsed = 0;
  final Random _random = Random();
  
  bool get isActive => intensity > 0 && elapsed < duration;
  
  void trigger({double intensity = 4.0, int durationMs = 300}) {
    this.intensity = intensity;
    this.duration = durationMs / 1000.0;
    this.elapsed = 0;
  }
  
  void update(double dt) {
    if (isActive) {
      elapsed += dt;
      // Reducir intensidad con el tiempo
      intensity = intensity * 0.95;
    } else {
      intensity = 0;
    }
  }
  
  Offset get offset {
    if (!isActive) return Offset.zero;
    return Offset(
      (_random.nextDouble() - 0.5) * 2 * intensity,
      (_random.nextDouble() - 0.5) * 2 * intensity,
    );
  }
  
  void reset() {
    intensity = 0;
    duration = 0;
    elapsed = 0;
  }
}

/// ============================================================================
/// EFECTO DE ONDA DE CHOQUE
/// ============================================================================

class Shockwave {
  double x, y;
  double radius = 0;
  double maxRadius;
  double thickness;
  Color color;
  double opacity = 1.0;
  bool isActive = false;
  
  Shockwave({
    required this.x,
    required this.y,
    this.maxRadius = 100,
    this.thickness = 3,
    this.color = Colors.white,
  });
  
  void trigger({double? x, double? y}) {
    if (x != null) this.x = x;
    if (y != null) this.y = y;
    radius = 0;
    opacity = 1.0;
    isActive = true;
  }
  
  void update(double dt) {
    if (isActive) {
      radius += 150 * dt;
      opacity = 1.0 - (radius / maxRadius);
      if (radius >= maxRadius) {
        isActive = false;
      }
    }
  }
  
  void paint(Canvas canvas) {
    if (!isActive) return;
    
    final paint = Paint()
      ..color = color.withOpacity(opacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = thickness * opacity
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
    
    canvas.drawCircle(Offset(x, y), radius, paint);
  }
}
