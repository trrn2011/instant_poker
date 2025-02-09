import 'package:flutter/material.dart';
import '../models/player.dart';
import '../models/card.dart' as poker;

class PlayerHandWidget extends StatelessWidget {
  final Player player;
  final bool isCurrentPlayer;
  final bool isFaceDown;

  const PlayerHandWidget({
    required this.player,
    required this.isCurrentPlayer,
    required this.isFaceDown,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        border: isCurrentPlayer
            ? Border.all(color: Colors.yellow, width: 2.0)
            : null,
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Column(
        children: [
          Text(
            player.name,
            style: TextStyle(color: Colors.white),
          ),
          Text(
            '${player.chips}チップ',
            style: TextStyle(color: Colors.white),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: player.hand.map((card) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: _buildCard(card),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildCard(poker.Card card) {
    if (isFaceDown) {
      return Container(
        width: 50,
        height: 70,
        decoration: BoxDecoration(
          color: Colors.blue,
          borderRadius: BorderRadius.circular(4.0),
          border: Border.all(color: Colors.white),
        ),
      );
    }

    Color cardColor =
        card.suit == '♥' || card.suit == '♦' ? Colors.red : Colors.black;

    return Container(
      width: 50,
      height: 70,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4.0),
        border: Border.all(color: Colors.black),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            card.suit,
            style: TextStyle(color: cardColor, fontSize: 20),
          ),
          Text(
            card.toString().replaceAll(card.suit, ''),
            style: TextStyle(color: cardColor, fontSize: 16),
          ),
        ],
      ),
    );
  }
}
