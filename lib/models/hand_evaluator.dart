import 'card.dart';

/// ポーカーの手札を評価するためのクラス
class HandEvaluator {
  // 役の強さを表す定数（数値が大きいほど強い）
  static const int ROYAL_FLUSH = 9; // ロイヤルストレートフラッシュ
  static const int STRAIGHT_FLUSH = 8; // ストレートフラッシュ
  static const int FOUR_OF_A_KIND = 7; // フォーカード（4枚同じ数字）
  static const int FULL_HOUSE = 6; // フルハウス（3枚同じ数字 + 2枚同じ数字）
  static const int FLUSH = 5; // フラッシュ（同じスートが5枚）
  static const int STRAIGHT = 4; // ストレート（連続した数字が5枚）
  static const int THREE_OF_A_KIND = 3; // スリーカード（3枚同じ数字）
  static const int TWO_PAIR = 2; // ツーペア（2組の同じ数字のペア）
  static const int ONE_PAIR = 1; // ワンペア（1組の同じ数字のペア）
  static const int HIGH_CARD = 0; // ハイカード（上記の役なし）

  /// 与えられた5枚のカードの役を評価する
  /// @param cards 評価する5枚のカード
  /// @return 役の評価結果
  static HandResult evaluateHand(List<Card> cards) {
    if (cards.length != 5) {
      throw ArgumentError('手札は5枚である必要があります');
    }

    // カードをランクの高い順にソート
    List<Card> sortedCards = List.from(cards)
      ..sort((a, b) => b.rank.compareTo(a.rank));

    bool isFlush = _isFlush(sortedCards);
    bool isStraight = _isStraight(sortedCards);

    // 役の判定（強い順に判定）
    if (isFlush && isStraight) {
      if (sortedCards[0].rank == 13) {
        // エースハイストレートフラッシュ
        return HandResult(ROYAL_FLUSH, sortedCards[0].rank);
      }
      return HandResult(STRAIGHT_FLUSH, sortedCards[0].rank);
    }

    if (_hasFourOfAKind(sortedCards)) {
      return HandResult(FOUR_OF_A_KIND, _getFourOfAKindRank(sortedCards));
    }

    if (_hasFullHouse(sortedCards)) {
      return HandResult(FULL_HOUSE, _getThreeOfAKindRank(sortedCards));
    }

    if (isFlush) {
      return HandResult(FLUSH, sortedCards[0].rank);
    }

    if (isStraight) {
      return HandResult(STRAIGHT, sortedCards[0].rank);
    }

    if (_hasThreeOfAKind(sortedCards)) {
      return HandResult(THREE_OF_A_KIND, _getThreeOfAKindRank(sortedCards));
    }

    if (_hasTwoPair(sortedCards)) {
      return HandResult(TWO_PAIR, _getHigherPairRank(sortedCards));
    }

    if (_hasOnePair(sortedCards)) {
      return HandResult(ONE_PAIR, _getPairRank(sortedCards));
    }

    return HandResult(HIGH_CARD, sortedCards[0].rank);
  }

  /// 同じスートが5枚あるかチェック（フラッシュ判定）
  static bool _isFlush(List<Card> cards) {
    String suit = cards[0].suit;
    return cards.every((card) => card.suit == suit);
  }

  /// 連続した数字が5枚あるかチェック（ストレート判定）
  static bool _isStraight(List<Card> cards) {
    // エースを1として扱うストレート
    if (cards[0].rank == 13 &&
        cards[1].rank == 4 &&
        cards[2].rank == 3 &&
        cards[3].rank == 2 &&
        cards[4].rank == 1) {
      return true;
    }

    // 通常のストレート判定
    for (int i = 0; i < cards.length - 1; i++) {
      if (cards[i].rank != cards[i + 1].rank + 1) {
        return false;
      }
    }
    return true;
  }

  /// 4枚同じ数字があるかチェック（フォーカード判定）
  static bool _hasFourOfAKind(List<Card> cards) {
    return cards.where((card) => card.rank == cards[0].rank).length == 4 ||
        cards.where((card) => card.rank == cards[1].rank).length == 4;
  }

  /// フルハウスかどうかチェック（3枚同じ数字 + 2枚同じ数字）
  static bool _hasFullHouse(List<Card> cards) {
    var rankCounts = _getRankCounts(cards);
    return rankCounts.values.contains(3) && rankCounts.values.contains(2);
  }

  /// 3枚同じ数字があるかチェック（スリーカード判定）
  static bool _hasThreeOfAKind(List<Card> cards) {
    return _getRankCounts(cards).values.contains(3);
  }

  /// 2組のペアがあるかチェック（ツーペア判定）
  static bool _hasTwoPair(List<Card> cards) {
    var pairs = _getRankCounts(cards).values.where((count) => count == 2);
    return pairs.length == 2;
  }

  /// 1組のペアがあるかチェック（ワンペア判定）
  static bool _hasOnePair(List<Card> cards) {
    return _getRankCounts(cards).values.contains(2);
  }

  /// 各ランクの出現回数を計算する
  /// @return ランクをキー、出現回数を値とするマップ
  static Map<int, int> _getRankCounts(List<Card> cards) {
    var rankCounts = <int, int>{};
    for (var card in cards) {
      rankCounts[card.rank] = (rankCounts[card.rank] ?? 0) + 1;
    }
    return rankCounts;
  }

  /// フォーカードのランクを取得
  static int _getFourOfAKindRank(List<Card> cards) {
    var rankCounts = _getRankCounts(cards);
    return rankCounts.entries.firstWhere((entry) => entry.value == 4).key;
  }

  /// スリーカードのランクを取得
  static int _getThreeOfAKindRank(List<Card> cards) {
    var rankCounts = _getRankCounts(cards);
    return rankCounts.entries.firstWhere((entry) => entry.value == 3).key;
  }

  /// 2つのペアのうち、より高いランクのペアを取得
  static int _getHigherPairRank(List<Card> cards) {
    var rankCounts = _getRankCounts(cards);
    var pairs = rankCounts.entries.where((entry) => entry.value == 2).toList()
      ..sort((a, b) => b.key.compareTo(a.key));
    return pairs[0].key;
  }

  /// ペアのランクを取得
  static int _getPairRank(List<Card> cards) {
    var rankCounts = _getRankCounts(cards);
    return rankCounts.entries.firstWhere((entry) => entry.value == 2).key;
  }
}

/// ポーカーの手札の評価結果を表すクラス
class HandResult {
  final int handRank; // 役の種類（0-9の値、高いほど強い）
  final int highCard; // 役を構成する中で最も高いカードのランク

  /// 評価結果を作成
  /// @param handRank 役の種類
  /// @param highCard 最高ランクのカード
  HandResult(this.handRank, this.highCard);

  @override

  /// 役の名前を日本語で返す
  String toString() {
    String handName;
    switch (handRank) {
      case HandEvaluator.ROYAL_FLUSH:
        handName = 'ロイヤルストレートフラッシュ';
        break;
      case HandEvaluator.STRAIGHT_FLUSH:
        handName = 'ストレートフラッシュ';
        break;
      case HandEvaluator.FOUR_OF_A_KIND:
        handName = 'フォーカード';
        break;
      case HandEvaluator.FULL_HOUSE:
        handName = 'フルハウス';
        break;
      case HandEvaluator.FLUSH:
        handName = 'フラッシュ';
        break;
      case HandEvaluator.STRAIGHT:
        handName = 'ストレート';
        break;
      case HandEvaluator.THREE_OF_A_KIND:
        handName = 'スリーカード';
        break;
      case HandEvaluator.TWO_PAIR:
        handName = 'ツーペア';
        break;
      case HandEvaluator.ONE_PAIR:
        handName = 'ワンペア';
        break;
      default:
        handName = 'ハイカード';
    }
    return handName;
  }
}
