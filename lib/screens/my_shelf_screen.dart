import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import 'home_screen.dart'; // for BookListTile

class MyShelfScreen extends StatelessWidget {
  const MyShelfScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('My Shelf'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Read'),
              Tab(text: 'Reading'),
              Tab(text: 'Want to Read'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _ShelfList(status: 'read'),
            _ShelfList(status: 'currently_reading'),
            _ShelfList(status: 'want_to_read'),
          ],
        ),
      ),
    );
  }
}

class _ShelfList extends StatelessWidget {
  final String status;

  const _ShelfList({required this.status});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();

    if (!state.isLoggedIn) {
      return const Center(child: Text('Please log in to view your shelf.'));
    }

    // Filter user's shelf by status
    final shelfBooks = state.userShelf
        .where((b) => b.status == status)
        .toList();

    if (shelfBooks.isEmpty) {
      return Center(
        child: Text(
          'No books in this shelf.',
          style: TextStyle(color: Colors.grey[400]),
        ),
      );
    }

    return ListView.builder(
      itemCount: shelfBooks.length,
      itemBuilder: (context, index) {
        final shelfEntry = shelfBooks[index];
        // find full book data
        final book = state.books.firstWhere(
          (b) => b.id == shelfEntry.bookId,
          // fallback if somehow missing
          orElse: () => state.books.first,
        );

        return BookListTile(book: book);
      },
    );
  }
}
