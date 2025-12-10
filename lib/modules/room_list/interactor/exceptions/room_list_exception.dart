class RoomListException implements Exception {
  final String message;

  RoomListException(this.message);

  @override
  String toString() => message;
}
