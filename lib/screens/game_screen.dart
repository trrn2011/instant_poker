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
import 'dart:async';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late PokerGame game;
  late List<Player> players;
  ActionInfo? currentAction;
  Timer? actionDisplayTimer;

  @override
  void initState() {
    super.initState();
    _initializeGame();
  }

  @override
  void dispose() {
    actionDisplayTimer?.cancel();
    super.dispose();
  }

  void _initializeGame() {
    // プレイヤーを作成
    players = [
      Player('あなた', 10000),
      Player('CPU 1', 10000),
      Player('CPU 2', 10000),
      Player('CPU 3', 10000),
    ];
    game = PokerGame(players);

    // アクション通知を設定
    game.onActionPerformed = _handleActionPerformed;

    game.startNewHand();
  }

  void _handleActionPerformed(ActionInfo actionInfo) {
    // アクション情報をデバッグログに出力 (printを使用)
    print('ポーカーアクション: ${actionInfo.player.name}: ${actionInfo.toString()}');

    setState(() {
      currentAction = actionInfo;
    });

    // 2秒後にアクション表示をクリア
    actionDisplayTimer?.cancel();
    actionDisplayTimer = Timer(Duration(seconds: 2), () {
      setState(() {
        currentAction = null;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final gameSettings = Provider.of<GameSettingProvider>(context);

    return Scaffold(
      backgroundColor: ColorsUtil.backgroundPurple,
      appBar: AppBar(
        title: Text('テキサスホールデム'),
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
      body: Stack(
        children: [
          Column(
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
                  child: Stack(
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // 対戦相手のカード
                          Padding(
                            padding: const EdgeInsets.only(top: 20.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                _buildPlayerPosition(players[2], 2),
                                _buildPlayerPosition(players[3], 3),
                              ],
                            ),
                          ),
                          // 左側のプレイヤー用のコンテナ
                          Container(
                            alignment: Alignment.centerLeft,
                            padding: EdgeInsets.only(left: 20),
                            child: _buildPlayerPosition(players[1], 1),
                          ),
                          // コミュニティカード
                          CommunityCardsWidget(
                            communityCards: game.communityCards,
                            pot: game.pot,
                          ),
                          // プレイヤーのカードとベッティングコントロール
                          Column(
                            children: [
                              _buildPlayerPosition(players[0], 0),
                              if (game.currentPlayer == players[0] &&
                                  !game.isGameOver &&
                                  !game.isCPUProcessing)
                                BettingControlsWidget(
                                  onCheck: () {
                                    setState(() {
                                      if (game.check(game.currentPlayer)) {
                                        game.nextPlayer();
                                      }
                                    });
                                  },
                                  onCall: () {
                                    setState(() {
                                      game.call(game.currentPlayer);
                                      game.nextPlayer();
                                    });
                                  },
                                  onRaise: (amount) {
                                    setState(() {
                                      game.raise(game.currentPlayer, amount);
                                      game.nextPlayer();
                                    });
                                  },
                                  onFold: () {
                                    setState(() {
                                      game.fold(game.currentPlayer);
                                      game.nextPlayer();
                                    });
                                  },
                                  currentBet: game.currentBet,
                                  playerChips: game.currentPlayer.chips,
                                  playerCurrentBet:
                                      game.currentPlayer.currentBet,
                                  currentPhase: game.currentPhase,
                                  isSmallBlind: game.smallBlindIndex == 0,
                                  isBigBlind: game.bigBlindIndex == 0,
                                  smallBlindAmount: game.smallBlindAmount,
                                  bigBlindAmount: game.bigBlindAmount,
                                ),
                            ],
                          ),
                        ],
                      ),

                      // アクション表示
                      if (currentAction != null)
                        _buildActionIndicator(currentAction!),
                    ],
                  ),
                ),
              ),
              // ゲーム情報バー
              _buildGameInfoBar(),
            ],
          ),

          // CPU処理中インジケーター
          if (game.isCPUProcessing && !game.isGameOver)
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.3),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(
                        color: Colors.white,
                      ),
                      SizedBox(height: 16),
                      Text(
                        '${game.currentPlayer.name}が考え中...',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildActionIndicator(ActionInfo actionInfo) {
    // プレイヤーの位置に応じた配置を計算
    final playerIndex = players.indexOf(actionInfo.player);
    double top, left;

    switch (playerIndex) {
      case 0: // あなた（下）
        top = MediaQuery.of(context).size.height * 0.7;
        left = MediaQuery.of(context).size.width * 0.5;
        break;
      case 1: // 左側
        top = MediaQuery.of(context).size.height * 0.5;
        left = MediaQuery.of(context).size.width * 0.2;
        break;
      case 2: // 上側左
        top = MediaQuery.of(context).size.height * 0.2;
        left = MediaQuery.of(context).size.width * 0.3;
        break;
      case 3: // 上側右
        top = MediaQuery.of(context).size.height * 0.2;
        left = MediaQuery.of(context).size.width * 0.7;
        break;
      default:
        top = MediaQuery.of(context).size.height * 0.5;
        left = MediaQuery.of(context).size.width * 0.5;
    }

    return Positioned(
      top: top,
      left: left - 50, // 中央揃え
      child: Container(
        width: 100,
        padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        decoration: BoxDecoration(
          color: _getActionColor(actionInfo.action),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black45,
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: Text(
            actionInfo.toString(),
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }

  Color _getActionColor(PlayerAction action) {
    switch (action) {
      case PlayerAction.check:
        return Colors.green;
      case PlayerAction.bet:
        return Colors.blue;
      case PlayerAction.call:
        return Colors.blue;
      case PlayerAction.raise:
        return Colors.orange;
      case PlayerAction.fold:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Widget _buildPlayerPosition(Player player, int index) {
    bool isCurrentPlayer = game.currentPlayer == player;
    bool isFaceDown = player != players[0] && !game.isGameOver;
    bool isDealer = game.dealerIndex == index;
    bool isSmallBlind = game.smallBlindIndex == index;
    bool isBigBlind = game.bigBlindIndex == index;

    return Stack(
      children: [
        PlayerHandWidget(
          player: player,
          isCurrentPlayer: isCurrentPlayer,
          isFaceDown: isFaceDown,
        ),
        // ディーラー、スモールブラインド、ビッグブラインドの表示
        if (isDealer || isSmallBlind || isBigBlind || player.currentBet > 0)
          Positioned(
            right: 0,
            bottom: 0,
            child: Row(
              children: [
                if (isDealer)
                  CircleContainer(
                    color: Colors.white,
                    child: Text('D', style: TextStyle(color: Colors.black)),
                  ),
                if (isSmallBlind)
                  CircleContainer(
                    color: Colors.blue,
                    child: Text('SB', style: TextStyle(color: Colors.white)),
                  ),
                if (isBigBlind)
                  CircleContainer(
                    color: Colors.red,
                    child: Text('BB', style: TextStyle(color: Colors.white)),
                  ),
                if (player.currentBet > 0 && !isSmallBlind && !isBigBlind)
                  CircleContainer(
                    color: Colors.green,
                    child: Text('${player.currentBet}',
                        style: TextStyle(color: Colors.white, fontSize: 10)),
                    size: 30,
                  ),
              ],
            ),
          ),
        // プレイヤーの状態表示（アクティブかどうか、現在のターンかどうか）
        if (player.isActive &&
            isCurrentPlayer &&
            !game.isGameOver &&
            !player.hasFolded)
          Positioned(
            right: -5,
            top: -5,
            child: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: Colors.yellow,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 1),
              ),
              child: Icon(Icons.arrow_forward, color: Colors.black, size: 16),
            ),
          ),
      ],
    );
  }

  Widget _buildGameInfoBar() {
    String phaseText = '';
    switch (game.currentPhase) {
      case GamePhase.preFlop:
        phaseText = 'プリフロップ';
        break;
      case GamePhase.flop:
        phaseText = 'フロップ';
        break;
      case GamePhase.turn:
        phaseText = 'ターン';
        break;
      case GamePhase.river:
        phaseText = 'リバー';
        break;
      case GamePhase.showdown:
        phaseText = 'ショーダウン';
        break;
    }

    return Container(
      padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      color: Colors.black54,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'フェーズ: $phaseText',
            style: TextStyle(color: Colors.white),
          ),
          Text(
            'ポット: ${game.pot}',
            style: TextStyle(color: Colors.white),
          ),
          Text(
            '現在のベット: ${game.currentBet}',
            style: TextStyle(color: Colors.white),
          ),
        ],
      ),
    );
  }
}
