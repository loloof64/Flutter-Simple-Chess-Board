import 'piece.dart';

class HalfMove {
  final String square;
  final Piece? piece;

  HalfMove(this.square, this.piece);

  @override
  String toString() {
    return "$square::$piece";
  }
}
