enum PieceType {
  pawn,
  knight,
  bishop,
  rook,
  queen,
  king;

  get name {
    return switch (this) {
      PieceType.pawn => 'p',
      PieceType.knight => 'n',
      PieceType.bishop => 'b',
      PieceType.rook => 'r',
      PieceType.queen => 'q',
      PieceType.king => 'k',
    };
  }

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
}
