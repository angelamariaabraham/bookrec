import 'package:flutter/material.dart';
import '../models/book.dart';
import '../services/database_service.dart';
import '../services/recommender_service.dart';
import '../services/minigames_service.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import 'dart:async';

class AppState with ChangeNotifier {
  List<Book> _books = [];
  List<Book> _featuredBooks = [];
  Map<int, Map<String, double>> _tfidfMatrix = {};
  bool _isLoading = true;
  bool _isLoggedIn = false;
  String? _userName;

  final AuthService _auth = AuthService();
  final FirestoreService _firestore = FirestoreService();

  List<ShelfBookModel> _userShelf = [];
  StreamSubscription<List<ShelfBookModel>>? _shelfSubscription;

  List<Book> get books => _books;
  List<Book> get featuredBooks => _featuredBooks;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _isLoggedIn;
  String? get userName => _userName;
  List<ShelfBookModel> get userShelf => _userShelf;

  AppState() {
    _init();
  }

  Future<void> _init() async {
    _isLoggedIn = await _auth.isLoggedIn();
    _userName = await _auth.getUserName();

    _books = await DatabaseService.instance.getAllBooks();
    if (_books.isNotEmpty) {
      _tfidfMatrix = RecommenderService.computeTfIdf(_books);
      _featuredBooks = _books.where((b) {
        double r = double.tryParse(b.rating ?? '0') ?? 0;
        return r > 4.5;
      }).toList()..shuffle();
    }

    if (_isLoggedIn) {
      _setupShelfListener();
    }

    _isLoading = false;
    notifyListeners();
  }

  void _setupShelfListener() {
    final uid = _auth.getUserId();
    if (uid != null) {
      _shelfSubscription?.cancel();
      _shelfSubscription = _firestore.getUserShelf(uid).listen((shelf) {
        _userShelf = shelf;
        notifyListeners();
      });
    }
  }

  Future<AuthStatus> login(String email, String password) async {
    AuthStatus status = await _auth.login(email, password);
    if (status == AuthStatus.success) {
      _isLoggedIn = true;
      _userName = await _auth.getUserName();
      _setupShelfListener();
      notifyListeners();
    }
    return status;
  }

  Future<AuthStatus> register(
    String name,
    String email,
    String password,
  ) async {
    AuthStatus status = await _auth.register(name, email, password);
    if (status == AuthStatus.success) {
      _isLoggedIn = true;
      _userName = await _auth.getUserName();
      _setupShelfListener();
      notifyListeners();
    }
    return status;
  }

  Future<void> logout() async {
    await _auth.logout();
    _isLoggedIn = false;
    _userName = null;
    _shelfSubscription?.cancel();
    _userShelf.clear();
    notifyListeners();
  }

  List<Book> getRecommendations(int bookId) {
    List<int> ids = RecommenderService.getRecommendations(
      bookId,
      _books,
      _tfidfMatrix,
    );
    return _books.where((b) => ids.contains(b.id)).toList();
  }

  // --- Firestore Data Exposure ---

  ShelfBookModel? getShelfBook(int bookId) {
    try {
      return _userShelf.firstWhere((b) => b.bookId == bookId);
    } catch (_) {
      return null;
    }
  }

  Future<void> updateShelfStatus(
    int bookId,
    String status, {
    DateTime? dateRead,
    double? rating,
  }) async {
    final uid = _auth.getUserId();
    if (uid == null) return;
    await _firestore.updateShelf(
      uid: uid,
      bookId: bookId,
      status: status,
      dateRead: dateRead,
      rating: rating,
    );
  }

  Future<void> removeBookFromShelf(int bookId) async {
    final uid = _auth.getUserId();
    if (uid == null) return;
    await _firestore.removeBookFromShelf(uid, bookId);
  }

  Future<void> addReview(int bookId, double rating, String text) async {
    final uid = _auth.getUserId();
    final name = _userName ?? 'Anonymous';
    if (uid == null) return;
    await _firestore.addReview(
      bookId: bookId,
      uid: uid,
      userName: name,
      rating: rating,
      text: text,
    );
  }

  Stream<List<ReviewModel>> getBookReviews(int bookId) {
    return _firestore.getReviewsForBook(bookId);
  }

  Map<String, dynamic>? getCoverRevealGame() {
    return MinigamesService.generateCoverRevealGame(_books);
  }

  Map<String, dynamic>? getSentenceDecryptionGame() {
    return MinigamesService.generateSentenceDecryptionGame(_books);
  }

  Map<String, dynamic>? getTimelineGame() {
    return MinigamesService.generateTimelineGame(_books);
  }
}
