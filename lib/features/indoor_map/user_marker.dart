import 'package:flutter/material.dart';

class UserMarker extends StatelessWidget {
  final Offset position;

  const UserMarker({
    super.key,
    required this.position,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: position.dx - 12,
      top: position.dy - 12,
      child: Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: Colors.blue,
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.white,
            width: 3,
          ),
          boxShadow: const [
            BoxShadow(
              blurRadius: 10,
              color: Colors.black26,
            )
          ],
        ),
      ),
    );
  }
}