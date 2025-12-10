import 'package:flutter/material.dart';
import 'package:pixel_adventure/components/physics/kina_physics.dart';

/// Exemplos práticos de uso do sistema Kina
///
/// Este arquivo demonstra diferentes formas de configurar e usar
/// o sistema de física Kina no seu jogo.

void main() {
  runApp(const KinaExamplesApp());
}

class KinaExamplesApp extends StatelessWidget {
  const KinaExamplesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kina Physics Examples',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const KinaExamplesPage(),
    );
  }
}

class KinaExamplesPage extends StatefulWidget {
  const KinaExamplesPage({super.key});

  @override
  State<KinaExamplesPage> createState() => _KinaExamplesPageState();
}

class _KinaExamplesPageState extends State<KinaExamplesPage> {
  String _selectedConfig = 'Normal';
  String _output = 'Selecione uma configuração para ver os detalhes';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kina Physics - Exemplos'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Configurações Pré-definidas',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              children: [
                _buildConfigButton('Easy'),
                _buildConfigButton('Normal'),
                _buildConfigButton('Hard'),
                _buildConfigButton('Speedrun'),
                _buildConfigButton('Custom'),
              ],
            ),
            const SizedBox(height: 24),
            const Text(
              'Detalhes da Configuração',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: SingleChildScrollView(
                  child: Text(
                    _output,
                    style: const TextStyle(fontFamily: 'monospace'),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConfigButton(String name) {
    return ElevatedButton(
      onPressed: () => _selectConfig(name),
      style: ElevatedButton.styleFrom(
        backgroundColor: _selectedConfig == name ? Colors.blue : Colors.grey,
      ),
      child: Text(name),
    );
  }

  void _selectConfig(String name) {
    setState(() {
      _selectedConfig = name;
      _output = _getConfigDetails(name);
    });
  }

  String _getConfigDetails(String name) {
    switch (name) {
      case 'Easy':
        return _formatConfig(KinaConfig.easy, 'FÁCIL - Para Iniciantes');
      case 'Normal':
        return _formatConfig(KinaConfig.normal, 'NORMAL - Balanceado');
      case 'Hard':
        return _formatConfig(KinaConfig.hard, 'DIFÍCIL - Para Avançados');
      case 'Speedrun':
        return _formatConfig(KinaConfig.speedrun, 'SPEEDRUN - Impulsos Altos');
      case 'Custom':
        return _getCustomExample();
      default:
        return '';
    }
  }

  String _formatConfig(KinaConfig config, String title) {
    // Determinar o nome da config baseado no título
    String configName = 'normal';
    if (title.contains('FÁCIL')) {
      configName = 'easy';
    } else if (title.contains('DIFÍCIL')) {
      configName = 'hard';
    } else if (title.contains('SPEEDRUN')) {
      configName = 'speedrun';
    }

    return '''
═══════════════════════════════════════
  $title
═══════════════════════════════════════

📏 ZONAS DE DETECÇÃO
├─ Kina Normal: ${config.edgeZoneNormal} pixels
└─ Super Kina:  ${config.edgeZoneSuper} pixels

🚀 IMPULSOS - KINA NORMAL
├─ Horizontal: ${config.baseBoostXNormal}
└─ Vertical:   ${config.baseBoostYNormal}

⚡ IMPULSOS - SUPER KINA
├─ Horizontal: ${config.baseBoostXSuper}
└─ Vertical:   ${config.baseBoostYSuper}

⚙️ MULTIPLICADORES
├─ Mínimo:     ${config.minVelocityFactor}x
├─ Máximo:     ${config.maxVelocityFactor}x
└─ Threshold:  ${config.velocityThreshold}

⏱️ COOLDOWN
└─ ${config.kinaCooldown}s ${config.kinaCooldown > 0 ? '(ativo)' : '(desativado)'}

═══════════════════════════════════════
CÓDIGO PARA USAR:
═══════════════════════════════════════

KinaPhysics.config = KinaConfig.$configName;

═══════════════════════════════════════
''';
  }

  String _getCustomExample() {
    return '''
═══════════════════════════════════════
  CONFIGURAÇÃO CUSTOMIZADA
═══════════════════════════════════════

Você pode criar suas próprias configurações
personalizadas ajustando os parâmetros:

// Exemplo 1: Kina Generoso
KinaPhysics.config = KinaConfig(
  edgeZoneNormal: 10.0,     // Zona MUITO grande
  edgeZoneSuper: 4.0,       // Super kina fácil
  baseBoostXNormal: 80.0,   // Impulso forte
  baseBoostYNormal: 50.0,
  baseBoostXSuper: 150.0,
  baseBoostYSuper: 80.0,
  minVelocityFactor: 1.0,   // Sem penalidade
  debugMode: true,          // Ver logs
);

// Exemplo 2: Kina Preciso (Skill-based)
KinaPhysics.config = KinaConfig(
  edgeZoneNormal: 3.0,      // Zona pequena
  edgeZoneSuper: 1.0,       // Super kina difícil
  baseBoostXNormal: 40.0,   // Impulso moderado
  baseBoostYNormal: 25.0,
  baseBoostXSuper: 100.0,
  baseBoostYSuper: 55.0,
  kinaCooldown: 0.5,        // Cooldown alto
  minVelocityFactor: 0.2,   // Penalidade forte
);

// Exemplo 3: Kina Progressivo (por nível)
void setupKinaForLevel(int level) {
  if (level <= 2) {
    KinaPhysics.config = KinaConfig.easy;
  } else if (level <= 4) {
    KinaPhysics.config = KinaConfig.normal;
  } else if (level <= 6) {
    KinaPhysics.config = KinaConfig.hard;
  } else {
    // Níveis finais: muito difícil
    KinaPhysics.config = KinaConfig(
      edgeZoneNormal: 2.5,
      edgeZoneSuper: 0.8,
      baseBoostXNormal: 30.0,
      baseBoostYNormal: 18.0,
      kinaCooldown: 0.4,
    );
  }
}

═══════════════════════════════════════
PARÂMETROS DISPONÍVEIS:
═══════════════════════════════════════

• edgeZoneNormal      - Zona de kina normal (px)
• edgeZoneSuper       - Zona de super kina (px)
• collisionTolerance  - Tolerância anti-bug (px)
• baseBoostXNormal    - Impulso X normal
• baseBoostYNormal    - Impulso Y normal
• baseBoostXSuper     - Impulso X super
• baseBoostYSuper     - Impulso Y super
• minVelocityFactor   - Multiplicador mínimo
• maxVelocityFactor   - Multiplicador máximo
• velocityThreshold   - Velocidade de referência
• kinaCooldown        - Tempo entre kinas (s)
• debugMode           - Ativar logs detalhados

═══════════════════════════════════════
''';
  }
}

// ═══════════════════════════════════════════════════════════════
// EXEMPLOS DE INTEGRAÇÃO NO JOGO
// ═══════════════════════════════════════════════════════════════

/// Exemplo 1: Configuração básica no início do jogo
class Example1_BasicSetup {
  void setupGame() {
    // Usar configuração normal (balanceada)
    KinaPhysics.config = KinaConfig.normal;
  }
}

/// Exemplo 2: Configuração por nível
class Example2_LevelBased {
  void loadLevel(int levelIndex) {
    // Ajustar dificuldade baseado no nível
    if (levelIndex <= 1) {
      KinaPhysics.config = KinaConfig.easy;
    } else if (levelIndex <= 3) {
      KinaPhysics.config = KinaConfig.normal;
    } else {
      KinaPhysics.config = KinaConfig.hard;
    }

    // Resetar tempo ao trocar de nível
    KinaPhysics.resetTime();
  }
}

/// Exemplo 3: Configuração customizada
class Example3_CustomConfig {
  void setupCustomKina() {
    KinaPhysics.config = const KinaConfig(
      // Zonas médias
      edgeZoneNormal: 5.0,
      edgeZoneSuper: 1.8,

      // Impulsos fortes
      baseBoostXNormal: 65.0,
      baseBoostYNormal: 38.0,
      baseBoostXSuper: 130.0,
      baseBoostYSuper: 65.0,

      // Sem cooldown
      kinaCooldown: 0.0,

      // Debug ativado para tuning
      debugMode: true,
    );
  }
}

/// Exemplo 4: Modo debug para tuning
class Example4_DebugMode {
  void enableDebugMode() {
    KinaPhysics.config = const KinaConfig(
      debugMode: true, // Ativa logs detalhados

      // Usar valores padrão para testar
      edgeZoneNormal: 6.0,
      edgeZoneSuper: 2.0,
      baseBoostXNormal: 50.0,
      baseBoostYNormal: 30.0,
    );

    // Agora ao jogar, você verá logs como:
    // 🚀 KINA SUPER ATIVADO!
    //    Borda: right
    //    Distância: 1.23px
    //    Precisão: 87.5%
    //    Velocidade: 245.8
    //    Boost X: 98.4
    //    Boost Y: 52.5
  }
}

/// Exemplo 5: Sistema de dificuldade dinâmica
class Example5_DynamicDifficulty {
  int consecutiveKinas = 0;

  void onKinaTriggered(KinaResult result) {
    if (result.triggered) {
      consecutiveKinas++;

      // Aumentar dificuldade após muitos kinas seguidos
      if (consecutiveKinas >= 5) {
        _increaseDifficulty();
      }
    } else {
      consecutiveKinas = 0;
      _resetDifficulty();
    }
  }

  void _increaseDifficulty() {
    // Reduzir zonas de detecção
    KinaPhysics.config = const KinaConfig(
      edgeZoneNormal: 4.0, // Mais difícil
      edgeZoneSuper: 1.5,
      baseBoostXNormal: 45.0,
      baseBoostYNormal: 28.0,
    );
  }

  void _resetDifficulty() {
    KinaPhysics.config = KinaConfig.normal;
  }
}

/// Exemplo 6: Power-up temporário
class Example6_PowerUp {
  void activateSuperKinaPowerUp(double duration) {
    // Salvar configuração atual
    final originalConfig = KinaPhysics.config;

    // Ativar super kina fácil
    KinaPhysics.config = const KinaConfig(
      edgeZoneNormal: 12.0, // Zona MUITO grande
      edgeZoneSuper: 6.0,
      baseBoostXSuper: 200.0, // Impulsos MUITO fortes
      baseBoostYSuper: 100.0,
    );

    // Restaurar após duração
    Future.delayed(Duration(seconds: duration.toInt()), () {
      KinaPhysics.config = originalConfig;
    });
  }
}
