import 'package:flame/components.dart';
import 'package:pixel_adventure/components/collision_block.dart';
import 'package:pixel_adventure/components/custom_hitbox.dart';
import 'package:pixel_adventure/components/player.dart';

/// Resultado da verificação de kina
class KinaResult {
  final bool triggered;
  final bool isSuperKina;
  final double boostX;
  final double boostY;
  final double precisionFactor;
  final String edgeType; // 'left' ou 'right'

  const KinaResult({
    required this.triggered,
    required this.isSuperKina,
    required this.boostX,
    required this.boostY,
    required this.precisionFactor,
    required this.edgeType,
  });

  /// Resultado vazio (sem kina)
  static const KinaResult none = KinaResult(
    triggered: false,
    isSuperKina: false,
    boostX: 0.0,
    boostY: 0.0,
    precisionFactor: 0.0,
    edgeType: '',
  );
}

/// Configuração de kina
class KinaConfig {
  // Zonas de detecção (em pixels)
  final double edgeZoneNormal;
  final double edgeZoneSuper;
  final double collisionTolerance;

  // Impulsos base - Kina Normal
  final double baseBoostXNormal;
  final double baseBoostYNormal;

  // Impulsos base - Super Kina
  final double baseBoostXSuper;
  final double baseBoostYSuper;

  // Multiplicadores de velocidade
  final double minVelocityFactor;
  final double maxVelocityFactor;
  final double velocityThreshold;

  // Cooldown (opcional)
  final double kinaCooldown;

  // Debug
  final bool debugMode;

  const KinaConfig({
    // Detecção
    this.edgeZoneNormal = 6.0,
    this.edgeZoneSuper = 2.0,
    this.collisionTolerance = 1.0,

    // Impulsos Normal
    this.baseBoostXNormal = 50.0,
    this.baseBoostYNormal = 30.0,

    // Impulsos Super
    this.baseBoostXSuper = 120.0,
    this.baseBoostYSuper = 60.0,

    // Multiplicadores
    this.minVelocityFactor = 0.5,
    this.maxVelocityFactor = 1.5,
    this.velocityThreshold = 300.0,

    // Cooldown
    this.kinaCooldown = 0.0, // 0 = sem cooldown

    // Debug
    this.debugMode = false,
  });

  /// Configuração FÁCIL (para iniciantes)
  static const KinaConfig easy = KinaConfig(
    edgeZoneNormal: 8.0,
    edgeZoneSuper: 3.0,
    baseBoostXNormal: 70.0,
    baseBoostYNormal: 40.0,
    baseBoostXSuper: 140.0,
    baseBoostYSuper: 70.0,
    minVelocityFactor: 0.8,
  );

  /// Configuração NORMAL (balanceada)
  static const KinaConfig normal = KinaConfig(
    edgeZoneNormal: 6.0,
    edgeZoneSuper: 2.0,
    baseBoostXNormal: 50.0,
    baseBoostYNormal: 30.0,
    baseBoostXSuper: 120.0,
    baseBoostYSuper: 60.0,
  );

  /// Configuração DIFÍCIL (para jogadores avançados)
  static const KinaConfig hard = KinaConfig(
    edgeZoneNormal: 4.0,
    edgeZoneSuper: 1.5,
    baseBoostXNormal: 35.0,
    baseBoostYNormal: 20.0,
    baseBoostXSuper: 100.0,
    baseBoostYSuper: 50.0,
    minVelocityFactor: 0.3,
    velocityThreshold: 250.0,
    kinaCooldown: 0.3,
  );

  /// Configuração SPEEDRUN (impulsos altos, zonas pequenas)
  static const KinaConfig speedrun = KinaConfig(
    edgeZoneNormal: 3.0,
    edgeZoneSuper: 1.0,
    baseBoostXNormal: 80.0,
    baseBoostYNormal: 45.0,
    baseBoostXSuper: 180.0,
    baseBoostYSuper: 90.0,
    maxVelocityFactor: 2.0,
  );
}

/// Sistema de física Kina
///
/// Implementa a mecânica de impulso ao colidir com extremidades de plataformas,
/// inspirada no jogo Transformice.
class KinaPhysics {
  static KinaConfig config = KinaConfig.normal;
  static double _lastKinaTime = 0.0;
  static double _currentTime = 0.0;

  /// Atualiza o tempo atual (chamar no update do jogo)
  static void updateTime(double dt) {
    _currentTime += dt;
  }

  /// Verifica se pode ativar kina (cooldown)
  static bool _canTriggerKina() {
    if (config.kinaCooldown <= 0) return true;
    return (_currentTime - _lastKinaTime) >= config.kinaCooldown;
  }

  /// Verifica condições básicas para kina
  static bool _checkBasicConditions({
    required Vector2 velocity,
    required PlayerState state,
  }) {
    // Deve estar em estado de queda (a velocidade já foi zerada na colisão)
    if (state != PlayerState.falling && state != PlayerState.falling_left) {
      return false;
    }

    // Verifica cooldown
    if (!_canTriggerKina()) return false;

    return true;
  }

  /// Calcula o fator de precisão (0.0 a 1.0)
  /// Quanto mais próximo de 1.0, mais preciso foi o acerto
  static double _calculatePrecisionFactor({
    required double edgeDistance,
    required double edgeZone,
  }) {
    if (edgeDistance >= edgeZone) return 0.0;
    return 1.0 - (edgeDistance / edgeZone);
  }

  /// Calcula o fator de velocidade baseado na velocidade de queda
  static double _calculateVelocityFactor(double velocityY) {
    final factor = velocityY.abs() / config.velocityThreshold;
    return factor.clamp(config.minVelocityFactor, config.maxVelocityFactor);
  }

  /// Verifica se a direção do movimento é compatível com a borda
  static bool _checkDirectionCompatibility({
    required String direction,
    required String edgeType,
    required Vector2 velocity,
  }) {
    if (edgeType == 'right') {
      // Para kina na borda direita, deve estar indo para direita
      return direction == 'right' && velocity.x >= 0;
    } else {
      // Para kina na borda esquerda, deve estar indo para esquerda
      return direction == 'left' && velocity.x <= 0;
    }
  }

  /// Verifica e calcula kina para uma colisão
  static KinaResult checkKinaCollision({
    required Vector2 playerPosition,
    required Vector2 playerVelocity,
    required CustomHitbox playerHitbox,
    required String playerDirection,
    required PlayerState playerState,
    required CollisionBlock block,
  }) {
    // Verificações básicas
    if (!_checkBasicConditions(
      velocity: playerVelocity,
      state: playerState,
    )) {
      return KinaResult.none;
    }

    // Calcula posições do jogador
    final playerLeft = playerPosition.x + playerHitbox.offsetX;
    final playerRight =
        playerPosition.x + playerHitbox.offsetX + playerHitbox.width;
    final blockLeft = block.isPlatform ? block.x : block.x - playerHitbox.width;
    final blockRight = block.isPlatform
        ? block.x + block.width
        : block.x + block.width + playerHitbox.width;

    // Verifica borda direita
    final distanceRightEdge = (playerRight - blockRight).abs();
    final isNearRightEdge = distanceRightEdge <= config.edgeZoneNormal;

    // Verifica borda esquerda
    final distanceLeftEdge = (playerLeft - blockLeft).abs();
    final isNearLeftEdge = distanceLeftEdge <= config.edgeZoneNormal;

    // Determina qual borda foi atingida
    String edgeType = '';
    double edgeDistance = 0.0;

    if (isNearRightEdge && playerDirection == 'right') {
      edgeType = 'right';
      edgeDistance = distanceRightEdge;
    } else if (isNearLeftEdge && playerDirection == 'left') {
      edgeType = 'left';
      edgeDistance = distanceLeftEdge;
    } else {
      // Não está em nenhuma borda válida
      return KinaResult.none;
    }

    // Verifica compatibilidade de direção
    if (!_checkDirectionCompatibility(
      direction: playerDirection,
      edgeType: edgeType,
      velocity: playerVelocity,
    )) {
      return KinaResult.none;
    }

    // Aplica tolerância
    if (edgeDistance > config.edgeZoneNormal + config.collisionTolerance) {
      return KinaResult.none;
    }

    // Determina se é Super Kina
    final isSuperKina = edgeDistance <= config.edgeZoneSuper;

    // Calcula fatores
    final precisionFactor = _calculatePrecisionFactor(
      edgeDistance: edgeDistance,
      edgeZone: isSuperKina ? config.edgeZoneSuper : config.edgeZoneNormal,
    );

    final velocityFactor = _calculateVelocityFactor(playerVelocity.y);

    // Calcula impulsos
    final baseBoostX =
        isSuperKina ? config.baseBoostXSuper : config.baseBoostXNormal;
    final baseBoostY =
        isSuperKina ? config.baseBoostYSuper : config.baseBoostYNormal;

    final boostX = baseBoostX * precisionFactor * velocityFactor;
    final boostY = baseBoostY * precisionFactor;

    // Aplica direção ao impulso horizontal
    final finalBoostX = edgeType == 'right' ? boostX : -boostX;

    // Atualiza tempo do último kina
    _lastKinaTime = _currentTime;

    // Debug
    if (config.debugMode) {
      print('🚀 KINA ${isSuperKina ? 'SUPER' : 'NORMAL'} ATIVADO!');
      print('   Borda: $edgeType');
      print('   Distância: ${edgeDistance.toStringAsFixed(2)}px');
      print('   Precisão: ${(precisionFactor * 100).toStringAsFixed(1)}%');
      print('   Velocidade: ${playerVelocity.y.toStringAsFixed(1)}');
      print('   Boost X: ${finalBoostX.toStringAsFixed(1)}');
      print('   Boost Y: ${boostY.toStringAsFixed(1)}');
    }

    return KinaResult(
      triggered: true,
      isSuperKina: isSuperKina,
      boostX: finalBoostX,
      boostY: boostY,
      precisionFactor: precisionFactor,
      edgeType: edgeType,
    );
  }

  /// Reseta o cooldown (útil para testes ou eventos especiais)
  static void resetCooldown() {
    _lastKinaTime = 0.0;
  }

  /// Reseta o tempo (útil ao trocar de nível)
  static void resetTime() {
    _currentTime = 0.0;
    _lastKinaTime = 0.0;
  }
}
