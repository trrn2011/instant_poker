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
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.amber.withOpacity(0.7),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 8,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Text(
            'ポット: $potチップ',
            style: TextStyle(
              color: Colors.black,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        SizedBox(height: 16),
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
          boxShadow: [
            BoxShadow(
              color: Colors.black45,
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
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
