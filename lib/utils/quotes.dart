import 'dart:math';

class OsintQuotes {
  static final List<QuoteModel> _quotes = [
    QuoteModel(
      quote: "The quieter you become, the more you can hear.",
      author: "Rumi",
    ),
    QuoteModel(
      quote: "In the land of the blind, the one-eyed man is King. In the land of the deaf, the silent man is God.",
      author: "Unknown",
    ),
    QuoteModel(
      quote: "The internet remembers everything, even what you choose to forget.",
      author: "Digital Forensics Adage",
    ),
    QuoteModel(
      quote: "If you are not paying for the product, then you are the product.",
      author: "Tristan Harris",
    ),
    QuoteModel(
      quote: "Technology trust is a good thing, but control is a better one.",
      author: "Stephane Nappo",
    ),
    QuoteModel(
      quote: "Defenders have to be right 100% of the time. Attackers only have to be right once.",
      author: "Ben Sasse",
    ),
    QuoteModel(
      quote: "The devil is in the details, but so is the salvation.",
      author: "Unknown",
    ),
    QuoteModel(
      quote: "You can't delete what has already been seen.",
      author: "Internet Adage",
    ),
    QuoteModel(
      quote: "Data frames the picture, but analysis tells the story.",
      author: "Intelligence Proverb",
    ),
    QuoteModel(
      quote: "To find a needle in a haystack, you don't look for the needle. You burn the hay.",
      author: "Unknown",
    ),
    QuoteModel(
      quote: "Amateurs hack systems, professionals hack people.",
      author: "Bruce Schneier",
    ),
    QuoteModel(
      quote: "Trust is a vulnerability.",
      author: "Mr. Robot",
    ),
    
    QuoteModel(
      quote: "Arguing that you don't care about privacy because you have nothing to hide is no different than saying you don't care about free speech because you have nothing to say.",
      author: "Edward Snowden",
    ),
    QuoteModel(
      quote: "There is no cloud, it's just someone else's computer.",
      author: "Tech Adage",
    ),
    
    QuoteModel(
      quote: "All warfare is based on deception.",
      author: "Sun Tzu",
    ),
    QuoteModel(
      quote: "With great power comes great responsibility.",
      author: "Voltaire",
    ),
    QuoteModel(
      quote: "Being invisible is not about hiding, but about knowing when to be seen.",
      author: "Anonymous",
    ),
    QuoteModel(
      quote: "The supreme art of war is to subdue the enemy without fighting.",
      author: "Sun Tzu",
    ),
    
    QuoteModel(
      quote: "We don't see things as they are, we see them as we are.",
      author: "Anaïs Nin",
    ),
    QuoteModel(
      quote: "Information is not knowledge. The only source of knowledge is experience.",
      author: "Albert Einstein",
    ),
    QuoteModel(
      quote: "Who watches the watchmen?",
      author: "Juvenal",
    ),
  ];

  static QuoteModel getRandomQuote() {
    final random = Random();
    return _quotes[random.nextInt(_quotes.length)];
  }

  static List<QuoteModel> getAllQuotes() => _quotes;
}

class QuoteModel {
  final String quote;
  final String author;

  QuoteModel({
    required this.quote,
    required this.author,
  });

  @override
  String toString() => '"$quote"\n— $author';
}
