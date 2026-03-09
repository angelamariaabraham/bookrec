import 'dart:math';
import '../models/book.dart';

class RecommenderService {
  // Simple TF-IDF implementation in Dart
  
  static Map<int, Map<String, double>> computeTfIdf(List<Book> books) {
    Map<String, int> docFrequency = {};
    List<Map<String, int>> termFrequencies = [];

    // 1. Calculate Term Frequency and Document Frequency
    for (var book in books) {
      String text = (book.normalizedDescription ?? '').toLowerCase();
      List<String> words = text.split(RegExp(r'\W+')).where((w) => w.length > 2).toList();
      
      Map<String, int> tf = {};
      Set<String> uniqueWords = {};
      for (var word in words) {
        tf[word] = (tf[word] ?? 0) + 1;
        uniqueWords.add(word);
      }
      termFrequencies.add(tf);

      for (var word in uniqueWords) {
        docFrequency[word] = (docFrequency[word] ?? 0) + 1;
      }
    }

    int n = books.length;
    Map<int, Map<String, double>> tfIdfMatrix = {};

    // 2. Calculate TF-IDF
    for (int i = 0; i < books.length; i++) {
      Map<String, double> weights = {};
      termFrequencies[i].forEach((word, count) {
        double tf = count.toDouble();
        double idf = log(n / (docFrequency[word] ?? 1));
        weights[word] = tf * idf;
      });
      tfIdfMatrix[books[i].id!] = weights;
    }

    return tfIdfMatrix;
  }

  static double cosineSimilarity(Map<String, double> v1, Map<String, double> v2) {
    double dotProduct = 0;
    double mag1 = 0;
    double mag2 = 0;

    Set<String> allWords = {...v1.keys, ...v2.keys};

    for (var word in allWords) {
      double val1 = v1[word] ?? 0;
      double val2 = v2[word] ?? 0;
      dotProduct += val1 * val2;
      mag1 += val1 * val1;
      mag2 += val2 * val2;
    }

    if (mag1 == 0 || mag2 == 0) return 0;
    return dotProduct / (sqrt(mag1) * sqrt(mag2));
  }

  static List<int> getRecommendations(int targetId, List<Book> allBooks, Map<int, Map<String, double>> matrix, {int k = 6}) {
    if (!matrix.containsKey(targetId)) return [];

    var targetVector = matrix[targetId]!;
    List<MapEntry<int, double>> scores = [];

    matrix.forEach((id, vector) {
      if (id != targetId) {
        scores.add(MapEntry(id, cosineSimilarity(targetVector, vector)));
      }
    });

    scores.sort((a, b) => b.value.compareTo(a.value));
    return scores.take(k).map((e) => e.key).toList();
  }
}
