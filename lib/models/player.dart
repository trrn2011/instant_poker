import 'card.dart';

/// ポーカーゲームのプレイヤーを表すクラス
class Player {
  String name; // プレイヤー名
  List<Card> hand = []; // プレイヤーの手札
  int chips; // プレイヤーの持っているチップ数
  bool isActive = true; // プレイヤーがゲームに参加中かどうか
  bool hasFolded = false; // プレイヤーがフォールド（降り）したかどうか
  int currentBet = 0; // 現在のベッティングラウンドでのベット額

  /// プレイヤーを作成する
  /// @param name プレイヤー名
  /// @param chips 初期チップ数
  Player(this.name, this.chips);

  /// プレイヤーにカードを配る
  /// @param card 配るカード
  void receiveCard(Card card) {
    hand.add(card);
  }

  /// プレイヤーの手札をリセットする
  /// 新しいラウンド開始時に呼び出される
  void clearHand() {
    hand.clear();
    hasFolded = false;
    currentBet = 0;
  }

  /// プレイヤーがベットを行う
  /// @param amount ベット額
  /// @return ベットが成功したかどうか（チップが足りない場合はfalse）
  bool placeBet(int amount) {
    if (amount > chips) return false;
    chips -= amount;
    currentBet += amount;
    return true;
  }

  /// プレイヤーが勝利金を受け取る
  /// @param amount 受け取る金額
  void collectWinnings(int amount) {
    chips += amount;
  }

  /// プレイヤーがフォールド（降り）する
  void fold() {
    hasFolded = true;
  }
}
