import 'package:flutter/material.dart';
import 'package:fpdart/fpdart.dart';
import 'package:provider/provider.dart';
import '../models/board.dart';
import '../models/board_color.dart';

class UITile extends StatelessWidget {
  final BoardColor color;
  final double size;

  const UITile({
    Key? key,
    required this.color,
    required this.size,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final board = Provider.of<Board>(context);

    return board.buildSquare
        .flatMap((t) => Option.fromNullable(t(color, size)))
        .getOrElse(() => Container(
              color: color == BoardColor.white
                  ? board.lightSquareColor
                  : board.darkSquareColor,
              height: size,
              width: size,
            ));
  }
}
