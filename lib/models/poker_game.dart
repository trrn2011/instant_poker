import 'card.dart';
import 'player.dart';
import 'hand_evaluator.dart';
import 'dart:async';

/// ポーカーゲームの各フェーズを表す列挙型
enum GamePhase {
  preFlop, // 最初の配札後、コミュニティカードが公開される前
  flop, // 最初の3枚のコミュニティカードが公開された後
  turn, // 4枚目のコミュニティカードが公開された後
  river, // 5枚目のコミュニティカードが公開された後
  showdown, // すべてのカードが公開され、勝者を決定するフェーズ
}

/// プレイヤーのアクションを表す列挙型
enum PlayerAction {
  check, // チェック（パス）
  bet, // ベット
  call, // コール
  raise, // レイズ
  fold, // フォールド
  none, // アクションなし
}

/// プレイヤーのアクション情報
class ActionInfo {
  final PlayerAction action;
  final int amount;
  final Player player;

  ActionInfo(this.action, this.amount, this.player);

  @override
  String toString() {
    switch (action) {
      case PlayerAction.check:
        return 'チェック';
      case PlayerAction.bet:
        return '$amountベット';
      case PlayerAction.call:
        return '$amountコール';
      case PlayerAction.raise:
        return '$amountレイズ';
      case PlayerAction.fold:
        return 'フォールド';
      default:
        return '';
    }
  }
}

/// ポーカーゲームのメインクラス
/// ゲームの状態管理や進行を制御する
class PokerGame {
  final List<Player> players; // ゲームに参加しているプレイヤーのリスト
  final Deck deck; // ゲームで使用するカードデッキ
  List<Card> communityCards = []; // 場に公開されているコミュニティカード
  int currentPlayerIndex = 0; // 現在のターンのプレイヤーのインデックス
  int dealerIndex = 0; // ディーラーポジションのプレイヤーのインデックス
  int smallBlindIndex = 0; // スモールブラインドポジションのプレイヤーのインデックス
  int bigBlindIndex = 0; // ビッグブラインドポジションのプレイヤーのインデックス
  int pot = 0; // 現在の場のポット（賭け金の合計）
  int currentBet = 0; // 現在のベット額
  int smallBlindAmount = 50; // スモールブラインドの額
  int bigBlindAmount = 100; // ビッグブラインドの額
  GamePhase currentPhase = GamePhase.preFlop; // 現在のゲームフェーズ
  bool isGameOver = false; // ゲームが終了したかどうか
  int roundStartPlayerIndex = 0; // ベッティングラウンドの最初のプレイヤーのインデックス

  // 最後のアクション情報
  ActionInfo? lastAction;

  // CPU処理中フラグ
  bool isCPUProcessing = false;

  // アクション通知用コールバック
  Function(ActionInfo)? onActionPerformed;

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
    lastAction = null;
    isCPUProcessing = false;

    // プレイヤーの状態をリセット
    for (var player in players) {
      player.clearHand();
    }

    // ディーラーを移動
    dealerIndex = (dealerIndex + 1) % players.length;

    // ブラインドポジションの設定
    setBlindPositions();

    // ブラインドベットの徴収
    collectBlinds();

    // 初期カードを配る
    _dealInitialCards();

    // プリフロップの最初のプレイヤーを設定（ビッグブラインドの次のプレイヤー）
    if (players.length > 3) {
      currentPlayerIndex = (bigBlindIndex + 1) % players.length;
    } else {
      // 2-3人ゲームではディーラーが最初に行動
      currentPlayerIndex = dealerIndex;
    }

    roundStartPlayerIndex = currentPlayerIndex;

    // 最初のCPUプレイヤーのターンを処理
    if (currentPlayer.name != 'あなた') {
      handleCPUTurn();
    }
  }

  /// ブラインドポジションを設定する
  void setBlindPositions() {
    if (players.length == 2) {
      // ヘッズアップ（2人対戦）の場合、ディーラーがスモールブラインド
      smallBlindIndex = dealerIndex;
      bigBlindIndex = (dealerIndex + 1) % players.length;
    } else {
      // 3人以上の場合、ディーラーの次のプレイヤーがスモールブラインド
      smallBlindIndex = (dealerIndex + 1) % players.length;
      bigBlindIndex = (dealerIndex + 2) % players.length;
    }
  }

  /// ブラインドベットを徴収する
  void collectBlinds() {
    // スモールブラインドの徴収
    _recordAction(PlayerAction.bet, smallBlindAmount, players[smallBlindIndex]);
    placeBet(players[smallBlindIndex], smallBlindAmount);

    // ビッグブラインドの徴収
    _recordAction(PlayerAction.bet, bigBlindAmount, players[bigBlindIndex]);
    placeBet(players[bigBlindIndex], bigBlindAmount);

    // 現在のベット額はビッグブラインドの額
    currentBet = bigBlindAmount;
  }

  /// アクション情報を記録する
  void _recordAction(PlayerAction action, int amount, Player player) {
    lastAction = ActionInfo(action, amount, player);
    if (onActionPerformed != null) {
      onActionPerformed!(lastAction!);
    }
  }

  /// 各プレイヤーに初期の2枚のカードを配る
  void _dealInitialCards() {
    // 各プレイヤーに2枚ずつカードを配る（ディーラーから時計回りに配る）
    for (int i = 0; i < 2; i++) {
      for (int j = 0; j < players.length; j++) {
        int playerIndex = (dealerIndex + j + 1) % players.length;
        if (players[playerIndex].isActive) {
          var card = deck.drawCard();
          if (card != null) {
            players[playerIndex].receiveCard(card);
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

    // フロップ以降は、ディーラーの左側から行動開始
    if (currentPhase != GamePhase.showdown) {
      // ディーラーの左隣から行動開始（残っているプレイヤーのうち最もディーラーに近いプレイヤー）
      int startIndex = (dealerIndex + 1) % players.length;
      int initialStartIndex = startIndex; // 一周したかどうかを確認するための変数

      do {
        if (players[startIndex].isActive && !players[startIndex].hasFolded) {
          currentPlayerIndex = startIndex;
          roundStartPlayerIndex = startIndex;
          break;
        }
        startIndex = (startIndex + 1) % players.length;
      } while (startIndex != initialStartIndex); // 一周してもプレイヤーが見つからない場合は終了

      // 次のプレイヤーがCPUの場合、自動的に行動
      if (currentPlayer.name != 'あなた' && !isGameOver) {
        handleCPUTurn();
      }
    }
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
      // 7枚のカードから最強の5枚を見つける
      var result = HandEvaluator.evaluateHand(allCards);
      playerHands[player] = result;
    }

    // 勝者を決定
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
      if (amount > currentBet) {
        currentBet = amount;
      }
    }
  }

  /// プレイヤーが新しくベットを行う
  /// @param player ベットするプレイヤー
  /// @param amount ベット額
  void bet(Player player, int amount) {
    if (!player.isActive || player.hasFolded) return;
    // ベットは前にベットがない場合のみ可能
    if (currentBet > 0) return;

    if (player.placeBet(amount)) {
      pot += amount;
      currentBet = amount;
      _recordAction(PlayerAction.bet, amount, player);
    }
  }

  /// プレイヤーがレイズを行う
  /// @param player レイズするプレイヤー
  /// @param amount レイズ額（現在のベット額に上乗せする額）
  void raise(Player player, int amount) {
    if (!player.isActive || player.hasFolded) return;
    // レイズは前にベットがある場合のみ可能
    if (currentBet == 0) return;

    int totalBet = currentBet + amount;
    if (player.placeBet(totalBet)) {
      pot += totalBet;
      currentBet = totalBet;
      _recordAction(PlayerAction.raise, amount, player);
    }
  }

  /// プレイヤーがコールを行う
  /// @param player コールするプレイヤー
  void call(Player player) {
    if (!player.isActive || player.hasFolded) return;
    // コールは前にベットがある場合のみ可能
    if (currentBet == 0) return;

    int amountToCall = currentBet - player.currentBet;
    if (amountToCall <= 0) return; // すでに十分なベット額がある場合
    if (player.placeBet(amountToCall)) {
      pot += amountToCall;
      _recordAction(PlayerAction.call, amountToCall, player);
    }
  }

  /// プレイヤーがチェックを行う
  /// @param player チェックするプレイヤー
  bool check(Player player) {
    if (!player.isActive || player.hasFolded) return false;
    // ベットがない場合、または既に現在のベットと同額を賭けている場合のみチェック可能
    if (currentBet == 0 || player.currentBet == currentBet) {
      _recordAction(PlayerAction.check, 0, player);
      return true;
    }
    return false;
  }

  /// プレイヤーが降りる（フォールド）
  /// @param player フォールドするプレイヤー
  void fold(Player player) {
    if (!player.isActive) return;
    player.fold();
    _recordAction(PlayerAction.fold, 0, player);

    // 1人しか残っていない場合は自動的に勝利
    List<Player> activePlayers =
        players.where((p) => p.isActive && !p.hasFolded).toList();
    if (activePlayers.length == 1) {
      activePlayers.first.collectWinnings(pot);
      isGameOver = true;
    }
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
      // ラウンドの最初のプレイヤーに戻った場合、全員が行動済み
      if (currentPlayerIndex == roundStartPlayerIndex && isRoundComplete()) {
        nextPhase();
        return;
      }
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
    if (activePlayers.isEmpty) return true;
    return activePlayers.every((p) => p.currentBet == currentBet);
  }

  /// CPUプレイヤーのターンを処理する（非同期処理）
  /// 一定の確率でコール、チェック、レイズ、フォールドを選択
  void handleCPUTurn() {
    // すでに処理中なら何もしない
    if (isCPUProcessing) return;

    isCPUProcessing = true;

    // 非同期でCPUの行動を処理する
    Future.delayed(Duration(milliseconds: 1500), () {
      if (currentPlayer.name == 'あなた' || isGameOver) {
        isCPUProcessing = false;
        return;
      }

      // CPUの戦略（ランダム）
      int randomAction = (DateTime.now().millisecondsSinceEpoch % 10);

      if (currentBet == 0 || currentPlayer.currentBet == currentBet) {
        // ベットがない場合またはすでにコールしている場合
        if (randomAction < 7) {
          // 70%の確率でチェック
          check(currentPlayer);
        } else {
          // 30%の確率でベット
          if (currentBet == 0) {
            // ベットがない場合はベット
            int betAmount = bigBlindAmount;
            bet(currentPlayer, betAmount);
          } else {
            // すでにベットがある場合はレイズ
            raise(currentPlayer, bigBlindAmount);
          }
        }
      } else {
        // ベットがあって、まだコールしていない場合
        if (randomAction < 5) {
          // 50%の確率でコール
          call(currentPlayer);
        } else if (randomAction < 8) {
          // 30%の確率でフォールド
          fold(currentPlayer);
        } else {
          // 20%の確率でレイズ
          raise(currentPlayer, bigBlindAmount);
        }
      }

      isCPUProcessing = false;
      nextPlayer();
    });
  }
}
