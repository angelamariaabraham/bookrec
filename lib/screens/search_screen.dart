import 'package:flutter/material.dart';
import '../models/book.dart';
import '../services/database_service.dart';
import 'home_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _searchController = TextEditingController();
  List<Book> _searchResults = [];
  bool _isSearching = false;

  void _onSearchChanged(String query) async {
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      return;
    }

    setState(() => _isSearching = true);
    final results = await DatabaseService.instance.searchBooks(query);
    setState(() {
      _searchResults = results;
      _isSearching = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Search by title or author...',
            border: InputBorder.none,
          ),
          onChanged: _onSearchChanged,
        ),
      ),
      body: _isSearching
          ? const Center(child: CircularProgressIndicator())
          : _searchResults.isEmpty && _searchController.text.isNotEmpty
          ? const Center(child: Text('No books found.'))
          : ListView.builder(
              itemCount: _searchResults.length,
              itemBuilder: (context, index) {
                return BookListTile(book: _searchResults[index]);
              },
            ),
    );
  }
}
