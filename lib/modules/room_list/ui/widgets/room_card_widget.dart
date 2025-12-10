import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pixel_adventure/modules/room_list/interactor/models/room_model.dart';

class RoomCardWidget extends StatelessWidget {
  final RoomModel room;
  final VoidCallback onJoin;

  const RoomCardWidget({
    super.key,
    required this.room,
    required this.onJoin,
  });

  @override
  Widget build(BuildContext context) {
    return Transform(
      transform: Matrix4.skewX(-0.05),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFFF38427),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.black, width: 3),
        ),
        child: Column(
          children: [
            // Room Info Section
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Room Name and Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Room Name
                        Stack(
                          children: [
                            Text(
                              room.name,
                              style: GoogleFonts.lilitaOne(
                                fontSize: 24,
                                foreground: Paint()
                                  ..style = PaintingStyle.stroke
                                  ..strokeWidth = 3
                                  ..color = Colors.black,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              room.name,
                              style: GoogleFonts.lilitaOne(
                                fontSize: 24,
                                color: Colors.white,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),

                        // Players Count
                        Row(
                          children: [
                            const Icon(
                              Icons.people,
                              color: Colors.white,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${room.currentPlayers}/${room.maxPlayers}',
                              style: GoogleFonts.lilitaOne(
                                fontSize: 18,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Status Badge
                  _buildStatusBadge(),
                ],
              ),
            ),

            // Join Button Section
            Container(
              decoration: const BoxDecoration(
                color: Color(0xff39283A),
                border: Border(
                  top: BorderSide(color: Colors.black, width: 2),
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(7),
                  bottomRight: Radius.circular(7),
                ),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: room.canJoin ? onJoin : null,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(7),
                    bottomRight: Radius.circular(7),
                  ),
                  child: Container(
                    height: 50,
                    alignment: Alignment.center,
                    child: Stack(
                      children: [
                        Text(
                          room.canJoin ? 'ENTRAR' : 'INDISPONÍVEL',
                          style: GoogleFonts.lilitaOne(
                            fontSize: 20,
                            foreground: Paint()
                              ..style = PaintingStyle.stroke
                              ..strokeWidth = 2
                              ..color = Colors.black,
                          ),
                        ),
                        Text(
                          room.canJoin ? 'ENTRAR' : 'INDISPONÍVEL',
                          style: GoogleFonts.lilitaOne(
                            fontSize: 20,
                            color: room.canJoin
                                ? const Color(0xFFEEC643)
                                : Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge() {
    Color badgeColor;
    String statusText;

    switch (room.status) {
      case RoomStatus.waiting:
        badgeColor = const Color(0xFF4CAF50);
        statusText = 'AGUARDANDO';
        break;
      case RoomStatus.playing:
        badgeColor = const Color(0xFFFF9800);
        statusText = 'JOGANDO';
        break;
      case RoomStatus.finished:
        badgeColor = const Color(0xFF9E9E9E);
        statusText = 'FINALIZADA';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: badgeColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black, width: 2),
      ),
      child: Text(
        statusText,
        style: GoogleFonts.lilitaOne(
          fontSize: 12,
          color: Colors.white,
        ),
      ),
    );
  }
}
