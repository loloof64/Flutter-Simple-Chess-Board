// Inspired by https://github.com/deven98/flutter_chess_board/blob/97fe52c9a0c706b455b2162df55b050eb92ff70e/lib/src/board_arrow.dart

/// An arrow for the last move done on board.
class BoardArrow {
  /// From square (e.g 'd2').
  final String from;

  /// To square (e.g 'd4').
  final String to;

  /// Constructor.
  /// from : from square (e.g 'd2').
  /// to : to square (e.g 'd4').
  /// color: color of the arrow from flutter material package (e.g Colors.green).
  BoardArrow({
    required this.from,
    required this.to,
  });

  /// Equality operator.
  @override
  bool operator ==(Object other) {
    return other is BoardArrow && from == other.from && to == other.to;
  }

  /// Hash code.
  @override
  int get hashCode => from.hashCode * to.hashCode;
}
