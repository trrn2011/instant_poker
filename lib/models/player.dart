import 'card.dart';

class Player {
  String name;
  List<Card> hand = [];
  int chips;
  bool isActive = true;
  bool hasFolded = false;
  int currentBet = 0;

  Player(this.name, this.chips);

  void receiveCard(Card card) {
    hand.add(card);
  }

  void clearHand() {
    hand.clear();
    hasFolded = false;
    currentBet = 0;
  }

  bool placeBet(int amount) {
    if (amount > chips) return false;
    chips -= amount;
    currentBet += amount;
    return true;
  }

  void collectWinnings(int amount) {
    chips += amount;
  }

  void fold() {
    hasFolded = true;
  }
}
