import 'piece_type.dart';

class ShortMove {
  final String from;
  final String to;
  PieceType? promotion;

  ShortMove({
    required this.from,
    required this.to,
    this.promotion,
  });
}
