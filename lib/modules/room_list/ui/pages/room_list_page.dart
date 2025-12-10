import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pixel_adventure/core/constants/routes/app_routes.dart';
import 'package:pixel_adventure/core/navigation/navigation_service.dart';
import 'package:pixel_adventure/modules/room_list/interactor/controllers/room_list_controller.dart';
import 'package:pixel_adventure/modules/room_list/interactor/models/room_model.dart';
import 'package:pixel_adventure/modules/room_list/interactor/state/room_list_state.dart';
import 'package:pixel_adventure/modules/room_list/ui/widgets/create_room_dialog.dart';
import 'package:pixel_adventure/modules/room_list/ui/widgets/room_card_widget.dart';

class RoomListPage extends StatefulWidget {
  final String characterSelected;

  const RoomListPage({
    super.key,
    required this.characterSelected,
  });

  @override
  State<RoomListPage> createState() => _RoomListPageState();
}

class _RoomListPageState extends State<RoomListPage> {
  final RoomListController _controller = Modular.get<RoomListController>();

  @override
  void initState() {
    super.initState();
    _controller.loadRooms();

    // Listen to state changes
    _controller.state.listen((state) {
      if (!mounted) return;

      if (state is RoomListJoinedState || state is RoomListCreatedState) {
        final roomId = state is RoomListJoinedState
            ? state.roomId
            : (state as RoomListCreatedState).roomId;

        // Navigate to game
        NavigationService.pushNamed(
          context: context,
          route: AppRoutes.gamePageRoute,
          arguments: {
            'selected': widget.characterSelected,
            'roomId': roomId,
          },
        );
      } else if (state is RoomListErrorState) {
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              state.message,
              style: GoogleFonts.lilitaOne(),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF0447BB),
              Color(0xFF0471FF),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    // Back Button
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    const SizedBox(width: 10),
                    // Title
                    Expanded(
                      child: Stack(
                        children: [
                          Text(
                            'SALAS DISPONÍVEIS',
                            style: GoogleFonts.lilitaOne(
                              fontSize: 28,
                              foreground: Paint()
                                ..style = PaintingStyle.stroke
                                ..strokeWidth = 3
                                ..color = Colors.black,
                            ),
                          ),
                          Text(
                            'SALAS DISPONÍVEIS',
                            style: GoogleFonts.lilitaOne(
                              fontSize: 28,
                              color: const Color(0xFFEEC643),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Room List
              Expanded(
                child: StreamBuilder<RoomListState>(
                  stream: _controller.state,
                  builder: (context, snapshot) {
                    final state = snapshot.data;

                    if (state is RoomListLoadingState ||
                        state is RoomListInitialState) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFFEEC643),
                        ),
                      );
                    }

                    if (state is RoomListLoadedState) {
                      final rooms = state.rooms.cast<RoomModel>();

                      if (rooms.isEmpty) {
                        return _buildEmptyState();
                      }

                      return ListView.builder(
                        padding: const EdgeInsets.only(bottom: 80),
                        itemCount: rooms.length,
                        itemBuilder: (context, index) {
                          final room = rooms[index];
                          return RoomCardWidget(
                            room: room,
                            onJoin: () => _controller.joinRoom(
                              room.id,
                              widget.characterSelected,
                            ),
                          );
                        },
                      );
                    }

                    if (state is RoomListJoiningState ||
                        state is RoomListCreatingState) {
                      return const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(
                              color: Color(0xFFEEC643),
                            ),
                            SizedBox(height: 20),
                            Text(
                              'Conectando...',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    return _buildEmptyState();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showCreateRoomDialog,
        backgroundColor: const Color(0xFFEEC643),
        icon: const Icon(Icons.add, color: Colors.black),
        label: Text(
          'CRIAR SALA',
          style: GoogleFonts.lilitaOne(
            fontSize: 16,
            color: Colors.black,
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.meeting_room_outlined,
            size: 80,
            color: Colors.white54,
          ),
          const SizedBox(height: 16),
          Text(
            'Nenhuma sala disponível',
            style: GoogleFonts.lilitaOne(
              fontSize: 20,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Crie uma nova sala para começar!',
            style: GoogleFonts.lilitaOne(
              fontSize: 16,
              color: Colors.white54,
            ),
          ),
        ],
      ),
    );
  }

  void _showCreateRoomDialog() {
    showDialog(
      context: context,
      builder: (context) => CreateRoomDialog(
        onCreateRoom: (roomName, maxPlayers) {
          _controller.createRoom(roomName, maxPlayers);
        },
      ),
    );
  }
}
