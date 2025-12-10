sealed class RoomListState {}

class RoomListInitialState extends RoomListState {}

class RoomListLoadingState extends RoomListState {}

class RoomListLoadedState extends RoomListState {
  final List<dynamic> rooms; // Using dynamic to avoid circular dependency

  RoomListLoadedState(this.rooms);
}

class RoomListErrorState extends RoomListState {
  final String message;

  RoomListErrorState(this.message);
}

class RoomListJoiningState extends RoomListState {
  final String roomId;

  RoomListJoiningState(this.roomId);
}

class RoomListJoinedState extends RoomListState {
  final String roomId;

  RoomListJoinedState(this.roomId);
}

class RoomListCreatingState extends RoomListState {}

class RoomListCreatedState extends RoomListState {
  final String roomId;

  RoomListCreatedState(this.roomId);
}
