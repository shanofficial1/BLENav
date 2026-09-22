import 'room.dart';

class Corridor {
  final String id;

  final String name;

  final double length;

  final List<Room> rooms;

  const Corridor({
    required this.id,
    required this.name,
    required this.length,
    required this.rooms,
  });
}