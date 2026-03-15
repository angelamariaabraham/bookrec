import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/book.dart';

class DatabaseService {
  static final DatabaseService instance = DatabaseService._init();
  static Database? _database;
  List<Book>? _webBooks; // Cache for web memory storage

  DatabaseService._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('books.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 4,
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
  }

  Future _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 4) {
      // Drop the old table and recreate to re-seed from the fixed JSON
      await db.execute('DROP TABLE IF EXISTS books');
      await _createDB(db, newVersion);
    }
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE books (
        id INTEGER PRIMARY KEY,
        title TEXT NOT NULL,
        author TEXT,
        description TEXT,
        genres TEXT,
        rating TEXT,
        cover_image_url TEXT,
        publish_date TEXT,
        normalized_description TEXT,
        num_ratings INTEGER
      )
    ''');

    // Seed data from JSON
    await _seedData(db);
  }

  Future _seedData(Database db) async {
    final String response = await rootBundle.loadString(
      'assets/books_data.json',
    );
    final List<dynamic> data = json.decode(response);

    Batch batch = db.batch();
    for (var item in data) {
      batch.insert('books', item);
    }
    await batch.commit(noResult: true);
    debugPrint('Seeded ${data.length} books into database');
  }

  Future<List<Book>> getAllBooks() async {
    if (kIsWeb) {
      if (_webBooks != null) return _webBooks!;
      final String response = await rootBundle.loadString(
        'assets/books_data.json',
      );
      final List<dynamic> data = json.decode(response);
      _webBooks = data.map((json) => Book.fromJson(json)).toList();
      return _webBooks!;
    }
    final db = await instance.database;
    final result = await db.query('books');
    return result.map((json) => Book.fromJson(json)).toList();
  }

  Future<Book?> getBookById(int id) async {
    if (kIsWeb) {
      final books = await getAllBooks();
      try {
        return books.firstWhere((b) => b.id == id);
      } catch (_) {
        return null;
      }
    }
    final db = await instance.database;
    final maps = await db.query(
      'books',
      columns: ['*'],
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Book.fromJson(maps.first);
    } else {
      return null;
    }
  }

  Future<List<Book>> searchBooks(String query) async {
    if (kIsWeb) {
      final books = await getAllBooks();
      final lowercaseQuery = query.toLowerCase();
      return books
          .where(
            (b) =>
                (b.title.toLowerCase().contains(lowercaseQuery)) ||
                (b.author?.toLowerCase().contains(lowercaseQuery) ?? false),
          )
          .toList();
    }
    final db = await instance.database;
    final result = await db.query(
      'books',
      where: 'title LIKE ? OR author LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
    );
    return result.map((json) => Book.fromJson(json)).toList();
  }

  Future<List<Book>> getBooksByCategory(String category) async {
    if (category.toLowerCase() == 'all') {
      return getAllBooks();
    }

    if (category.toLowerCase() == 'all') {
      return getAllBooks();
    }

    String searchQuery = category;
    if (category.toLowerCase() == 'sci-fi') {
      searchQuery = 'Science Fiction';
    }

    if (kIsWeb) {
      final books = await getAllBooks();
      final lowercaseCategory = searchQuery.toLowerCase();
      return books
          .where(
            (b) =>
                (b.genres?.toLowerCase().contains(lowercaseCategory) ?? false),
          )
          .toList();
    }
    final db = await instance.database;
    final result = await db.query(
      'books',
      where: 'genres LIKE ?',
      whereArgs: ['%$searchQuery%'],
    );
    return result.map((json) => Book.fromJson(json)).toList();
  }
}
