// Inspired by https://github.com/deven98/flutter_chess_board/blob/97fe52c9a0c706b455b2162df55b050eb92ff70e/lib/src/board_arrow.dart

import 'package:flutter/material.dart';

class BoardArrow {
  final String from;
  final String to;
  final Color color;

  BoardArrow({
    required this.from,
    required this.to,
    required this.color,
  });

  @override
  bool operator ==(Object other) {
    return other is BoardArrow && from == other.from && to == other.to;
  }

  @override
  int get hashCode => from.hashCode * to.hashCode;
}
