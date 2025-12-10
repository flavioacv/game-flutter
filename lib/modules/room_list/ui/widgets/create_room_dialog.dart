import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CreateRoomDialog extends StatefulWidget {
  final Function(String roomName, int maxPlayers) onCreateRoom;

  const CreateRoomDialog({
    super.key,
    required this.onCreateRoom,
  });

  @override
  State<CreateRoomDialog> createState() => _CreateRoomDialogState();
}

class _CreateRoomDialogState extends State<CreateRoomDialog> {
  final TextEditingController _roomNameController = TextEditingController();
  int _selectedMaxPlayers = 4;
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _roomNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFF211F30),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: const BorderSide(color: Colors.white, width: 3),
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        constraints: const BoxConstraints(maxHeight: 500),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Title
                Stack(
                  children: [
                    Text(
                      'CRIAR SALA',
                      style: GoogleFonts.lilitaOne(
                        fontSize: 28,
                        foreground: Paint()
                          ..style = PaintingStyle.stroke
                          ..strokeWidth = 3
                          ..color = Colors.black,
                      ),
                    ),
                    Text(
                      'CRIAR SALA',
                      style: GoogleFonts.lilitaOne(
                        fontSize: 28,
                        color: const Color(0xFFEEC643),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Room Name Input
                TextFormField(
                  controller: _roomNameController,
                  maxLength: 20,
                  style: GoogleFonts.lilitaOne(
                    fontSize: 16,
                    color: Colors.white,
                  ),
                  decoration: InputDecoration(
                    labelText: 'Nome da Sala',
                    labelStyle: GoogleFonts.lilitaOne(
                      color: Colors.white70,
                    ),
                    filled: true,
                    fillColor: const Color(0xFF39283A),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide:
                          const BorderSide(color: Colors.white, width: 2),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide:
                          const BorderSide(color: Colors.white, width: 2),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide:
                          const BorderSide(color: Color(0xFFEEC643), width: 2),
                    ),
                    counterStyle: GoogleFonts.lilitaOne(color: Colors.white70),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Digite um nome para a sala';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Max Players Selector
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Número de Jogadores',
                      style: GoogleFonts.lilitaOne(
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [2, 3, 4].map((number) {
                        final isSelected = _selectedMaxPlayers == number;
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedMaxPlayers = number;
                            });
                          },
                          child: Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? const Color(0xFFEEC643)
                                  : const Color(0xFF39283A),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: Colors.white,
                                width: isSelected ? 3 : 2,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                '$number',
                                style: GoogleFonts.lilitaOne(
                                  fontSize: 24,
                                  color:
                                      isSelected ? Colors.black : Colors.white,
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
                const SizedBox(height: 30),

                // Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Cancel Button
                    _buildButton(
                      'CANCELAR',
                      const Color(0xFFA6552D),
                      () => Navigator.of(context).pop(),
                    ),

                    // Create Button
                    _buildButton(
                      'CRIAR',
                      const Color(0xFFEEC643),
                      () {
                        if (_formKey.currentState!.validate()) {
                          widget.onCreateRoom(
                            _roomNameController.text.trim(),
                            _selectedMaxPlayers,
                          );
                          Navigator.of(context).pop();
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildButton(String text, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Transform(
        transform: Matrix4.skewX(-0.1),
        child: Container(
          width: 120,
          height: 50,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.black, width: 3),
          ),
          child: Stack(
            children: [
              // Shadow
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                height: 4,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.3),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(5),
                      bottomRight: Radius.circular(5),
                    ),
                  ),
                ),
              ),
              // Text
              Center(
                child: Stack(
                  children: [
                    Text(
                      text,
                      style: GoogleFonts.lilitaOne(
                        fontSize: 18,
                        foreground: Paint()
                          ..style = PaintingStyle.stroke
                          ..strokeWidth = 2
                          ..color = Colors.black,
                      ),
                    ),
                    Text(
                      text,
                      style: GoogleFonts.lilitaOne(
                        fontSize: 18,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
