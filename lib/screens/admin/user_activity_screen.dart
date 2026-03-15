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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'User Activity',
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildUserHeader(user, theme),
            const SizedBox(height: 40),
            _buildSectionHeader('Shelf Status', Icons.auto_stories_rounded, theme),
            const SizedBox(height: 16),
            StreamBuilder<List<ShelfBookModel>>(
              stream: FirestoreService().getUserShelf(user.uid),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                final shelf = snapshot.data!;
                if (shelf.isEmpty) return _buildEmptyState('No books on shelf', theme);
                return _buildShelfList(shelf, state, theme);
              },
            ),
            const SizedBox(height: 40),
            _buildSectionHeader('Community Reviews', Icons.rate_review_rounded, theme),
            const SizedBox(height: 16),
            StreamBuilder<List<ReviewModel>>(
              stream: FirestoreService().getReviewsForUser(user.uid),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                final reviews = snapshot.data!;
                if (reviews.isEmpty) return _buildEmptyState('No reviews written yet', theme);
                return _buildReviewList(reviews, state, theme, context);
              },
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildUserHeader(UserModel user, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primary.withValues(alpha: 0.1),
            theme.colorScheme.primary.withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.1),
        ),
      ),
      child: Row(
        children: [
          Hero(
            tag: 'user_avatar_${user.uid}',
            child: CircleAvatar(
              radius: 35,
              backgroundColor: theme.colorScheme.primary,
              child: Text(
                user.displayName.isNotEmpty ? user.displayName[0].toUpperCase() : 'U',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.displayName,
                  style: GoogleFonts.outfit(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                Text(
                  user.email,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: user.role == 'admin'
                        ? Colors.redAccent.withValues(alpha: 0.1)
                        : theme.colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    user.role.toUpperCase(),
                    style: TextStyle(
                      color: user.role == 'admin' ? Colors.redAccent : theme.colorScheme.primary,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, ThemeData theme) {
    return Row(
      children: [
        Icon(icon, size: 20, color: theme.colorScheme.primary),
        const SizedBox(width: 10),
        Text(
          title,
          style: GoogleFonts.outfit(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(String message, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Text(
        message,
        style: TextStyle(
          color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
          fontStyle: FontStyle.italic,
        ),
      ),
    );
  }

  Widget _buildShelfList(List<ShelfBookModel> shelf, AppState state, ThemeData theme) {
    return Column(
      children: shelf.map((item) {
        final book = state.books.firstWhere(
          (b) => b.id == item.bookId,
          orElse: () => Book(id: item.bookId, title: 'Unknown Book', author: 'Unknown'),
        );
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: theme.colorScheme.outline.withValues(alpha: 0.05),
            ),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.all(12),
            leading: Container(
              width: 50,
              height: 75,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
                image: book.coverImageUrl != null
                    ? DecorationImage(
                        image: NetworkImage(book.coverImageUrl!),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: book.coverImageUrl == null
                  ? const Icon(Icons.book_rounded, color: Colors.grey)
                  : null,
            ),
            title: Text(
              book.title,
              style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(
                  item.status.replaceAll('_', ' ').toUpperCase(),
                  style: TextStyle(
                    color: theme.colorScheme.primary,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  'Added ${item.dateAdded.toString().split(' ')[0]}',
                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildReviewList(List<ReviewModel> reviews, AppState state, ThemeData theme, BuildContext context) {
    return Column(
      children: reviews.map((review) {
        final book = state.books.firstWhere(
          (b) => b.id == review.bookId,
          orElse: () => Book(id: review.bookId, title: 'Unknown Book', author: 'Unknown'),
        );
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: theme.colorScheme.primary.withValues(alpha: 0.05),
            ),
            boxShadow: [
              BoxShadow(
                color: theme.colorScheme.primary.withValues(alpha: 0.03),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          book.title,
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: List.generate(5, (index) {
                            return Icon(
                              index < review.rating ? Icons.star_rounded : Icons.star_outline_rounded,
                              size: 18,
                              color: Colors.amber,
                            );
                          }),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.delete_sweep_rounded, color: Colors.red[300], size: 22),
                    onPressed: () => _confirmDeleteReview(context, review.id, book.title),
                    tooltip: 'Moderate Review',
                    constraints: const BoxConstraints(),
                    padding: EdgeInsets.zero,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                review.text,
                style: theme.textTheme.bodyMedium?.copyWith(
                  height: 1.5,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Posted on ${review.timestamp.toString().split('.')[0]}',
                style: const TextStyle(fontSize: 11, color: Colors.grey),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  void _confirmDeleteReview(BuildContext context, String reviewId, String bookTitle) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Moderate Review'),
        content: Text('Are you sure you want to remove this review for "$bookTitle"? This action is permanent.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              await FirestoreService().deleteReview(reviewId);
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Review removed successfully')),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
