import 'package:firebase_database/firebase_database.dart';

class ReviewModel {
  final String id;
  final int bookId;
  final String uid;
  final String userName;
  final double rating;
  final String text;
  final DateTime timestamp;

  ReviewModel({
    required this.id,
    required this.bookId,
    required this.uid,
    required this.userName,
    required this.rating,
    required this.text,
    required this.timestamp,
  });

  factory ReviewModel.fromMap(String id, Map<dynamic, dynamic> data) {
    return ReviewModel(
      id: id,
      bookId: data['bookId'] ?? 0,
      uid: data['uid'] ?? '',
      userName: data['userName'] ?? 'Anonymous',
      rating: (data['rating'] ?? 0).toDouble(),
      text: data['text'] ?? '',
      timestamp: data['timestamp'] != null
          ? DateTime.fromMillisecondsSinceEpoch(data['timestamp'] as int)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'bookId': bookId,
      'uid': uid,
      'userName': userName,
      'rating': rating,
      'text': text,
      'timestamp': timestamp.millisecondsSinceEpoch,
    };
  }
}

class ShelfBookModel {
  final int bookId;
  final String status; // 'read', 'want_to_read', 'currently_reading'
  final DateTime dateAdded;
  final DateTime? dateRead;
  final double? rating;

  ShelfBookModel({
    required this.bookId,
    required this.status,
    required this.dateAdded,
    this.dateRead,
    this.rating,
  });

  factory ShelfBookModel.fromMap(int bookId, Map<dynamic, dynamic> data) {
    return ShelfBookModel(
      bookId: bookId,
      status: data['status'] ?? 'want_to_read',
      dateAdded: data['dateAdded'] != null
          ? DateTime.fromMillisecondsSinceEpoch(data['dateAdded'] as int)
          : DateTime.now(),
      dateRead: data['dateRead'] != null
          ? DateTime.fromMillisecondsSinceEpoch(data['dateRead'] as int)
          : null,
      rating: data['rating'] != null
          ? (data['rating'] as num).toDouble()
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'bookId': bookId,
      'status': status,
      'dateAdded': dateAdded.millisecondsSinceEpoch,
    };
    if (dateRead != null) map['dateRead'] = dateRead!.millisecondsSinceEpoch;
    if (rating != null) map['rating'] = rating;
    return map;
  }
}

// Named FirestoreService so we don't have to break imports, but it uses RTDB!
class FirestoreService {
  final FirebaseDatabase _db = FirebaseDatabase.instance;

  // --- REVIEWS ---

  Future<void> addReview({
    required int bookId,
    required String uid,
    required String userName,
    required double rating,
    required String text,
  }) async {
    final ref = _db.ref('reviews').push();
    final review = ReviewModel(
      id: ref.key ?? '',
      bookId: bookId,
      uid: uid,
      userName: userName,
      rating: rating,
      text: text,
      timestamp: DateTime.now(),
    );
    await ref.set(review.toMap());
  }

  Stream<List<ReviewModel>> getReviewsForBook(int bookId) {
    return _db.ref('reviews').orderByChild('bookId').equalTo(bookId).onValue.map((
      event,
    ) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;
      if (data == null) return [];

      final reviews = data.entries.map((e) {
        return ReviewModel.fromMap(
          e.key.toString(),
          e.value as Map<dynamic, dynamic>,
        );
      }).toList();

      // Realtime Database doesn't strictly sort in descending order via queries
      // so we sort it locally to have newest first.
      reviews.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      return reviews;
    });
  }

  // --- SHELVES ---

  Future<void> updateShelf({
    required String uid,
    required int bookId,
    required String status,
    DateTime? dateRead,
    double? rating,
  }) async {
    final ref = _db.ref('users/$uid/shelf/$bookId');
    final snapshot = await ref.get();

    if (snapshot.exists) {
      // Update existing
      Map<String, dynamic> updates = {'status': status};
      if (dateRead != null) {
        updates['dateRead'] = dateRead.millisecondsSinceEpoch;
      }
      if (rating != null) {
        updates['rating'] = rating;
      }
      await ref.update(updates);
    } else {
      // Create new
      final model = ShelfBookModel(
        bookId: bookId,
        status: status,
        dateAdded: DateTime.now(),
        dateRead: dateRead,
        rating: rating,
      );
      await ref.set(model.toMap());
    }
  }

  Future<void> removeBookFromShelf(String uid, int bookId) async {
    await _db.ref('users/$uid/shelf/$bookId').remove();
  }

  Stream<List<ShelfBookModel>> getUserShelf(String uid) {
    return _db.ref('users/$uid/shelf').onValue.map((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;
      if (data == null) return [];

      return data.entries.map((e) {
        return ShelfBookModel.fromMap(
          int.parse(e.key.toString()),
          e.value as Map<dynamic, dynamic>,
        );
      }).toList();
    });
  }
}
