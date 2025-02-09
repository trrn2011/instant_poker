import 'package:flutter/material.dart';
import '../utils/colors_util.dart';
import '../widgets/circle_container_widget.dart';
import 'package:provider/provider.dart';
import '../providers/game_setting_provider.dart';
import '../models/poker_game.dart';
import '../models/player.dart';
import '../widgets/player_hand_widget.dart';
import '../widgets/community_cards_widget.dart';
import '../widgets/betting_controls_widget.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late PokerGame game;
  late List<Player> players;

  @override
  void initState() {
    super.initState();
    _initializeGame();
  }

  void _initializeGame() {
    // 仮のプレイヤーを作成
    players = [
      Player('あなた', 10000),
      Player('CPU 1', 10000),
      Player('CPU 2', 10000),
      Player('CPU 3', 10000),
    ];
    game = PokerGame(players);
    game.startNewHand();
  }

  @override
  Widget build(BuildContext context) {
    final gameSettings = Provider.of<GameSettingProvider>(context);

    return Scaffold(
      backgroundColor: ColorsUtil.backgroundPurple,
      appBar: AppBar(
        title: Text('ポーカーゲーム'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          if (game.isGameOver)
            TextButton(
              onPressed: () {
                setState(() {
                  _initializeGame();
                });
              },
              child: Text(
                '新しいゲーム',
                style: TextStyle(color: Colors.white),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/poker_table.png'),
                  fit: BoxFit.contain,
                ),
                border: Border.all(color: Colors.white, width: 2.0),
              ),
              width: double.infinity,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // 対戦相手のカード
                  Padding(
                    padding: const EdgeInsets.only(top: 20.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        PlayerHandWidget(
                          player: players[2],
                          isCurrentPlayer: game.currentPlayer == players[2],
                          isFaceDown: !game.isGameOver,
                        ),
                        PlayerHandWidget(
                          player: players[3],
                          isCurrentPlayer: game.currentPlayer == players[3],
                          isFaceDown: !game.isGameOver,
                        ),
                      ],
                    ),
                  ),
                  // コミュニティカード
                  CommunityCardsWidget(
                    communityCards: game.communityCards,
                    pot: game.pot,
                  ),
                  // プレイヤーのカードとベッティングコントロール
                  Column(
                    children: [
                      PlayerHandWidget(
                        player: players[0],
                        isCurrentPlayer: game.currentPlayer == players[0],
                        isFaceDown: false,
                      ),
                      if (game.currentPlayer == players[0] && !game.isGameOver)
                        BettingControlsWidget(
                          onCheck: () {
                            setState(() {
                              game.placeBet(
                                  game.currentPlayer, game.currentBet);
                              game.nextPlayer();
                              if (game.isRoundComplete()) {
                                game.nextPhase();
                              }
                            });
                          },
                          onCall: () {
                            setState(() {
                              game.placeBet(
                                  game.currentPlayer, game.currentBet);
                              game.nextPlayer();
                              if (game.isRoundComplete()) {
                                game.nextPhase();
                              }
                            });
                          },
                          onRaise: (amount) {
                            setState(() {
                              game.placeBet(game.currentPlayer, amount);
                              game.nextPlayer();
                            });
                          },
                          onFold: () {
                            setState(() {
                              game.fold(game.currentPlayer);
                              game.nextPlayer();
                              if (game.isRoundComplete()) {
                                game.nextPhase();
                              }
                            });
                          },
                          currentBet: game.currentBet,
                          playerChips: game.currentPlayer.chips,
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
