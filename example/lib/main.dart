import 'package:flutter/material.dart';
import 'package:simple_chess_board_usage/chess_board_with_history.dart';
import 'package:simple_chess_board_usage/variants/custom_move_indicator.dart';
import 'package:simple_chess_board_usage/variants/handling_promotions.dart';
import 'package:simple_chess_board_usage/variants/interactive.dart';
import 'package:simple_chess_board_usage/variants/simple.dart';
import 'package:simple_chess_board_usage/variants/with_sounds.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Simple chess board Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({
    super.key,
  });

  Future<void> _goToSimpleBoard(BuildContext context) async {
    await Navigator.of(context).push(MaterialPageRoute(builder: (context) {
      return SimpleBoardVariant();
    }));
  }

  Future<void> _goToInteractiveBoard(BuildContext context) async {
    await Navigator.of(context).push(MaterialPageRoute(builder: (context) {
      return InteractiveBoard();
    }));
  }

  Future<void> _goToCustomIndicatorsBoard(BuildContext context) async {
    await Navigator.of(context).push(MaterialPageRoute(builder: (context) {
      return CustomMoveIndicator();
    }));
  }

  Future<void> _goToPromotionHandling(BuildContext context) async {
    await Navigator.of(context).push(MaterialPageRoute(builder: (context) {
      return HandlingPromotionsBoard();
    }));
  }

  Future<void> _goToHistoryExample(BuildContext context) async {
    await Navigator.of(context).push(MaterialPageRoute(builder: (context) {
      return ChessBoardWithHistory();
    }));
  }

  Future<void> _goToSoundExample(BuildContext context) async {
    await Navigator.of(context).push(MaterialPageRoute(builder: (context) {
      return BoardWithSound();
    }));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Simple chess board demo"),
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          spacing: 10,
          children: [
            ElevatedButton(
              onPressed: () => _goToSimpleBoard(context),
              child: Text("See simple board"),
            ),
            ElevatedButton(
              onPressed: () => _goToInteractiveBoard(context),
              child: Text("See interactive board"),
            ),
            ElevatedButton(
              onPressed: () => _goToCustomIndicatorsBoard(context),
              child: Text("See custom indicators board"),
            ),
            ElevatedButton(
              onPressed: () => _goToPromotionHandling(context),
              child: Text("See nicer promotion handling"),
            ),
            ElevatedButton(
              onPressed: () => _goToHistoryExample(context),
              child: Text("See history example"),
            ),
            ElevatedButton(
              onPressed: () => _goToSoundExample(context),
              child: Text("See sound example"),
            ),
          ],
        ),
      ),
    );
  }
}
