import 'package:flutter/material.dart';
import '../models/card.dart' as poker;

class CommunityCardsWidget extends StatelessWidget {
  final List<poker.Card> communityCards;
  final int pot;

  const CommunityCardsWidget({
    required this.communityCards,
    required this.pot,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          'ポット: $potチップ',
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
        SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ...communityCards.map((card) => _buildCard(card)),
            // 残りのカード枠を表示
            ...List.generate(
                5 - communityCards.length, (index) => _buildEmptyCard()),
          ],
        ),
      ],
    );
  }

  Widget _buildCard(poker.Card card) {
    Color cardColor =
        card.suit == '♥' || card.suit == '♦' ? Colors.red : Colors.black;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: Container(
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
      ),
    );
  }

  Widget _buildEmptyCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: Container(
        width: 50,
        height: 70,
        decoration: BoxDecoration(
          color: Colors.grey.withOpacity(0.3),
          borderRadius: BorderRadius.circular(4.0),
          border: Border.all(color: Colors.white.withOpacity(0.5)),
        ),
      ),
    );
  }
}
