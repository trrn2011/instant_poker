/// トランプのカードを表すクラス
class Card {
  final String suit; // スート（マーク）：♠, ♥, ♦, ♣
  final int rank; // ランク（数字）：1(A)〜13(K)

  /// カードを作成する
  /// @param suit カードのスート
  /// @param rank カードのランク（1=A, 11=J, 12=Q, 13=K）
  Card(this.suit, this.rank);

  @override

  /// カードの文字列表現を返す（例：「♠A」「♥10」「♦J」など）
  String toString() {
    String rankStr;
    switch (rank) {
      case 1:
        rankStr = 'A';
        break;
      case 11:
        rankStr = 'J';
        break;
      case 12:
        rankStr = 'Q';
        break;
      case 13:
        rankStr = 'K';
        break;
      default:
        rankStr = rank.toString();
    }
    return '$suit$rankStr';
  }
}

/// トランプのデッキ（山札）を表すクラス
class Deck {
  List<Card> cards = []; // デッキ内のカード
  static final List<String> suits = ['♠', '♥', '♦', '♣']; // 使用するスート
  static final List<int> ranks =
      List.generate(13, (i) => i + 1); // 使用するランク（1-13）

  /// デッキを作成し、カードを初期化する
  Deck() {
    reset();
  }

  /// デッキをリセットし、すべてのカードを再生成してシャッフルする
  void reset() {
    cards.clear();
    for (var suit in suits) {
      for (var rank in ranks) {
        cards.add(Card(suit, rank));
      }
    }
    shuffle();
  }

  /// デッキ内のカードをシャッフルする
  void shuffle() {
    cards.shuffle();
  }

  /// デッキからカードを1枚引く
  /// @return 引いたカード。デッキが空の場合はnull
  Card? drawCard() {
    if (cards.isEmpty) return null;
    return cards.removeLast();
  }
}
