import 'package:flutter/material.dart';
import '../models/book.dart';
import '../services/database_service.dart';
import 'home_screen.dart';

class CategoryScreen extends StatefulWidget {
  final String category;

  const CategoryScreen({super.key, required this.category});

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  List<Book> _books = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBooks();
  }

  Future<void> _loadBooks() async {
    final books = await DatabaseService.instance.getBooksByCategory(
      widget.category,
    );
    setState(() {
      _books = books;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('${widget.category} Books')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _books.isEmpty
          ? Center(child: Text('No books found in ${widget.category}.'))
          : GridView.builder(
              padding: const EdgeInsets.all(16.0),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 0.6,
                crossAxisSpacing: 16.0,
                mainAxisSpacing: 16.0,
              ),
              itemCount: _books.length,
              itemBuilder: (context, index) {
                return BookCard(book: _books[index]);
              },
            ),
    );
  }
}
