class PieceType {
  final String name;

  const PieceType._value(this.name);

  static const PieceType pawn = PieceType._value('p');
  static const PieceType knight = PieceType._value('n');
  static const PieceType bishop = PieceType._value('b');
  static const PieceType rook = PieceType._value('r');
  static const PieceType queen = PieceType._value('q');
  static const PieceType king = PieceType._value('k');

  factory PieceType.fromString(String value) {
    switch (value.toLowerCase()) {
      case 'p':
        return PieceType.pawn;
      case 'n':
        return PieceType.knight;
      case 'b':
        return PieceType.bishop;
      case 'r':
        return PieceType.rook;
      case 'q':
        return PieceType.queen;
      case 'k':
        return PieceType.king;
      default:
        throw "Unknown piece type";
    }
  }

  @override
  int get hashCode => name.hashCode;

  @override
  String toString() => name;

  String toLowerCase() => name;

  String toUpperCase() => name.toUpperCase();

  @override
  bool operator ==(Object other) {
    return other.runtimeType == runtimeType && hashCode == other.hashCode;
  }
}
