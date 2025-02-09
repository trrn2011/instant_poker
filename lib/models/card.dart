class Card {
  final String suit;
  final int rank;

  Card(this.suit, this.rank);

  @override
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

class Deck {
  List<Card> cards = [];
  static final List<String> suits = ['♠', '♥', '♦', '♣'];
  static final List<int> ranks = List.generate(13, (i) => i + 1);

  Deck() {
    reset();
  }

  void reset() {
    cards.clear();
    for (var suit in suits) {
      for (var rank in ranks) {
        cards.add(Card(suit, rank));
      }
    }
    shuffle();
  }

  void shuffle() {
    cards.shuffle();
  }

  Card? drawCard() {
    if (cards.isEmpty) return null;
    return cards.removeLast();
  }
} 