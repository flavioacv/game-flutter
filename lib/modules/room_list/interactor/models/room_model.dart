class RoomModel {
  final String id;
  final String name;
  final String hostId;
  final int maxPlayers;
  final int currentPlayers;
  final DateTime createdAt;
  final RoomStatus status;

  RoomModel({
    required this.id,
    required this.name,
    required this.hostId,
    required this.maxPlayers,
    required this.currentPlayers,
    required this.createdAt,
    required this.status,
  });

  factory RoomModel.fromMap(String id, Map<dynamic, dynamic> map) {
    final info = map['info'] as Map<dynamic, dynamic>?;
    return RoomModel(
      id: id,
      name: info?['name'] as String? ?? 'Sala sem nome',
      hostId: info?['host'] as String? ?? '',
      maxPlayers: info?['maxPlayers'] as int? ?? 4,
      currentPlayers: info?['currentPlayers'] as int? ?? 0,
      createdAt:
          DateTime.fromMillisecondsSinceEpoch(info?['createdAt'] as int? ?? 0),
      status: _parseStatus(info?['status'] as String?),
    );
  }

  static RoomStatus _parseStatus(String? status) {
    switch (status) {
      case 'waiting':
        return RoomStatus.waiting;
      case 'playing':
        return RoomStatus.playing;
      case 'finished':
        return RoomStatus.finished;
      default:
        return RoomStatus.waiting;
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'host': hostId,
      'maxPlayers': maxPlayers,
      'currentPlayers': currentPlayers,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'status': status.name,
    };
  }

  RoomModel copyWith({
    String? id,
    String? name,
    String? hostId,
    int? maxPlayers,
    int? currentPlayers,
    DateTime? createdAt,
    RoomStatus? status,
  }) {
    return RoomModel(
      id: id ?? this.id,
      name: name ?? this.name,
      hostId: hostId ?? this.hostId,
      maxPlayers: maxPlayers ?? this.maxPlayers,
      currentPlayers: currentPlayers ?? this.currentPlayers,
      createdAt: createdAt ?? this.createdAt,
      status: status ?? this.status,
    );
  }

  bool get isFull => currentPlayers >= maxPlayers;
  bool get canJoin => !isFull && status == RoomStatus.waiting;
}

enum RoomStatus {
  waiting,
  playing,
  finished,
}
