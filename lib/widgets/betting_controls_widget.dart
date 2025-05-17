import 'package:flutter/material.dart';
import '../utils/colors_util.dart';
import '../models/poker_game.dart';

class BettingControlsWidget extends StatefulWidget {
  final VoidCallback onCheck;
  final VoidCallback onCall;
  final Function(int) onRaise;
  final VoidCallback onFold;
  final int currentBet;
  final int playerChips;
  final int playerCurrentBet;
  final GamePhase currentPhase;
  final bool isSmallBlind;
  final bool isBigBlind;
  final int smallBlindAmount;
  final int bigBlindAmount;

  const BettingControlsWidget({
    required this.onCheck,
    required this.onCall,
    required this.onRaise,
    required this.onFold,
    required this.currentBet,
    required this.playerChips,
    required this.playerCurrentBet,
    required this.currentPhase,
    this.isSmallBlind = false,
    this.isBigBlind = false,
    this.smallBlindAmount = 50,
    this.bigBlindAmount = 100,
    super.key,
  });

  @override
  State<BettingControlsWidget> createState() => _BettingControlsWidgetState();
}

class _BettingControlsWidgetState extends State<BettingControlsWidget> {
  int _raiseAmount = 0;

  @override
  void initState() {
    super.initState();
    _updateRaiseAmount();
  }

  @override
  void didUpdateWidget(BettingControlsWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentBet != widget.currentBet ||
        oldWidget.playerChips != widget.playerChips) {
      _updateRaiseAmount();
    }
  }

  void _updateRaiseAmount() {
    // 最小レイズ額を設定
    int minRaise = widget.currentPhase == GamePhase.preFlop
        ? widget.bigBlindAmount
        : widget.bigBlindAmount * 2;

    _raiseAmount = (widget.currentBet + minRaise)
        .clamp(widget.currentBet + minRaise, widget.playerChips);
  }

  @override
  Widget build(BuildContext context) {
    // コールに必要な額
    int amountToCall = widget.currentBet - widget.playerCurrentBet;

    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          _buildPhaseIndicator(),
          SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // チェックボタン (ベットがない場合、または既に十分に賭けている場合)
              if (widget.currentBet == 0 ||
                  widget.playerCurrentBet == widget.currentBet)
                _buildActionButton(
                  'チェック',
                  widget.onCheck,
                  Colors.green,
                )
              // コールボタン
              else
                _buildActionButton(
                  'コール\n$amountToCall',
                  widget.playerChips >= amountToCall ? widget.onCall : null,
                  Colors.blue,
                ),

              // レイズボタン
              _buildRaiseButton(context),

              // フォールドボタン
              _buildActionButton(
                'フォールド',
                widget.onFold,
                Colors.red,
              ),
            ],
          ),
          SizedBox(height: 8),
          _buildChipsInfo(),
        ],
      ),
    );
  }

  Widget _buildPhaseIndicator() {
    String phaseName = '';
    switch (widget.currentPhase) {
      case GamePhase.preFlop:
        phaseName = 'プリフロップ';
        break;
      case GamePhase.flop:
        phaseName = 'フロップ';
        break;
      case GamePhase.turn:
        phaseName = 'ターン';
        break;
      case GamePhase.river:
        phaseName = 'リバー';
        break;
      case GamePhase.showdown:
        phaseName = 'ショーダウン';
        break;
    }

    return Text(
      phaseName,
      style: TextStyle(
        color: Colors.white,
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildChipsInfo() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Text(
          'チップ: ${widget.playerChips}',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          'ベット: ${widget.playerCurrentBet}',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          'ポット: ?',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(String text, VoidCallback? onPressed, Color color) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        disabledBackgroundColor: Colors.grey,
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
    // レイズに必要な最小額を計算
    int minRaise = widget.currentPhase == GamePhase.preFlop
        ? widget.bigBlindAmount
        : widget.bigBlindAmount * 2;

    bool canRaise = widget.playerChips >=
        (widget.currentBet - widget.playerCurrentBet + minRaise);

    return ElevatedButton(
      onPressed: canRaise ? () => _showRaiseDialog(context) : null,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.orange,
        disabledBackgroundColor: Colors.grey,
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
    // 最小レイズ額を計算
    int minRaise = widget.currentPhase == GamePhase.preFlop
        ? widget.bigBlindAmount
        : widget.bigBlindAmount * 2;

    int minRaiseTotal = widget.currentBet + minRaise;
    int maxRaiseTotal = widget.playerChips + widget.playerCurrentBet;

    // すでに賭けている額を考慮
    int actualMinRaise =
        (minRaiseTotal - widget.playerCurrentBet).clamp(0, widget.playerChips);
    int actualMaxRaise = maxRaiseTotal - widget.playerCurrentBet;

    int raiseAmount = actualMinRaise;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: ColorsUtil.backgroundPurple,
              title: Text(
                'レイズ額を選択',
                style: TextStyle(color: Colors.white),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '現在のベット: ${widget.currentBet}',
                    style: TextStyle(color: Colors.white),
                  ),
                  Text(
                    'あなたのベット: ${widget.playerCurrentBet}',
                    style: TextStyle(color: Colors.white),
                  ),
                  Text(
                    '残りチップ: ${widget.playerChips}',
                    style: TextStyle(color: Colors.white),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'レイズ額: $raiseAmount',
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                  Slider(
                    value: raiseAmount.toDouble(),
                    min: actualMinRaise.toDouble(),
                    max: actualMaxRaise.toDouble(),
                    divisions: (actualMaxRaise - actualMinRaise) ~/ 10 + 1,
                    label: raiseAmount.toString(),
                    onChanged: (value) {
                      setDialogState(() {
                        raiseAmount = value.toInt();
                      });
                    },
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          setDialogState(() {
                            raiseAmount = actualMinRaise;
                          });
                        },
                        child: Text('最小'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          setDialogState(() {
                            raiseAmount = actualMaxRaise; // オールイン
                          });
                        },
                        child: Text('オールイン'),
                      ),
                    ],
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
                    widget.onRaise(raiseAmount);
                    Navigator.pop(context);
                  },
                  child: Text(
                    '確定',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
