import 'package:flutter/material.dart';
import '../constants.dart';
import '../services/audio_service.dart';

/// ============================================================================
/// PANTALLA DE CONFIGURACIÓN
/// Permite ajustar sonido, efectos visuales y otras opciones
/// ============================================================================

class SettingsScreen extends StatefulWidget {
  final VoidCallback? onSettingsChanged;
  
  const SettingsScreen({super.key, this.onSettingsChanged});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // Configuración de audio
  bool _soundEnabled = true;
  bool _musicEnabled = true;
  double _masterVolume = 0.7;
  double _sfxVolume = 0.8;
  double _musicVolume = 0.5;
  
  // Configuración visual
  bool _glowEnabled = true;
  bool _particlesEnabled = true;
  bool _screenShakeEnabled = true;
  
  // Configuración de controles
  bool _hapticsEnabled = true;
  
  final AudioService _audioService = AudioService();
  
  @override
  void initState() {
    super.initState();
    _loadSettings();
  }
  
  void _loadSettings() {
    // Cargar configuración guardada
    final audioSettings = _audioService.toJson();
    setState(() {
      _soundEnabled = audioSettings['soundEnabled'] ?? true;
      _musicEnabled = audioSettings['musicEnabled'] ?? true;
      _masterVolume = audioSettings['masterVolume'] ?? 0.7;
      _sfxVolume = audioSettings['sfxVolume'] ?? 0.8;
      _musicVolume = audioSettings['musicVolume'] ?? 0.5;
    });
  }
  
  void _saveSettings() {
    // Guardar configuración
    _audioService.setSoundEnabled(_soundEnabled);
    _audioService.setMusicEnabled(_musicEnabled);
    _audioService.setMasterVolume(_masterVolume);
    _audioService.setSfxVolume(_sfxVolume);
    _audioService.setMusicVolume(_musicVolume);
    
    widget.onSettingsChanged?.call();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: NeonColors.darkerBg,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              NeonColors.darkerBg,
              NeonColors.darkBg,
              NeonColors.darkerBg,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildAudioSection(),
                      const SizedBox(height: 30),
                      _buildVisualSection(),
                      const SizedBox(height: 30),
                      _buildControlsSection(),
                      const SizedBox(height: 30),
                      _buildAboutSection(),
                    ],
                  ),
                ),
              ),
              _buildFooter(),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: NeonColors.primaryNeon),
            onPressed: () {
              _saveSettings();
              Navigator.of(context).pop();
            },
          ),
          const SizedBox(width: 10),
          const Text(
            'CONFIGURACIÓN',
            style: TextStyle(
              fontFamily: TextStyles.neonFont,
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 3,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildAudioSection() {
    return _buildSection(
      title: 'AUDIO',
      icon: Icons.volume_up,
      children: [
        _buildToggleSetting(
          title: 'Sonido',
          subtitle: 'Activar/desactivar efectos de sonido',
          value: _soundEnabled,
          onChanged: (value) {
            setState(() => _soundEnabled = value);
            _saveSettings();
          },
        ),
        const SizedBox(height: 15),
        _buildToggleSetting(
          title: 'Música',
          subtitle: 'Activar/desactivar música de fondo',
          value: _musicEnabled,
          onChanged: (value) {
            setState(() => _musicEnabled = value);
            _saveSettings();
          },
        ),
        const SizedBox(height: 20),
        _buildSliderSetting(
          title: 'Volumen Maestro',
          value: _masterVolume,
          min: 0.0,
          max: 1.0,
          divisions: 20,
          label: '${(_masterVolume * 100).toInt()}%',
          onChanged: (value) {
            setState(() => _masterVolume = value);
            _saveSettings();
          },
        ),
        const SizedBox(height: 15),
        _buildSliderSetting(
          title: 'Volumen Efectos',
          value: _sfxVolume,
          min: 0.0,
          max: 1.0,
          divisions: 20,
          label: '${(_sfxVolume * 100).toInt()}%',
          onChanged: (value) {
            setState(() => _sfxVolume = value);
            _saveSettings();
          },
        ),
        const SizedBox(height: 15),
        _buildSliderSetting(
          title: 'Volumen Música',
          value: _musicVolume,
          min: 0.0,
          max: 1.0,
          divisions: 20,
          label: '${(_musicVolume * 100).toInt()}%',
          onChanged: (value) {
            setState(() => _musicVolume = value);
            _saveSettings();
          },
        ),
      ],
    );
  }
  
  Widget _buildVisualSection() {
    return _buildSection(
      title: 'VISUALES',
      icon: Icons.palette,
      children: [
        _buildToggleSetting(
          title: 'Efectos Neón',
          subtitle: 'Brillo y efectos de luz neón',
          value: _glowEnabled,
          onChanged: (value) {
            setState(() => _glowEnabled = value);
            _saveSettings();
          },
        ),
        const SizedBox(height: 15),
        _buildToggleSetting(
          title: 'Partículas',
          subtitle: 'Efectos de partículas al comer y capturar',
          value: _particlesEnabled,
          onChanged: (value) {
            setState(() => _particlesEnabled = value);
            _saveSettings();
          },
        ),
        const SizedBox(height: 15),
        _buildToggleSetting(
          title: 'Temblor de Pantalla',
          subtitle: 'Efecto de vibración visual',
          value: _screenShakeEnabled,
          onChanged: (value) {
            setState(() => _screenShakeEnabled = value);
            _saveSettings();
          },
        ),
      ],
    );
  }
  
  Widget _buildControlsSection() {
    return _buildSection(
      title: 'CONTROLES',
      icon: Icons.gamepad,
      children: [
        _buildToggleSetting(
          title: 'Vibración Háptica',
          subtitle: 'Retroalimentación táctil al jugar',
          value: _hapticsEnabled,
          onChanged: (value) {
            setState(() => _hapticsEnabled = value);
            _saveSettings();
          },
        ),
      ],
    );
  }
  
  Widget _buildAboutSection() {
    return _buildSection(
      title: 'ACERCA DE',
      icon: Icons.info,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: NeonColors.uiPanelBg,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: NeonColors.uiBorder.withOpacity(0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'PAC-MAN NEON EDITION',
                style: TextStyle(
                  fontFamily: TextStyles.neonFont,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: NeonColors.primaryNeon,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Versión 2.0.0\n\nUna reinterpretación moderna del clásico juego de arcade con gráficos neón futuristas y efectos visuales espectaculares.',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 15),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildStatBox('NIVELES', '99'),
                  _buildStatBox('MAPAS', '5'),
                  _buildStatBox('FANTASMAS', '4'),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
  
  Widget _buildStatBox(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontFamily: TextStyles.neonFont,
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: NeonColors.textAccent,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white54,
            fontSize: 10,
            letterSpacing: 1,
          ),
        ),
      ],
    );
  }
  
  Widget _buildFooter() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton.icon(
            onPressed: () {
              _resetToDefaults();
            },
            icon: const Icon(Icons.refresh, color: Colors.black),
            label: const Text(
              'RESTAURAR VALORES',
              style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: NeonColors.uiPanelBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: NeonColors.uiBorder.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: NeonColors.primaryNeon, size: 24),
              const SizedBox(width: 10),
              Text(
                title,
                style: const TextStyle(
                  fontFamily: TextStyles.neonFont,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          ...children,
        ],
      ),
    );
  }
  
  Widget _buildToggleSetting({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                subtitle,
                style: const TextStyle(
                  color: Colors.white54,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: NeonColors.primaryNeon,
          activeTrackColor: NeonColors.primaryNeon.withOpacity(0.5),
        ),
      ],
    );
  }
  
  Widget _buildSliderSetting({
    required String title,
    required double value,
    required double min,
    required double max,
    required int? divisions,
    required String label,
    required ValueChanged<double> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              label,
              style: const TextStyle(
                color: NeonColors.primaryNeon,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Slider(
          value: value,
          min: min,
          max: max,
          divisions: divisions,
          label: label,
          activeColor: NeonColors.primaryNeon,
          inactiveColor: NeonColors.primaryNeon.withOpacity(0.3),
          onChanged: onChanged,
        ),
      ],
    );
  }
  
  void _resetToDefaults() {
    setState(() {
      _soundEnabled = true;
      _musicEnabled = true;
      _masterVolume = 0.7;
      _sfxVolume = 0.8;
      _musicVolume = 0.5;
      _glowEnabled = true;
      _particlesEnabled = true;
      _screenShakeEnabled = true;
      _hapticsEnabled = true;
    });
    _saveSettings();
  }
}
