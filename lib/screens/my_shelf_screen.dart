import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/app_state.dart';
import 'home_screen.dart';

class MyShelfScreen extends StatelessWidget {
  const MyShelfScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: theme.colorScheme.surface,
        body: Stack(
          children: [
            // Background ambient glow
            Positioned(
              top: -100,
              right: -100,
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: theme.colorScheme.primary.withValues(alpha: 0.05),
                ),
              ),
            ),
            SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Custom Header
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 24, 8),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back_rounded),
                          onPressed: () {
                            if (Navigator.canPop(context)) {
                              Navigator.pop(context);
                            } else {
                              context.read<AppState>().setSelectedTabIndex(0);
                            }
                          },
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'My Shelf',
                          style: GoogleFonts.outfit(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Custom Glassmorphic TabBar
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Container(
                      height: 50,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(25),
                        border: Border.all(
                          color: theme.colorScheme.primary.withValues(alpha: 0.1),
                        ),
                      ),
                      child: TabBar(
                        dividerColor: Colors.transparent,
                        indicatorSize: TabBarIndicatorSize.tab,
                        indicator: BoxDecoration(
                          borderRadius: BorderRadius.circular(25),
                          color: theme.colorScheme.primary,
                          boxShadow: [
                            BoxShadow(
                              color: theme.colorScheme.primary.withValues(alpha: 0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        labelColor: theme.colorScheme.onPrimary,
                        unselectedLabelColor: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                        labelStyle: GoogleFonts.inter(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                        tabs: const [
                          Tab(text: 'Read'),
                          Tab(text: 'Reading'),
                          Tab(text: 'Want to Read'),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Content
                  const Expanded(
                    child: TabBarView(
                      children: [
                        _ShelfList(status: 'read'),
                        _ShelfList(status: 'currently_reading'),
                        _ShelfList(status: 'want_to_read'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
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
    final theme = Theme.of(context);

    if (!state.isLoggedIn) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.lock_outline_rounded, size: 64, color: theme.colorScheme.primary.withValues(alpha: 0.2)),
            const SizedBox(height: 16),
            Text(
              'Please log in to view your shelf',
              style: GoogleFonts.inter(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            ),
          ],
        ),
      );
    }

    final shelfBooks = state.userShelf
        .where((b) => b.status == status)
        .toList();

    if (shelfBooks.isEmpty) {
      String message;
      IconData icon;
      switch (status) {
        case 'read':
          message = 'You haven\'t finished any books yet.';
          icon = Icons.auto_stories_rounded;
          break;
        case 'currently_reading':
          message = 'Nothing in your current reading list.';
          icon = Icons.menu_book_rounded;
          break;
        default:
          message = 'Your "Want to Read" list is empty.';
          icon = Icons.bookmark_add_rounded;
      }

      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 80,
              color: theme.colorScheme.primary.withValues(alpha: 0.1),
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 16,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => context.read<AppState>().setSelectedTabIndex(0),
              icon: const Icon(Icons.explore_rounded),
              label: const Text('Discover Books'),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
                foregroundColor: theme.colorScheme.primary,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 5,
        childAspectRatio: 0.52,
        crossAxisSpacing: 12.0,
        mainAxisSpacing: 20.0,
      ),
      itemCount: shelfBooks.length,
      itemBuilder: (context, index) {
        final shelfEntry = shelfBooks[index];
        final book = state.books.firstWhere(
          (b) => b.id == shelfEntry.bookId,
          orElse: () => state.books.first,
        );

        return BookCard(book: book);
      },
    );
  }
}
