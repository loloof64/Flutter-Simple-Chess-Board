import 'package:flutter/material.dart';
import 'package:fpdart/fpdart.dart';
import 'package:provider/provider.dart';
import '../models/board.dart';
import '../models/half_move.dart';
import '../models/short_move.dart';
import '../models/square.dart';
import '../widgets/ui_piece.dart';
import '../widgets/ui_tile.dart';

class UISquare extends StatelessWidget {
  final Square square;
  final void Function(ShortMove move) onDrop;
  final void Function(HalfMove move) onClick;
  final Color? highlight;

  const UISquare({
    Key? key,
    required this.square,
    required this.onClick,
    required this.onDrop,
    this.highlight,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: square.x,
      top: square.y,
      width: square.size,
      height: square.size,
      child: _buildSquare(context),
    );
  }

  Widget _buildSquare(BuildContext context) {
    final board = Provider.of<Board>(context);
    return DragTarget<HalfMove>(
      onWillAccept: (data) {
        return data?.square != square.name;
      },
      onAccept: (data) {
        onDrop(ShortMove(
          from: data.square,
          to: square.name,
        ));
      },
      builder: (context, candidateData, rejectedData) {
        return InkWell(
          onTap: () => onClick(HalfMove(square.name, square.piece)),
          child: Stack(
            children: [
              UITile(
                color: square.color,
                size: square.size,
              ),
              if (highlight != null)
                Container(
                  color: highlight,
                  height: square.size,
                  width: square.size,
                ),
              board.buildCustomPiece
                  .flatMap((t) => Option.fromNullable(t(square)))
                  .alt(() => square.piece.map((t) => UIPiece(
                        squareName: square.name,
                        squareColor: square.color,
                        piece: t,
                        size: square.size,
                      )))
                  .getOrElse(() => const SizedBox())
            ],
          ),
        );
      },
    );
  }
}
