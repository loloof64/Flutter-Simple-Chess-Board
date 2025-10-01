<!--
This README describes the package. If you publish this package to pub.dev,
this README's contents appear on the landing page for your package.

For information about how to write a good package README, see the guide for
[writing package pages](https://dart.dev/guides/libraries/writing-package-pages).

For general information about developing packages, see the Dart guide for
[creating packages](https://dart.dev/guides/libraries/create-library-packages)
and the Flutter guide for
[developing packages and plugins](https://flutter.dev/developing-packages).
-->

A simple chess board widget, with several options.

## Features

![Example usage](https://github.com/loloof64/Flutter-Simple-Chess-Board/blob/main/simple_chess_board.png#400)

A simple chess board, where:

- you can configure the current position,
- you can configure each side type (e.g : we can drag pieces for white side, but block them for black side if we want to make an external engine move),
- you can show coordinates and player turn around the board,
- you define your own widget for processing with promotion piece selection,
- you can choose the orientation of the board (are Blacks at bottom ?),
- you can add arrows,
- you can choose colors,
- the common size will be the least of attributed width/height : if width > height => takes the allocated height, and the reverse if width < height (so for example, if you use it in a Row/Column, you can set the stretch alignment in the cross axis direction for a quite good layout/effect),
- you can highlights some square, from the color you want,
- you can enable interactive tap-to-move functionality with visual move indicators,
- you can customize move indicator widgets for both normal moves and capture moves,
- you can enable sound effects when moves are made (for both human and computer moves),
- you can track captured pieces for both players and get them as callbacks.

If you want to implement game logic, you can use the [chess](https://pub.dev/packages/chess) package.

Please, also notice, that when there is a pending promotion, you should prevent the user to reverse the board orientation. Otherwise the result can be quite ugly. This can easily be done by showing a modal over your interface when the user is invited to choose a promotion piece.

Last but not least : there's no implementation of cpu thinking, but you can grab a package for that. For example [Stockfish Chess Engine](https://pub.dev/packages/stockfish_chess_engine).

## Getting started

To use SimpleChessBoard widget, add [simple_chess_board](https://pub.dev/packages/simple_chess_board/install) as a dependency in your pubspec.yaml .

## Usage

You can find a longer example in the `example` folder.

### Simple example

```dart
SimpleChessBoard(
    engineThinking: false,
    fen: '8/8/8/4p1K1/2k1P3/8/8/8 b - - 0 1',
    onMove: ({required ShortMove move}) {
    debugPrint('${move.from}|${move.to}|${move.promotion}');
    },
    blackSideAtBottom: false,
    whitePlayerType: PlayerType.human,
    blackPlayerType: PlayerType.computer,
    lastMoveToHighlight: BoardArrow(from: 'e2', to: 'e4'),
    onPromote: () async => PieceType.queen,
    onPromotionCommited: ({required moveDone, required pieceType}) => {},
    onTap: ({required cellCoordinate}) {},
    cellHighlights: <String, Color>{},
    chessBoardColors: ChessBoardColors()
    ..lastMoveArrowColor = Colors.redAccent,
    showPossibleMoves: false,
    playSounds: true, // Enable sound effects for all moves
    onCapturedPiecesChanged: ({
        required whiteCapturedPieces,
        required blackCapturedPieces,
    }) {
        // Track captured pieces - whiteCapturedPieces contains pieces captured by white
        debugPrint('White captured: $whiteCapturedPieces');
        debugPrint('Black captured: $blackCapturedPieces');
    },
)
```

### Customizing colors

```dart
SimpleChessBoard(
    chessBoardColors: ChessBoardColors()
        ..lightSquaresColor = Colors.blue.shade200
        ..darkSquaresColor = Colors.blue.shade600
        ..coordinatesZoneColor = Colors.redAccent.shade200
        ..lastMoveArrowColor = Colors.cyan
        ..startSquareColor = Colors.orange
        ..endSquareColor = Colors.green
        ..circularProgressBarColor = Colors.red
        ..coordinatesColor = Colors.green,
    engineThinking: false,
    fen: _chess.fen,
    onMove: tryMakingMove,
    blackSideAtBottom: _blackAtBottom,
    whitePlayerType: PlayerType.human,
    blackPlayerType: PlayerType.human,
    lastMoveToHighlight: _lastMoveArrowCoordinates,
    cellHighlights: _highlightCells,
    onPromote: () => handlePromotion(context),
    onPromotionCommited: ({
        required ShortMove moveDone,
        required PieceType pieceType,
    }) {
        moveDone.promotion = pieceType;
        tryMakingMove(move: moveDone);
    },
    onTap: ({required String cellCoordinate}) {
        if (_highlightCells[cellCoordinate] == null) {
        _highlightCells[cellCoordinate] = Colors.red.withAlpha(70);
        setState(() {});
        } else {
        _highlightCells.remove(cellCoordinate);
        setState(() {});
        }
    },
)
```

### Customizing move indicators

```dart
SimpleChessBoard(
    engineThinking: false,
    fen: _chess.fen,
    onMove: tryMakingMove,
    blackSideAtBottom: _blackAtBottom,
    whitePlayerType: PlayerType.human,
    blackPlayerType: PlayerType.human,
    showPossibleMoves: true,
    // Custom widget for normal moves (empty squares)
    normalMoveIndicatorBuilder: (cellSize) => SizedBox(
        width: cellSize,
        height: cellSize,
        child: Center(
            child: Container(
                width: cellSize * 0.3,
                height: cellSize * 0.3,
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.blue.withValues(alpha: 0.7),
                ),
            ),
        ),
    ),
    // Custom widget for capture moves (squares with opponent pieces)
    captureMoveIndicatorBuilder: (cellSize) => Container(
        width: cellSize,
        height: cellSize,
        decoration: BoxDecoration(
            border: Border.all(
                color: Colors.red,
                width: cellSize * 0.05,
            ),
        ),
        child: Icon(
            Icons.close,
            color: Colors.red,
            size: cellSize * 0.5,
        ),
    ),
    onPromote: () => handlePromotion(context),
    // ... other required parameters
),
```

### Move history and navigation

```dart
class ChessBoardWithHistory extends StatefulWidget {
  @override
  State<ChessBoardWithHistory> createState() => _ChessBoardWithHistoryState();
}

class _ChessBoardWithHistoryState extends State<ChessBoardWithHistory> {
  late chess.Chess _chess;
  late MoveHistory _moveHistory;
  String? _customFen;

  @override
  void initState() {
    super.initState();
    _chess = chess.Chess();
    _moveHistory = MoveHistory(); // Optional: MoveHistory(initialFen: customFen)
  }

  void _onMove(ShortMove move) {
    // Make move and add to history
    final success = _chess.move({'from': move.from, 'to': move.to});
    if (success) {
      _moveHistory.addMove(
        move: '${move.from}${move.to}',
        fen: _chess.fen,
      );
      setState(() => _customFen = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SimpleChessBoard(
          fen: _customFen ?? _chess.fen,
          onMove: ({required move}) => _onMove(move),
          // Board is only interactive when at current position
          isInteractive: _customFen == null,
          // Customize non-interactive overlay
          nonInteractiveText: 'ANALYZING POSITION',
          nonInteractiveTextStyle: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
          nonInteractiveOverlayColor: Colors.deepPurple,
          // ... other required parameters
        ),
        
        // Navigation controls
        MoveNavigationControls(
          moveHistory: _moveHistory,
          onGoBack: () => setState(() => _customFen = _moveHistory.goBack()),
          onGoForward: () {
            final fen = _moveHistory.goForward();
            if (fen != null) setState(() => _customFen = fen);
          },
          onGoToStart: () => setState(() {
            _customFen = _moveHistory.initialFen;
            _moveHistory.goToIndex(-1);
          }),
          onGoToEnd: () => setState(() {
            _customFen = null;
            _moveHistory.goToIndex(_moveHistory.length - 1);
          }),
        ),
      ],
    );
  }
}
```

### Tracking captured pieces

You can track captured pieces by providing an `onCapturedPiecesChanged` callback. This callback is invoked whenever the board position changes, providing lists of captured pieces for both players:

```dart
class MyChessBoard extends StatefulWidget {
  @override
  State<MyChessBoard> createState() => _MyChessBoardState();
}

class _MyChessBoardState extends State<MyChessBoard> {
  String fen = chess.Chess.DEFAULT_POSITION;
  List<PieceType> whiteCapturedPieces = [];
  List<PieceType> blackCapturedPieces = [];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Display white's captured pieces (black pieces)
        Text('White captured: ${whiteCapturedPieces.length} pieces'),
        
        SimpleChessBoard(
          fen: fen,
          whitePlayerType: PlayerType.human,
          blackPlayerType: PlayerType.human,
          onMove: ({required move}) {
            // Handle move
          },
          onCapturedPiecesChanged: ({
            required whiteCapturedPieces,
            required blackCapturedPieces,
          }) {
            setState(() {
              this.whiteCapturedPieces = whiteCapturedPieces;
              this.blackCapturedPieces = blackCapturedPieces;
            });
          },
          // ... other required parameters
        ),
        
        // Display black's captured pieces (white pieces)
        Text('Black captured: ${blackCapturedPieces.length} pieces'),
      ],
    );
  }
}
```

The captured pieces are returned as lists of `PieceType` enum values, where:
- `whiteCapturedPieces`: Black pieces that have been captured by white
- `blackCapturedPieces`: White pieces that have been captured by black

Each `PieceType` can be: `pawn`, `knight`, `bishop`, `rook`, `queen`, or `king`.

For a complete example with UI rendering of captured pieces, see `example/lib/variants/captured_pieces_example.dart`.

### Handling promotion

You handle promotion in the function you give to the mandatory `onPromote` parameter. In this function you return the `PieceType` you want to use.
You can also be notified if the promotion has been set, by using `onPromotionCommited` function.

As an example:

```dart
SimpleChessBoard(
    engineThinking: false,
    fen: '1k6/p2KP3/1p6/8/4B3/8/8/8 w - - 0 1',
    onMove: ({required ShortMove move}) {
        debugPrint('${move.from}|${move.to}|${move.promotion}');
    },
    blackSideAtBottom: false,
    whitePlayerType: PlayerType.human,
    blackPlayerType: PlayerType.computer,
    lastMoveToHighlight: null,
    onPromote: () {
        return showDialog<PieceType>(
        context: context,
        builder: (_) {
            return AlertDialog(
            title: Text('Promotion'),
            content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                ListTile(
                    title: Text("Queen"),
                    onTap: () =>
                        Navigator.of(context).pop(PieceType.queen),
                ),
                ListTile(
                    title: Text("Rook"),
                    onTap: () =>
                        Navigator.of(context).pop(PieceType.rook),
                ),
                ListTile(
                    title: Text("Bishop"),
                    onTap: () =>
                        Navigator.of(context).pop(PieceType.bishop),
                ),
                ListTile(
                    title: Text("Knight"),
                    onTap: () =>
                        Navigator.of(context).pop(PieceType.knight),
                ),
                ],
            ),
            );
        },
        );
    },
    onPromotionCommited: ({required moveDone, required pieceType}) {
        // update the board logic with the given pieceType and moveData inside moveDone.
    },
    // Other parameters ...
)
```

### Parameters

- fen : board position in [Forsyth-Edwards Notation](https://en.wikipedia.org/wiki/Forsyth%E2%80%93Edwards_Notation). Example : `rnbqkbnr/pppppppp/8/8/4P3/8/PPPP1PPP/RNBQKBNR b KQkq e3 0 1`.
- orientation: says if Black side is at bottom or not. Give `BoardColor.black` if Blacks must be at bottom of the board, or `BoardColor.white` otherwise.
- whitePlayerType : if it is white turn and this is set to `PlayerType.human`, then the user will be able to move pieces. Either with the click method, or with the drag and drop method. Otherwise, if set to `PlayerType.computer` and it is white turn, then the user won't be able to move pieces.
- blackPlayerType : if it is black turn and this is set to `PlayerType.human`, then the user will be able to move pieces. Either with the click method, or with the drag and drop method. Otherwise, if set to `PlayerType.computer` and it is black turn, then the user won't be able to move pieces.
- onMove : the given function will be called whenever a move is done on board by the user (if he's allowed to move pieces). It has a single `required` parameter `ShortMove move` which carries data about from/to cells, as well as promotion type which is nullable. **Notice that it's up to you to update the board or not based on the move you receive from this function.** You can use the [chess](https://pub.dev/packages/chess) package to get the new position.
- onPromote: the given function is called whenever a promotion move is done on board by the user (if he's allowed to move pieces). You must return a `Future<PieceType?>`. The `Future` can wrap a `null` value in order to cancel. Otherwise, wrap a `PieceType` such as `PieceType.queen`.
- onPromotionCommited : you should update the board logic here, as you get data about the move made and the selected promotion. The simplest way is to first change the promotion type of the given move data, and then try to update the board logic. (See example application code.)
- showCoordinatesZone (optionnal) : says if you want to show coordinates and player turn around the board. Give `true` for showing it, or `false` for removing it.
- lastMoveToHighlight (optionnal) : give data about the arrow to draw on the board, if any. You pass a `BoardArrow` with from/to cells `String` (such as `BoardArrow(from: 'e2', to: 'e4')`) if you want to draw an arrow, or `null` if you don't want any arrow on the board. Given that colors can be customized in the `ChessBoardColors` instance you give to the board.
- showPossibleMoves (optional) : enable interactive tap-to-move functionality with visual move indicators. Set to `true` to show possible moves when a piece is selected.
- normalMoveIndicatorBuilder (optional) : custom widget builder for normal move indicators (moves to empty squares). Receives the cell size as parameter and should return a widget.
- captureMoveIndicatorBuilder (optional) : custom widget builder for capture move indicators (moves to squares with opponent pieces). Receives the cell size as parameter and should return a widget.
- isInteractive (optional) : whether the board allows user interaction. When `false`, displays a customizable overlay and prevents moves. Default: `true`.
- nonInteractiveText (optional) : text to display when board is not interactive. Default: `'VIEWING HISTORY'`.
- nonInteractiveTextStyle (optional) : text style for the non-interactive overlay text.
- nonInteractiveOverlayColor (optional) : color for the non-interactive overlay border and background. Default: `Colors.orange`.
- engineThinking (optionnal) : says if you want to show a `CircularProgressBar` in order to indicate that an engine is trying to compute next move for example.
- playSounds (optional) : whether to play sound effects when moves are made. When `true`, plays the castle.mp3 sound effect for each move (both human and computer moves). Default: `false`.
- onCapturedPiecesChanged (optional) : callback function that is triggered whenever the board position changes. Receives two parameters: `whiteCapturedPieces` (list of `PieceType` representing black pieces captured by white) and `blackCapturedPieces` (list of `PieceType` representing white pieces captured by black). Use this to track and display captured pieces in your UI.
- boardColors : you pass a `ChessBoardColors` in which colors can be customized. See example project code.

## Project's repository

You can find the repository on [Github](https://github.com/loloof64/Flutter-Simple-Chess-Board).

## Credits

- Using code from [Flutter Chess board](https://github.com/varunpvp/flutter_chessboard).
- Using code from [Flutter Stateless Chess board](https://github.com/varunpvp/flutter_chessboard).
- Using chess pieces definitions from [Wikimedia Commons](https://commons.wikimedia.org/wiki/Category:SVG_chess_pieces).


## Contributors

<p align="center">
  <a href="https://github.com/berkaycatak">
    <img src="https://avatars.githubusercontent.com/u/34205493?v=4" width="80" style="border-radius:50%; margin: 10px;" />
  </a>
</p>
