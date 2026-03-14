import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/app_state.dart';
import '../../services/firestore_service.dart';
import '../../models/book.dart';

class UserActivityScreen extends StatelessWidget {
  final UserModel user;

  const UserActivityScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = context.watch<AppState>();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'User Activity',
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildUserHeader(user, theme),
            const SizedBox(height: 32),
            _buildSectionTitle('Shelf Activity', theme),
            const SizedBox(height: 16),
            StreamBuilder<List<ShelfBookModel>>(
              stream: FirestoreService().getUserShelf(user.uid),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                final shelf = snapshot.data!;
                if (shelf.isEmpty) return const Text('No books on shelf.');
                return _buildShelfList(shelf, state, theme);
              },
            ),
            const SizedBox(height: 32),
            _buildSectionTitle('Reviews', theme),
            const SizedBox(height: 16),
            StreamBuilder<List<ReviewModel>>(
              stream: FirestoreService().getReviewsForUser(user.uid),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                final reviews = snapshot.data!;
                if (reviews.isEmpty) return const Text('No reviews written.');
                return _buildReviewList(reviews, state, theme);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserHeader(UserModel user, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: theme.colorScheme.primary,
            child: Text(
              user.name[0].toUpperCase(),
              style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.name,
                  style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Text(user.email, style: TextStyle(color: Colors.grey[600])),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: user.role == 'admin' ? Colors.red.withValues(alpha: 0.1) : Colors.green.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              user.role.toUpperCase(),
              style: TextStyle(
                color: user.role == 'admin' ? Colors.red[700] : Colors.green[700],
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, ThemeData theme) {
    return Text(
      title,
      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
    );
  }

  Widget _buildShelfList(List<ShelfBookModel> shelf, AppState state, ThemeData theme) {
    return Column(
      children: shelf.map((item) {
        final book = state.books.firstWhere((b) => b.id == item.bookId, orElse: () => Book(id: item.bookId, title: 'Unknown Book', author: 'Unknown'));
        return ListTile(
          leading: Container(
            width: 40,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(4),
              image: book.coverImageUrl != null ? DecorationImage(image: NetworkImage(book.coverImageUrl!), fit: BoxFit.cover) : null,
            ),
          ),
          title: Text(book.title, style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text(item.status.replaceAll('_', ' ').toUpperCase()),
          trailing: Text(
            item.dateAdded.toString().split(' ')[0],
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildReviewList(List<ReviewModel> reviews, AppState state, ThemeData theme) {
    return Column(
      children: reviews.map((review) {
        final book = state.books.firstWhere((b) => b.id == review.bookId, orElse: () => Book(id: review.bookId, title: 'Unknown Book', author: 'Unknown'));
        return Card(
          elevation: 0,
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: theme.colorScheme.outline.withValues(alpha: 0.1)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        book.title,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Row(
                      children: List.generate(5, (index) {
                        return Icon(
                          index < review.rating ? Icons.star : Icons.star_border,
                          size: 16,
                          color: Colors.amber,
                        );
                      }),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(review.text),
                const SizedBox(height: 8),
                Text(
                  review.timestamp.toString().split('.')[0],
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
