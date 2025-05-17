import 'card.dart';
import 'player.dart';
import 'hand_evaluator.dart';

/// ポーカーゲームの各フェーズを表す列挙型
enum GamePhase {
  preFlop, // 最初の配札後、コミュニティカードが公開される前
  flop, // 最初の3枚のコミュニティカードが公開された後
  turn, // 4枚目のコミュニティカードが公開された後
  river, // 5枚目のコミュニティカードが公開された後
  showdown, // すべてのカードが公開され、勝者を決定するフェーズ
}

/// ポーカーゲームのメインクラス
/// ゲームの状態管理や進行を制御する
class PokerGame {
  final List<Player> players; // ゲームに参加しているプレイヤーのリスト
  final Deck deck; // ゲームで使用するカードデッキ
  List<Card> communityCards = []; // 場に公開されているコミュニティカード
  int currentPlayerIndex = 0; // 現在のターンのプレイヤーのインデックス
  int dealerIndex = 0; // ディーラーポジションのプレイヤーのインデックス
  int pot = 0; // 現在の場のポット（賭け金の合計）
  int currentBet = 0; // 現在のベット額
  GamePhase currentPhase = GamePhase.preFlop; // 現在のゲームフェーズ
  bool isGameOver = false; // ゲームが終了したかどうか

  /// コンストラクタ
  /// 最低2人のプレイヤーが必要
  PokerGame(this.players) : deck = Deck() {
    if (players.length < 2) {
      throw ArgumentError('プレイヤーは2人以上必要です');
    }
  }

  /// 新しい手札を開始する
  /// ゲーム状態をリセットし、カードを配り、最初のプレイヤーのターンを設定
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

  /// 各プレイヤーに初期の2枚のカードを配る
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

  /// 次のゲームフェーズに進む
  /// プリフロップ → フロップ → ターン → リバー → ショーダウン の順に進行
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

  /// フロップカードを配る（コミュニティカードの最初の3枚）
  void _dealFlop() {
    for (int i = 0; i < 3; i++) {
      var card = deck.drawCard();
      if (card != null) {
        communityCards.add(card);
      }
    }
  }

  /// ターンカードを配る（コミュニティカードの4枚目）
  void _dealTurn() {
    var card = deck.drawCard();
    if (card != null) {
      communityCards.add(card);
    }
  }

  /// リバーカードを配る（コミュニティカードの5枚目）
  void _dealRiver() {
    var card = deck.drawCard();
    if (card != null) {
      communityCards.add(card);
    }
  }

  /// ショーダウン（勝者決定）を処理する
  /// 各プレイヤーの手札を評価し、勝者にポットを与える
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

  /// プレイヤーがベットを行う
  /// @param player ベットするプレイヤー
  /// @param amount ベット額
  void placeBet(Player player, int amount) {
    if (!player.isActive || player.hasFolded) return;
    if (player.placeBet(amount)) {
      pot += amount;
      currentBet = amount;
    }
  }

  /// プレイヤーが降りる（フォールド）
  /// @param player フォールドするプレイヤー
  void fold(Player player) {
    if (!player.isActive) return;
    player.fold();
  }

  /// ベッティングラウンドをリセットする
  /// 各プレイヤーの現在のベット額をクリア
  void resetBettingRound() {
    currentBet = 0;
    for (var player in players) {
      player.currentBet = 0;
    }
  }

  /// 現在のターンのプレイヤーを取得
  Player get currentPlayer => players[currentPlayerIndex];

  /// 次のプレイヤーに進む
  /// フォールドしたプレイヤーや非アクティブなプレイヤーはスキップ
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

  /// 現在のベッティングラウンドが完了したかどうかを確認
  /// すべての活動中のプレイヤーが同じベット額にそろった場合に完了
  bool isRoundComplete() {
    var activePlayers = players.where((p) => p.isActive && !p.hasFolded);
    return activePlayers.every((p) => p.currentBet == currentBet);
  }

  /// CPUプレイヤーのターンを処理
  /// 現在の実装では、CPUは常にコールまたはチェック
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
