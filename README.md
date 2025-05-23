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
* you can configure the current position,
* you can configure each side type (e.g : we can drag pieces for white side, but block them for black side if we want to make an external engine move),
* you can show coordinates and player turn around the board,
* you define your own widget for processing with promotion piece selection,
* you can choose the orientation of the board (are Blacks at bottom ?),
* you can add arrows,
* you can choose colors,
* the common size will be the least of attributed width/height : if width > height => takes the allocated height, and the reverse if width < height (so for example, if you use it in a Row/Column, you can set the stretch alignment in the cross axis direction for a quite good layout/effect),
* you can highlights some square, from the color you want.

If you want to implement game logic, you can use the [chess](https://pub.dev/packages/chess) package.

Please, also notice, that when there is a pending promotion, you should prevent the user to reverse the board orientation. Otherwise the result can be quite ugly. This can easily be done by showing a modal over your interface when the user is invited to choose a promotion piece.

## Getting started

To use SimpleChessBoard widget, add [simple_chess_board](https://pub.dev/packages/simple_chess_board/install) as a dependency in your pubspec.yaml .

## Usage

You can find a longer example in the `example` folder.

### Simple example

```dart
SimpleChessBoard(
    engineThinking: false,
    fen: '8/8/8/4p1K1/2k1P3/8/8/8 b - - 0 1',
    onMove: ({required ShortMove move}){
        print('${move.from}|${move.to}|${move.promotion}')
    },
    orientation: BoardColor.black,
    whitePlayerType: PlayerType.human,
    blackPlayerType: PlayerType.computer,
    lastMoveToHighlight: BoardArrow(from: 'e2', to: 'e4', color: Colors.blueAccent),
    onPromote: () => PieceType.queen,
),
```

### Handling promotion

You handle promotion in the function you give to the mandatory `onPromote` parameter. In this function you return the `PieceType` you want to use.
You can also be notified if the promotion has been set, by using `onPromotionCommited` function.

As an example:

```dart
SimpleChessBoard(
    engineThinking: false,
    fen: '1k6/p2KP3/1p6/8/4B3/8/8/8 w - - 0 1',
    onMove: ({required ShortMove move}){
        print('${move.from}|${move.to}|${move.promotion}')
    },
    orientation: BoardColor.white,
    whitePlayerType: PlayerType.human,
    blackPlayerType: PlayerType.computer,
    lastMoveToHighlight: BoardArrow(from: 'e2', to: 'e4', color: Colors.blueAccent),
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
                                onTap: () => navigator.pop(PieceType.queen),
                            ),
                            ListTile(
                                title: Text("Rook"),
                                onTap: () => navigator.pop(PieceType.rook),
                            ),
                            ListTile(
                                title: Text("Bishop"),
                                onTap: () => navigator.pop(PieceType.bishop),
                            ),
                            ListTile(
                                title: Text("Knight"),
                                onTap: () => navigator.pop(PieceType.knight),
                            ),
                        ],
                    ),
                );
            },
        );
    },
)
```

### Parameters

* fen : board position in [Forsyth-Edwards Notation](https://en.wikipedia.org/wiki/Forsyth%E2%80%93Edwards_Notation). Example : `rnbqkbnr/pppppppp/8/8/4P3/8/PPPP1PPP/RNBQKBNR b KQkq e3 0 1`.
* orientation: says if Black side is at bottom or not. Give `BoardColor.black` if Blacks must be at bottom of the board, or `BoardColor.white` otherwise.
* whitePlayerType : if it is white turn and this is set to `PlayerType.human`, then the user will be able to move pieces. Either with the click method, or with the drag and drop method. Otherwise, if set to `PlayerType.computer` and it is white turn, then the user won't be able to move pieces.
* blackPlayerType : if it is black turn and this is set to `PlayerType.human`, then the user will be able to move pieces. Either with the click method, or with the drag and drop method. Otherwise, if set to `PlayerType.computer` and it is black turn, then the user won't be able to move pieces.
* onMove : the given function will be called whenever a move is done on board by the user (if he's allowed to move pieces). It has a single `required` parameter `ShortMove move` which carries data about from/to cells, as well as promotion type which is nullable. **Notice that it's up to you to update the board or not based on the move you receive from this function.** You can use the [chess](https://pub.dev/packages/chess) package to get the new position.
* onPromote: the given function is called whenever a promotion move is done on board by the user (if he's allowed to move pieces). You must return a `Future<PieceType?>`. The `Future` can wrap a `null` value in order to cancel. Otherwise, wrap a `PieceType` such as `PieceType.queen`.
* showCoordinatesZone (optionnal) : says if you want to show coordinates and player turn around the board. Give `true` for showing it, or `false` for removing it.
* lastMoveToHighlight (optionnal) : give data about the arrow to draw on the board, if any. You pass a `BoardArrow` with from/to cells `String` and color `Color` (such as `BoardArrow(from: 'e2', to: 'e4', color: Colors.blueAccent)`) if you want to draw an arrow, or `null` if you don't want any arrow on the board.
* engineThinking (optionnal) : says if you want to show a `CircularProgressBar` in order to indicate that an engine is trying to compute next move for example.

## Project's repository

You can find the repository on [Github](https://github.com/loloof64/Flutter-Simple-Chess-Board).

## Credits

* Using code from [Flutter Chess board](https://github.com/varunpvp/flutter_chessboard).
* Using code from [Flutter Stateless Chess board](https://github.com/varunpvp/flutter_chessboard).
* Using chess pieces definitions from [Wikimedia Commons](https://commons.wikimedia.org/wiki/Category:SVG_chess_pieces).