import 'dart:math' show sin;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'constants.dart';
import 'game_screen.dart';
import 'screens/settings_screen.dart';
import 'services/audio_service.dart';

/// ============================================================================
/// PAC-MAN NEON EDITION - PUNTO DE ENTRADA PRINCIPAL
/// Una reinterpretación moderna del clásico juego de arcade
/// con gráficos neón futuristas y efectos espectaculares
/// ============================================================================

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Configurar orientación de pantalla
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);
  
  // Modo inmersivo
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  
  // Inicializar servicio de audio
  final audioService = AudioService();
  audioService.initialize();
  
  runApp(const PacmanApp());
}

class PacmanApp extends StatelessWidget {
  const PacmanApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PAC-MAN NEON',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: NeonColors.darkerBg,
        primaryColor: NeonColors.primaryNeon,
        colorScheme: const ColorScheme.dark(
          primary: NeonColors.primaryNeon,
          secondary: NeonColors.secondaryNeon,
          tertiary: NeonColors.accentNeon,
        ),
        fontFamily: TextStyles.neonFont,
      ),
      home: const MainMenuScreen(),
    );
  }
}

/// ============================================================================
/// PANTALLA DE MENÚ PRINCIPAL
/// Con acceso a juego, configuración y leaderboard
/// ============================================================================

class MainMenuScreen extends StatefulWidget {
  const MainMenuScreen({super.key});

  @override
  State<MainMenuScreen> createState() => _MainMenuScreenState();
}

class _MainMenuScreenState extends State<MainMenuScreen> with TickerProviderStateMixin {
  int highScore = 0;
  bool _showSettings = false;
  
  @override
  void initState() {
    super.initState();
    _loadHighScore();
  }
  
  void _loadHighScore() {
    // Cargar high score desde almacenamiento persistente
    setState(() {
      highScore = 0; // Se cargará desde SharedPreferences en implementación completa
    });
  }
  
  @override
  Widget build(BuildContext context) {
    if (_showSettings) {
      return SettingsScreen(
        onSettingsChanged: () {
          setState(() {});
        },
      );
    }
    
    return GestureDetector(
      onTap: () {
        _startGame();
      },
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              NeonColors.darkerBg,
              NeonColors.darkBg.withOpacity(0.8),
              NeonColors.darkerBg,
            ],
            stops: const [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Título con efecto neón animado
                      _buildAnimatedTitle(),
                      
                      const SizedBox(height: 50),
                      
                      // Animación de fantasmas
                      _buildGhostParade(),
                      
                      const SizedBox(height: 60),
                      
                      // Botón de jugar
                      _buildPlayButton(),
                      
                      const SizedBox(height: 20),
                      
                      // Botones secundarios
                      _buildSecondaryButtons(),
                      
                      const SizedBox(height: 40),
                      
                      // High Score
                      if (highScore > 0) _buildHighScoreDisplay(),
                    ],
                  ),
                ),
              ),
              
              // Footer con instrucciones
              _buildFooter(),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildAnimatedTitle() {
    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0, end: 1),
      duration: const Duration(milliseconds: 1500),
      builder: (context, double value, child) {
        return Transform.scale(
          scale: 0.8 + 0.2 * value,
          child: Opacity(
            opacity: value,
            child: child,
          ),
        );
      },
      child: ShaderMask(
        shaderCallback: (bounds) => LinearGradient(
          colors: [
            NeonColors.primaryNeon,
            NeonColors.secondaryNeon,
            NeonColors.accentNeon,
            NeonColors.primaryNeon,
          ],
          stops: const [0.0, 0.33, 0.66, 1.0],
        ).createShader(bounds),
        child: const Text(
          'PAC-MAN',
          style: TextStyle(
            fontSize: 56,
            fontWeight: FontWeight.bold,
            letterSpacing: 10,
            color: Colors.white,
            shadows: [
              Shadow(
                color: NeonColors.primaryNeon,
                blurRadius: 25,
              ),
              Shadow(
                color: NeonColors.secondaryNeon,
                blurRadius: 50,
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildGhostParade() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildAnimatedGhost(kBlinkyColor, 'BLINKY', 0),
        const SizedBox(width: 10),
        _buildAnimatedGhost(kPinkyColor, 'PINKY', 1),
        const SizedBox(width: 10),
        _buildAnimatedGhost(kInkyColor, 'INKY', 2),
        const SizedBox(width: 10),
        _buildAnimatedGhost(kClydeColor, 'CLYDE', 3),
      ],
    );
  }
  
  Widget _buildAnimatedGhost(Color color, String name, int index) {
    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0, end: 1),
      duration: Duration(milliseconds: 500 + index * 200),
      builder: (context, double value, child) {
        return Transform.translate(
          offset: Offset(0, sin((index * 2 + 0.05)) * 8 * value),
          child: child,
        );
      },
      child: Column(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.6),
                  blurRadius: 20,
                  spreadRadius: 3,
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          Text(
            name,
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildPlayButton() {
    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0, end: 1),
      duration: const Duration(milliseconds: 800),
      builder: (context, double value, child) {
        return Transform.scale(
          scale: value,
          child: child,
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              NeonColors.primaryNeon,
              NeonColors.secondaryNeon,
            ],
          ),
          borderRadius: BorderRadius.circular(35),
          boxShadow: [
            BoxShadow(
              color: NeonColors.primaryNeon.withOpacity(0.6),
              blurRadius: 25,
              spreadRadius: 4,
            ),
          ],
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.play_arrow, color: Colors.black, size: 32),
            SizedBox(width: 10),
            Text(
              'JUGAR',
              style: TextStyle(
                color: Colors.black,
                fontSize: 28,
                fontWeight: FontWeight.bold,
                letterSpacing: 4,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildSecondaryButtons() {
    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0, end: 1),
      duration: const Duration(milliseconds: 1000),
      builder: (context, double value, child) {
        return Opacity(
          opacity: value,
          child: child,
        );
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildSecondaryButton(
            icon: Icons.settings,
            label: 'OPCIONES',
            onTap: () {
              setState(() {
                _showSettings = true;
              });
            },
          ),
          const SizedBox(width: 20),
          _buildSecondaryButton(
            icon: Icons.leaderboard,
            label: 'RANKING',
            onTap: () {
              _showLeaderboard();
            },
          ),
        ],
      ),
    );
  }
  
  Widget _buildSecondaryButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(color: NeonColors.uiBorder, width: 1.5),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, color: NeonColors.primaryNeon, size: 28),
            const SizedBox(height: 6),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildHighScoreDisplay() {
    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0, end: 1),
      duration: const Duration(milliseconds: 1200),
      builder: (context, double value, child) {
        return Opacity(
          opacity: value,
          child: child,
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
        decoration: BoxDecoration(
          border: Border.all(color: NeonColors.accentNeon, width: 2),
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: NeonColors.accentNeon.withOpacity(0.3),
              blurRadius: 15,
            ),
          ],
        ),
        child: Column(
          children: [
            const Text(
              'HIGH SCORE',
              style: TextStyle(
                color: NeonColors.textAccent,
                fontSize: 14,
                letterSpacing: 3,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              highScore.toString().padLeft(8, '0'),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
                letterSpacing: 4,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildFooter() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const Text(
            'DESLIZA O USA LAS FLECHAS PARA MOVERTE',
            style: TextStyle(
              color: Colors.white38,
              fontSize: 11,
              letterSpacing: 2,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          const Text(
            'ESPACIO PARA PAUSA',
            style: TextStyle(
              color: Colors.white38,
              fontSize: 11,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildControlHint(Icons.touch_app, 'TÁCTIL'),
              const SizedBox(width: 20),
              _buildControlHint(Icons.keyboard, 'TECLADO'),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildControlHint(IconData icon, String label) {
    return Row(
      children: [
        Icon(icon, color: Colors.white54, size: 16),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white54,
            fontSize: 10,
          ),
        ),
      ],
    );
  }
  
  void _startGame() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const GameScreen(),
      ),
    );
  }
  
  void _showLeaderboard() {
    // Implementar leaderboard más adelante
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Leaderboard próximamente...'),
        backgroundColor: NeonColors.darkBg,
      ),
    );
  }
}
