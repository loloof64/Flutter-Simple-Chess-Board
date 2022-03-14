/// A side of the board (white/black).
class BoardColor {
  /// Value: 0 for white, 1 for black.
  final int value;

  /// Constructor
  const BoardColor._value(this.value);

  /// White side
  static const BoardColor white = BoardColor._value(0);

  /// Black side
  static const BoardColor black = BoardColor._value(1);

  /// Hash code
  @override
  int get hashCode => value.hashCode;

  /// String representation
  @override
  String toString() => (this == white) ? 'w' : 'b';

  /// Equality operator
  @override
  bool operator ==(Object other) {
    return other.runtimeType == runtimeType && hashCode == other.hashCode;
  }
}
