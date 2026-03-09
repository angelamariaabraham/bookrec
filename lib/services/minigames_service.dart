import 'dart:math';
import '../models/book.dart';

class MinigamesService {
  // Helper to get a pool of "popular" books (so the games are actually playable)
  static List<Book> _getPopularBooks(List<Book> allBooks) {
    return allBooks.where((b) {
      int ratings = b.numRatings ?? 0;
      return ratings > 10000; // Arbitrary threshold for "well known"
    }).toList();
  }

  // Helper to randomly select books
  static List<Book> _getRandomBooks(List<Book> pool, int count) {
    if (pool.length < count) return pool;
    final random = Random();
    var list = pool.toList()..shuffle(random);
    return list.take(count).toList();
  }

  // --- Game 2: Cover Reveal ---
  static Map<String, dynamic>? generateCoverRevealGame(List<Book> allBooks) {
    final pool = _getPopularBooks(allBooks)
        .where((b) => b.coverImageUrl != null && b.coverImageUrl!.isNotEmpty)
        .toList();
    final selection = _getRandomBooks(pool, 4);
    if (selection.length < 4) return null;

    Book correctBook = selection.first;

    // Shuffle options
    final random = Random();
    var options = selection.toList()..shuffle(random);

    return {'correct_book': correctBook, 'options': options};
  }

  // --- Game 3: Sentence Decryption ---
  static Map<String, dynamic>? generateSentenceDecryptionGame(
    List<Book> allBooks,
  ) {
    final pool = _getPopularBooks(allBooks).where((b) {
      if (b.description == null) return false;
      // Make sure it has enough sentences to be interesting
      if (b.description!.split(RegExp(r'(?<=[.!?])\s+')).length < 3)
        return false;

      // Filter out descriptions with Arabic or mostly non-English characters
      // We check if the description has a high proportion of basic Latin letters
      final onlyLetters = b.description!.replaceAll(RegExp(r'[^a-zA-Z]'), '');
      if (onlyLetters.length < (b.description!.length * 0.5)) return false;

      return true;
    }).toList();

    final selection = _getRandomBooks(pool, 4);
    if (selection.length < 4) return null;

    Book correctBook = selection.first;
    String description = correctBook.description!;

    // Obfuscate title and author from description
    String obfuscatedDesc = description;
    if (correctBook.title.length > 3) {
      obfuscatedDesc = obfuscatedDesc.replaceAll(
        RegExp(correctBook.title, caseSensitive: false),
        '[HIDDEN]',
      );
    }
    if (correctBook.author != null && correctBook.author!.length > 3) {
      obfuscatedDesc = obfuscatedDesc.replaceAll(
        RegExp(correctBook.author!, caseSensitive: false),
        '[HIDDEN]',
      );
    }

    // Split into sentences
    List<String> sentences = obfuscatedDesc.split(RegExp(r'(?<=[.!?])\s+'));
    sentences.removeWhere((s) => s.trim().isEmpty);

    // Shuffle options
    final random = Random();
    var options = selection.toList()..shuffle(random);

    return {
      'correct_book': correctBook,
      'sentences': sentences,
      'options': options,
    };
  }

  // --- Game 4: Timeline Tool ---
  static Map<String, dynamic>? generateTimelineGame(List<Book> allBooks) {
    final pool = _getPopularBooks(allBooks).where((b) {
      if (b.publishDate == null) return false;
      return double.tryParse(b.publishDate!) != null ||
          b.publishDate!.contains(RegExp(r'\d{4}'));
    }).toList();

    final selection = _getRandomBooks(pool, 4);
    if (selection.length < 4) return null;

    // We don't need a single correct book, the goal is ordering all 4.
    // Parse years to determine correct order
    List<Map<String, dynamic>> items = selection.map((b) {
      int year = 0;
      // Very basic extraction of 4 digits
      var match = RegExp(r'\d{4}').firstMatch(b.publishDate ?? '');
      if (match != null) {
        year = int.tryParse(match.group(0) ?? '0') ?? 0;
      }
      return {'book': b, 'year': year};
    }).toList();

    // Sort to find correct order
    var sorted = items.toList()
      ..sort((a, b) => (a['year'] as int).compareTo(b['year'] as int));

    return {
      'items': items, // Currently random order
      'correct_order_ids': sorted.map((e) => (e['book'] as Book).id).toList(),
    };
  }
}
