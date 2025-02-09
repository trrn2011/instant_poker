import 'card.dart';
import 'player.dart';
import 'hand_evaluator.dart';

enum GamePhase {
  preFlop,
  flop,
  turn,
  river,
  showdown,
}

class PokerGame {
  final List<Player> players;
  final Deck deck;
  List<Card> communityCards = [];
  int currentPlayerIndex = 0;
  int dealerIndex = 0;
  int pot = 0;
  int currentBet = 0;
  GamePhase currentPhase = GamePhase.preFlop;
  bool isGameOver = false;

  PokerGame(this.players) : deck = Deck() {
    if (players.length < 2) {
      throw ArgumentError('プレイヤーは2人以上必要です');
    }
  }

  void startNewHand() {
    // ゲームの状態をリセット
    deck.reset();
    communityCards.clear();
    pot = 0;
    currentBet = 0;
    currentPhase = GamePhase.preFlop;
    isGameOver = false;

    // プレイヤーの状態をリセット
    for (var player in players) {
      player.clearHand();
    }

    // ディーラーを移動
    dealerIndex = (dealerIndex + 1) % players.length;
    currentPlayerIndex = (dealerIndex + 1) % players.length;

    // 初期カードを配る
    _dealInitialCards();

    // 最初のCPUプレイヤーのターンを処理
    if (currentPlayer.name != 'あなた') {
      handleCPUTurn();
    }
  }

  void _dealInitialCards() {
    // 各プレイヤーに2枚ずつカードを配る
    for (int i = 0; i < 2; i++) {
      for (var player in players) {
        if (player.isActive) {
          var card = deck.drawCard();
          if (card != null) {
            player.receiveCard(card);
          }
        }
      }
    }
  }

  void nextPhase() {
    switch (currentPhase) {
      case GamePhase.preFlop:
        _dealFlop();
        currentPhase = GamePhase.flop;
        break;
      case GamePhase.flop:
        _dealTurn();
        currentPhase = GamePhase.turn;
        break;
      case GamePhase.turn:
        _dealRiver();
        currentPhase = GamePhase.river;
        break;
      case GamePhase.river:
        _showdown();
        currentPhase = GamePhase.showdown;
        break;
      case GamePhase.showdown:
        isGameOver = true;
        break;
    }
    resetBettingRound();
  }

  void _dealFlop() {
    for (int i = 0; i < 3; i++) {
      var card = deck.drawCard();
      if (card != null) {
        communityCards.add(card);
      }
    }
  }

  void _dealTurn() {
    var card = deck.drawCard();
    if (card != null) {
      communityCards.add(card);
    }
  }

  void _dealRiver() {
    var card = deck.drawCard();
    if (card != null) {
      communityCards.add(card);
    }
  }

  void _showdown() {
    List<Player> activePlayers =
        players.where((p) => p.isActive && !p.hasFolded).toList();
    if (activePlayers.length <= 1) {
      // 1人しか残っていない場合は自動的に勝利
      activePlayers.first.collectWinnings(pot);
      return;
    }

    // 各プレイヤーの最強の手を評価
    var playerHands = <Player, HandResult>{};
    for (var player in activePlayers) {
      var allCards = [...player.hand, ...communityCards];
      // 7枚のカードから最強の5枚を見つける（簡略化のため、現在は7枚すべてを使用）
      var result = HandEvaluator.evaluateHand(allCards.sublist(0, 5));
      playerHands[player] = result;
    }

    // 勝者を決定（簡略化のため、最初の最強手のプレイヤーが勝利）
    var winner = playerHands.entries
        .reduce((a, b) => a.value.handRank > b.value.handRank ? a : b)
        .key;
    winner.collectWinnings(pot);
  }

  void placeBet(Player player, int amount) {
    if (!player.isActive || player.hasFolded) return;
    if (player.placeBet(amount)) {
      pot += amount;
      currentBet = amount;
    }
  }

  void fold(Player player) {
    if (!player.isActive) return;
    player.fold();
  }

  void resetBettingRound() {
    currentBet = 0;
    for (var player in players) {
      player.currentBet = 0;
    }
  }

  Player get currentPlayer => players[currentPlayerIndex];

  void nextPlayer() {
    do {
      currentPlayerIndex = (currentPlayerIndex + 1) % players.length;
    } while (!players[currentPlayerIndex].isActive ||
        players[currentPlayerIndex].hasFolded);

    // 次のプレイヤーがCPUの場合、自動的に行動
    if (currentPlayer.name != 'あなた' && !isGameOver) {
      handleCPUTurn();
    }
  }

  bool isRoundComplete() {
    var activePlayers = players.where((p) => p.isActive && !p.hasFolded);
    return activePlayers.every((p) => p.currentBet == currentBet);
  }

  void handleCPUTurn() {
    if (currentPlayer.name == 'あなた') return;

    // CPUは常にコールまたはチェック
    if (currentBet > 0) {
      placeBet(currentPlayer, currentBet);
    }
    nextPlayer();

    if (isRoundComplete()) {
      nextPhase();
    }
  }
}
