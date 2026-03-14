import 'package:flutter/material.dart';
import '../models/book.dart';
import '../services/database_service.dart';
import '../services/recommender_service.dart';
import '../services/minigames_service.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_database/firebase_database.dart';
import 'dart:async';

class AppState with ChangeNotifier {
  List<Book> _books = [];
  List<Book> _featuredBooks = [];
  Map<int, Map<String, double>> _tfidfMatrix = {};
  bool _isLoading = true;
  bool _isLoggedIn = false;
  String? _userName;
  int _selectedTabIndex = 0;
  int _streakCount = 0;
  bool _isAdmin = false;
  DateTime? _lastActiveDate;
  int _yearlyReadingGoal = 50;

  final AuthService _auth = AuthService();
  final FirestoreService _firestore = FirestoreService();

  List<ShelfBookModel> _userShelf = [];
  StreamSubscription<List<ShelfBookModel>>? _shelfSubscription;
  StreamSubscription<DatabaseEvent>? _profileSubscription;
  StreamSubscription<Map<dynamic, dynamic>?>? _announcementSubscription;

  Map<dynamic, dynamic>? _currentAnnouncement;

  List<Book> get books => _books;
  List<Book> get featuredBooks => _featuredBooks;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _isLoggedIn;
  String? get userName => _userName;
  List<ShelfBookModel> get userShelf => _userShelf;
  int get selectedTabIndex => _selectedTabIndex;
  int get streakCount => _streakCount;
  bool get isAdmin => _isAdmin;
  int get yearlyReadingGoal => _yearlyReadingGoal;
  Map<dynamic, dynamic>? get currentAnnouncement => _currentAnnouncement;

  void setSelectedTabIndex(int index) {
    _selectedTabIndex = index;
    notifyListeners();
  }

  AppState() {
    _init();
  }

  Future<void> _init() async {
    _isLoggedIn = await _auth.isLoggedIn();
    _userName = await _auth.getUserName();

    if (_isLoggedIn) {
      final uid = _auth.getUserId();
      if (uid != null) {
        final profile = await _firestore.getUserProfile(uid);
        if (profile != null) {
          _isAdmin = profile.role == 'admin';
        }
      }
    }

    try {
      final prefs = await SharedPreferences.getInstance();

      // Load recent searches
      final savedSearches = prefs.getStringList('recentSearches');
      if (savedSearches != null) {
        for (var search in savedSearches) {
          if (!_recentSearches.contains(search)) {
            _recentSearches.add(search);
          }
        }
      }

      // Load streak and goal
      _streakCount = prefs.getInt('streakCount') ?? 0;
      _yearlyReadingGoal = prefs.getInt('yearlyReadingGoal') ?? 50;
      final lastActiveStr = prefs.getString('lastActiveDate');
      if (lastActiveStr != null) {
        _lastActiveDate = DateTime.parse(lastActiveStr);
      }

      _updateStreak();
    } catch (_) {}

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
      _setupProfileListener();
    }
    _setupAnnouncementListener();

    _isLoading = false;
    notifyListeners();
  }

  void _updateStreak() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    if (_lastActiveDate == null) {
      _streakCount = 1;
      _lastActiveDate = today;
    } else {
      final lastActive = DateTime(
        _lastActiveDate!.year,
        _lastActiveDate!.month,
        _lastActiveDate!.day,
      );
      final difference = today.difference(lastActive).inDays;

      if (difference == 1) {
        // Logged in on consecutive day
        _streakCount += 1;
        _lastActiveDate = today;
      } else if (difference > 1) {
        // Break in streak
        _streakCount = 1;
        _lastActiveDate = today;
      } else if (difference == 0) {
        // Already logged in today, no change
      }
    }

    // Save updated streak
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('streakCount', _streakCount);
      await prefs.setString(
        'lastActiveDate',
        _lastActiveDate!.toIso8601String(),
      );
    } catch (_) {}
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

      final uid = _auth.getUserId();
      if (uid != null) {
        UserModel? profile = await _firestore.getUserProfile(uid);
        if (profile == null) {
          // Create default profile for legacy users
          profile = UserModel(
            uid: uid,
            name: _userName ?? 'User',
            email: email,
            role: 'user',
          );
          await _firestore.saveUserProfile(profile);
        }
        _isAdmin = profile.role == 'admin';
      }

      _setupShelfListener();
      _setupProfileListener();
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
      _userName = name;

      final uid = _auth.getUserId();
      if (uid != null) {
        final profile = UserModel(
          uid: uid,
          name: name,
          email: email,
          role: 'user',
        );
        await _firestore.saveUserProfile(profile);
        _isAdmin = false;
      }

      _setupShelfListener();
      _setupProfileListener();
      notifyListeners();
    }
    return status;
  }

  Future<void> logout() async {
    await _auth.logout();
    _isLoggedIn = false;
    _userName = null;
    _isAdmin = false;
    _shelfSubscription?.cancel();
    _profileSubscription?.cancel();
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

  // --- Recent Searches ---
  final List<String> _recentSearches = [];
  List<String> get recentSearches => _recentSearches;

  Future<void> _saveRecentSearches() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList('recentSearches', _recentSearches);
    } catch (_) {}
  }

  void addRecentSearch(String query) {
    if (query.trim().isEmpty) return;

    final normalized = query.trim();
    // Remove if exists (case-insensitive) to append to front
    _recentSearches.removeWhere(
      (item) => item.toLowerCase() == normalized.toLowerCase(),
    );
    _recentSearches.insert(0, normalized);

    // Keep only top 5 recent searches
    if (_recentSearches.length > 5) {
      _recentSearches.removeLast();
    }

    _saveRecentSearches();
    notifyListeners();
  }

  void removeRecentSearch(String query) {
    _recentSearches.remove(query);
    _saveRecentSearches();
    notifyListeners();
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

  void _setupProfileListener() {
    final uid = _auth.getUserId();
    if (uid != null) {
      _profileSubscription?.cancel();
      _profileSubscription = FirebaseDatabase.instance
          .ref('users/$uid/profile')
          .onValue
          .listen((event) {
        if (event.snapshot.exists) {
          final data = event.snapshot.value as Map<dynamic, dynamic>;
          _isAdmin = data['role'] == 'admin';
          _userName = data['name'] ?? _userName;
          notifyListeners();
        }
      });
    }
  }

  Map<String, dynamic>? getCoverRevealGame() {
    return MinigamesService.generateCoverRevealGame(_books);
  }

  Map<String, dynamic>? getSentenceDecryptionGame() {
    return MinigamesService.generateSentenceDecryptionGame(_books);
  }

  Map<dynamic, dynamic>? getTimelineGame() {
    return MinigamesService.generateTimelineGame(_books);
  }

  void _setupAnnouncementListener() {
    _announcementSubscription?.cancel();
    _announcementSubscription = _firestore.getGlobalAnnouncement().listen((data) {
      _currentAnnouncement = data;
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _shelfSubscription?.cancel();
    _profileSubscription?.cancel();
    _announcementSubscription?.cancel();
    super.dispose();
  }
}
