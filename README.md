# 🕹️ PAC-MAN NEON EDITION

Una reinterpretación moderna del clásico juego de arcade **Pac-Man**, con gráficos neón futuristas, efectos visuales espectaculares y jugabilidad mejorada.

![Versión](https://img.shields.io/badge/versión-2.0.0-blue)
![Flutter](https://img.shields.io/badge/Flutter-3.0+-02569B?logo=flutter)
![Plataformas](https://img.shields.io/badge/plataformas-Android%20%7C%20iOS%20%7C%20Web-lightgrey)

---

## ✨ Características

### 🎮 Jugabilidad Clásica Mejorada
- **Mecánicas originales** del Pac-Man respetadas
- **4 fantasmas** con comportamientos únicos:
  - **BLINKY** (Rojo) - Perseguidor directo
  - **PINKY** (Rosa) - Emboscador
  - **INKY** (Cyan) - Impredecible
  - **CLYDE** (Naranja) - Aleatorio

### 🎨 Diseño Neón Futurista
- Gráficos **neón brillantes** con efectos de glow
- **5 diseños de mapas** diferentes:
  - Clásico
  - Moderno
  - Laberinto
  - Arena
  - Velocidad
- **Animaciones fluidas** a 60 FPS
- **Sistema de partículas** para efectos visuales

### 🔊 Audio Inmersivo
- Efectos de sonido **sintetizados**
- Música dinámica (próximamente)
- Control de volumen independiente

### 📱 Controles Multiplataforma
- **Controles táctiles** con D-Pad virtual
- **Teclado** (flechas direccionales)
- **Gestos** (deslizar para mover)
- Compatible con **gamepads** (próximamente)

### 🏆 Sistema de Puntuación
- **High Score** persistente
- **Combo multiplier** al comer fantasmas
- **99 niveles** de dificultad progresiva
- **Vidas extra** cada 10,000 puntos

### ⚡ Power-Ups Especiales
- **Power Pellets** - Los fantasmas se vuelven vulnerables
- **Speed Boost** - Aumenta temporalmente la velocidad
- **Freeze Ghost** - Congela a los fantasmas

---

## 🚀 Instalación

### Requisitos Previos
- **Flutter SDK** 3.0 o superior
- **Dart SDK** 3.0 o superior
- Android Studio / VS Code / Xcode

### Pasos de Instalación

1. **Clonar el repositorio**
```bash
cd pacman_game
```

2. **Instalar dependencias**
```bash
flutter pub get
```

3. **Ejecutar el juego**
```bash
# Android
flutter run

# iOS
flutter run

# Web
flutter run -d chrome

# Windows
flutter run -d windows
```

---

## 🎯 Cómo Jugar

### Objetivo
Come todos los puntos del mapa sin ser atrapado por los fantasmas.

### Controles

| Acción | Teclado | Táctil |
|--------|---------|--------|
| Mover arriba | ↑ | Deslizar arriba / D-Pad |
| Mover abajo | ↓ | Deslizar abajo / D-Pad |
| Mover izquierda | ← | Deslizar izquierda / D-Pad |
| Mover derecha | → | Deslizar derecha / D-Pad |
| Pausa | Espacio | Botón de pausa |

### Puntuación

| Elemento | Puntos |
|----------|--------|
| Punto normal | 10 |
| Power Pellet | 50 |
| Fantasma (1º) | 200 |
| Fantasma (2º) | 400 |
| Fantasma (3º) | 800 |
| Fantasma (4º) | 1600 |
| Cereza | 100 |
| Fresa | 300 |
| Naranja | 500 |
| Manzana | 700 |
| Melón | 1000 |
| Galaxia | 2000 |
| Diamante | 3000 |
| Corona | 5000 |

---

## 🛠️ Estructura del Proyecto

```
pacman_game/
├── lib/
│   ├── constants.dart         # Constantes y configuraciones
│   ├── main.dart              # Punto de entrada
│   ├── game_screen.dart       # Pantalla principal de juego
│   ├── game_map.dart          # Mapas y niveles
│   ├── game_painter.dart      # Renderizado gráfico
│   ├── ghost.dart             # Lógica de fantasmas
│   ├── effects/
│   │   └── particle_system.dart  # Sistema de partículas
│   ├── screens/
│   │   └── settings_screen.dart  # Pantalla de configuración
│   ├── services/
│   │   └── audio_service.dart    # Servicio de audio
│   └── widgets/               # Componentes UI reutilizables
├── assets/
│   ├── audio/                 # Archivos de audio
│   └── fonts/                 # Fuentes personalizadas
├── pubspec.yaml               # Dependencias
└── README.md                  # Este archivo
```

---

## ⚙️ Configuración

### Opciones Disponibles

- **Audio**
  - Volumen maestro
  - Volumen de efectos
  - Volumen de música
  - Activar/desactivar sonido

- **Visuales**
  - Efectos neón
  - Partículas
  - Temblor de pantalla

- **Controles**
  - Vibración háptica

---

## 🎨 Tecnologías Utilizadas

- **Flutter** - Framework UI
- **Dart** - Lenguaje de programación
- **CustomPainter** - Renderizado gráfico personalizado
- **Audio** - Síntesis de sonido programática
- **Animations** - Sistema de animaciones de Flutter

---

## 👻 Personalidades de los Fantasmas

### Blinky (Rojo)
- **Personalidad**: Perseguidor
- **Comportamiento**: Persigue directamente a Pac-Man
- **Habilidad**: 10% más rápido que los demás

### Pinky (Rosa)
- **Personalidad**: Emboscador
- **Comportamiento**: Apunta 4 casillas delante de Pac-Man
- **Estrategia**: Intenta cortar el camino

### Inky (Cyan)
- **Personalidad**: Impredecible
- **Comportamiento**: Usa la posición de Blinky para calcular objetivo
- **Estrategia**: Ataque coordinado

### Clyde (Naranja)
- **Personalidad**: Aleatorio
- **Comportamiento**: Persigue si está lejos, scatter si está cerca
- **Estrategia**: Impredecible

---

## 📊 Niveles y Dificultad

El juego cuenta con **99 niveles** de dificultad progresiva:

| Nivel | Velocidad Pac-Man | Velocidad Fantasmas | Duración Power Pellet |
|-------|-------------------|---------------------|----------------------|
| 1 | 0.75x | 0.70x | 6000ms |
| 2-4 | 0.80-0.85x | 0.75-0.80x | 5500-5000ms |
| 5-8 | 0.90-0.95x | 0.85-0.90x | 4500-3000ms |
| 9+ | 1.0x | 0.95x | 2500ms |

Cada 5 niveles, el mapa cambia a un diseño diferente.

---

## 🐛 Solución de Problemas

### El juego va lento
- Reduce los efectos de partículas en Configuración
- Desactiva el brillo neón

### No hay sonido
- Verifica que el sonido esté activado en Configuración
- Sube el volumen maestro

### Los controles no responden
- Asegúrate de que el juego tenga el foco
- En móvil, usa el D-Pad virtual o gestos

---

## 📝 Licencia

Este proyecto es una reinterpretación educativa del clásico Pac-Man de Namco. Todos los derechos del personaje original pertenecen a Bandai Namco Entertainment.

---

## 🙏 Créditos

- **Diseño original**: Namco (1980)
- **Reinterpretación Neón**: Desarrollado con Flutter
- **Gráficos**: CustomPainter con efectos de brillo
- **Audio**: Síntesis programática

---

## 📞 Contacto

¿Tienes sugerencias o encontraste un bug? ¡Abre un issue en el repositorio!

---

**¡Disfruta del juego! 🎮✨**
