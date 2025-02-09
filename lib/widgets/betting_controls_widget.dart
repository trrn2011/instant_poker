import 'package:flutter/material.dart';
import '../utils/colors_util.dart';

class BettingControlsWidget extends StatelessWidget {
  final VoidCallback onCheck;
  final VoidCallback onCall;
  final Function(int) onRaise;
  final VoidCallback onFold;
  final int currentBet;
  final int playerChips;

  const BettingControlsWidget({
    required this.onCheck,
    required this.onCall,
    required this.onRaise,
    required this.onFold,
    required this.currentBet,
    required this.playerChips,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          if (currentBet == 0)
            _buildActionButton(
              'チェック',
              onCheck,
              Colors.green,
            )
          else
            _buildActionButton(
              'コール\n$currentBet',
              onCall,
              Colors.blue,
            ),
          _buildRaiseButton(context),
          _buildActionButton(
            'フォールド',
            onFold,
            Colors.red,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(String text, VoidCallback onPressed, Color color) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(color: Colors.white),
      ),
    );
  }

  Widget _buildRaiseButton(BuildContext context) {
    return ElevatedButton(
      onPressed: () => _showRaiseDialog(context),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.orange,
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: Text(
        'レイズ',
        style: TextStyle(color: Colors.white),
      ),
    );
  }

  void _showRaiseDialog(BuildContext context) {
    int raiseAmount = currentBet * 2;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: ColorsUtil.backgroundPurple,
        title: Text(
          'レイズ額を選択',
          style: TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '現在のベット: $currentBet',
              style: TextStyle(color: Colors.white),
            ),
            Text(
              '残りチップ: $playerChips',
              style: TextStyle(color: Colors.white),
            ),
            Slider(
              value: raiseAmount.toDouble(),
              min: currentBet * 2.0,
              max: playerChips.toDouble(),
              divisions: 20,
              label: raiseAmount.toString(),
              onChanged: (value) {
                raiseAmount = value.toInt();
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'キャンセル',
              style: TextStyle(color: Colors.white),
            ),
          ),
          TextButton(
            onPressed: () {
              onRaise(raiseAmount);
              Navigator.pop(context);
            },
            child: Text(
              '確定',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
