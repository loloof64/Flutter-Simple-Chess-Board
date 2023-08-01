/// A side of the board (white/black).
enum BoardColor {
  white,
  black;

  String get name {
    return switch (this) {
      BoardColor.white => "w",
      BoardColor.black => "b",
    };
  }
}
