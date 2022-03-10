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

![Example screenshot](./simple_chess_board.jpg "Example usage")

A simple chess board, where:
* you can configure the current position,
* you can configure each side type (e.g : we can drag pieces for white side, but block them for black side if we want to make an external engine move),
* you can show coordinates and player turn around the board,
* you define your own widget for processing with promotion piece selection,
* you can choose the orientation of the board (are Blacks at bottom ?),
* you can add arrows.

If you want to implement game logic, you can use the [chess](https://pub.dev/packages/chess) package.

## Getting started

TODO: List prerequisites and provide or point to information on how to
start using the package.

## Usage

TODO: Include short and useful examples for package users. Add longer examples
to `/example` folder. 

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


## Additional information

TODO: Tell users more about the package: where to find more information, how to 
contribute to the package, how to file issues, what response they can expect 
from the package authors, and more.

## Credits

* Using code from [Flutter Chess board](https://github.com/varunpvp/flutter_chessboard).
* Using code from [Flutter Stateless Chess board](https://github.com/varunpvp/flutter_chessboard).