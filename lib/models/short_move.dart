import 'package:fpdart/fpdart.dart';

import 'piece_type.dart';

class ShortMove {
  final String from;
  final String to;
  final Option<PieceType> promotion;

  ShortMove({
    required this.from,
    required this.to,
    this.promotion = const None(),
  });
}
