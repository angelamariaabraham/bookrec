import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/app_state.dart';
import '../models/book.dart';
import 'book_details_screen.dart';
import 'category_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ScrollController _featuredScrollController = ScrollController();

  @override
  void dispose() {
    _featuredScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final theme = Theme.of(context);
    final featuredBooks = state.featuredBooks;
    final announcement = state.currentAnnouncement;

    return Scaffold(
      drawer: const AppDrawer(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.pushNamed(context, '/minigames'),
        icon: const Icon(Icons.gamepad_rounded),
        label: const Text('Minigames'),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Column(
          children: [
            if (announcement != null)
              AnnouncementBanner(
                key: ValueKey(announcement['timestamp'] ?? announcement['text']),
                text: announcement['text'] ?? '',
                type: announcement['type'] ?? 'info',
                timestamp: announcement['timestamp'] as int? ?? 0,
              ),
            Expanded(
              child: CustomScrollView(
                slivers: [
                  SliverAppBar(
                    backgroundColor: theme.scaffoldBackgroundColor,
                    elevation: 0,
                    pinned: true,
                    centerTitle: false,
                    title: Text(
                      'BookFusion',
                      style: GoogleFonts.outfit(
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    iconTheme: IconThemeData(color: theme.colorScheme.onSurface),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24.0,
                        vertical: 8.0,
                      ),
                      child: TextField(
                        readOnly: true,
                        onTap: () {
                          FocusScope.of(context).unfocus();
                          Navigator.pushNamed(context, '/search');
                        },
                        decoration: const InputDecoration(
                          hintText: 'Search books, authors...',
                          prefixIcon: Icon(Icons.search_rounded),
                          suffixIcon: Icon(Icons.tune_rounded),
                        ),
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.only(
                        top: 24.0,
                        left: 24.0,
                        bottom: 8.0,
                      ),
                      child: Text('Explore', style: theme.textTheme.titleLarge),
                    ),
                  ),
                  const SliverToBoxAdapter(child: CategoryRow()),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.only(
                        top: 32.0,
                        left: 24.0,
                        bottom: 16.0,
                      ),
                      child: Text(
                        'Hidden Gems & Classics',
                        style: theme.textTheme.titleLarge,
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: SizedBox(
                      height: 335,
                      child: Scrollbar(
                        controller: _featuredScrollController,
                        thumbVisibility: true,
                        thickness: 4,
                        radius: const Radius.circular(8),
                        child: ListView.builder(
                          controller: _featuredScrollController,
                          padding: const EdgeInsets.only(
                            left: 16.0,
                            right: 16.0,
                            bottom: 12.0,
                          ),
                          scrollDirection: Axis.horizontal,
                          physics: const BouncingScrollPhysics(),
                          itemCount: featuredBooks.take(30).length,
                          itemBuilder: (context, index) {
                            final book = featuredBooks[index];
                            return BookCard(book: book);
                          },
                        ),
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.only(
                        top: 32.0,
                        left: 24.0,
                        bottom: 16.0,
                      ),
                      child: Text(
                        'Curated For You',
                        style: theme.textTheme.titleLarge,
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    sliver: SliverGrid(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 6,
                        childAspectRatio: 0.5,
                        crossAxisSpacing: 10.0,
                        mainAxisSpacing: 16.0,
                      ),
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final book = state.books.length > index + 10 
                          ? state.books[index + 10] 
                          : state.books[index % state.books.length];
                        return BookCard(book: book);
                      }, childCount: 18),
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 100)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class BookCard extends StatelessWidget {
  final Book book;
  final VoidCallback? onTap;

  const BookCard({super.key, required this.book, this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: 160,
      margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
      child: InkWell(
        onTap: () {
          if (onTap != null) {
            onTap!();
          }
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => BookDetailsScreen(book: book),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Hero(
                tag: 'book-${book.id}',
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    image: DecorationImage(
                      image: NetworkImage(
                        book.coverImageUrl ?? 'https://via.placeholder.com/150',
                      ),
                      fit: BoxFit.cover,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: theme.brightness == Brightness.light
                            ? Colors.black.withValues(alpha: 0.15)
                            : Colors.black.withValues(alpha: 0.4),
                        blurRadius: 15,
                        spreadRadius: 2,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              book.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.titleMedium?.copyWith(height: 1.2),
            ),
            const SizedBox(height: 4),
            Text(
              book.author ?? 'Unknown Author',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CategoryRow extends StatefulWidget {
  const CategoryRow({super.key});

  @override
  State<CategoryRow> createState() => _CategoryRowState();
}

class _CategoryRowState extends State<CategoryRow> {
  final ScrollController _categoryScrollController = ScrollController();

  @override
  void dispose() {
    _categoryScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final categories = [
      {
        'icon': Icons.library_books_rounded,
        'label': 'All',
        'color': Colors.blueGrey,
      },
      {
        'icon': Icons.menu_book_rounded,
        'label': 'Fiction',
        'color': Colors.indigoAccent,
      },
      {
        'icon': Icons.search_rounded,
        'label': 'Mystery',
        'color': Colors.tealAccent,
      },
      {
        'icon': Icons.favorite_rounded,
        'label': 'Romance',
        'color': Colors.pinkAccent,
      },
      {
        'icon': Icons.visibility_rounded,
        'label': 'Thriller',
        'color': Colors.orangeAccent,
      },
    ];

    return SizedBox(
      height: 135, // Increased slightly for scrollbar
      child: Scrollbar(
        controller: _categoryScrollController,
        thumbVisibility: true,
        thickness: 4,
        radius: const Radius.circular(8),
        child: ListView.builder(
          controller: _categoryScrollController,
          padding: const EdgeInsets.only(
            left: 24.0,
            right: 24.0,
            bottom: 12.0, // Space for scrollbar
          ),
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          itemCount: categories.length,
          itemBuilder: (context, index) {
            final cat = categories[index];
            final color = cat['color'] as Color;
            final icon = cat['icon'] as IconData;
            final label = cat['label'] as String;

            return Padding(
              padding: const EdgeInsets.only(right: 16),
              child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CategoryScreen(category: label),
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(24),
                child: Container(
                  width: 140,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [color.withValues(alpha: 0.8), color],
                    ),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: color.withValues(alpha: 0.3),
                        blurRadius: 12,
                        spreadRadius: 1,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        right: -10,
                        bottom: -10,
                        child: Icon(
                          icon,
                          size: 80,
                          color: Colors.white.withValues(alpha: 0.15),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(icon, size: 20, color: Colors.white),
                            ),
                            Text(
                              label,
                              style: GoogleFonts.outfit(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    return Drawer(
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
            ),
            accountName: Text(
              state.userName ?? 'Guest',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            accountEmail: null,
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white.withValues(alpha: 0.2),
              child: const Icon(
                Icons.person_rounded,
                size: 40,
                color: Colors.white,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home_rounded),
            title: const Text(
              'Home',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            leading: const Icon(Icons.search_rounded),
            title: const Text(
              'Search',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            onTap: () => Navigator.pushNamed(context, '/search'),
          ),
          ListTile(
            leading: const Icon(Icons.book_rounded),
            title: const Text(
              'My Shelf',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            onTap: () => Navigator.pushNamed(context, '/shelf'),
          ),
          ListTile(
            leading: const Icon(Icons.gamepad_rounded),
            title: const Text(
              'Minigames',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            onTap: () => Navigator.pushNamed(context, '/minigames'),
          ),
          const Spacer(),
          ListTile(
            leading: const Icon(Icons.logout_rounded, color: Colors.red),
            title: const Text(
              'Logout',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
            onTap: () {
              state.logout();
              Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
            },
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class AnnouncementBanner extends StatefulWidget {
  final String text;
  final String type;
  final int timestamp;

  const AnnouncementBanner({
    super.key,
    required this.text,
    required this.type,
    required this.timestamp,
  });

  @override
  State<AnnouncementBanner> createState() => _AnnouncementBannerState();
}

class _AnnouncementBannerState extends State<AnnouncementBanner> {
  bool _isDismissed = false;

  @override
  Widget build(BuildContext context) {
    if (_isDismissed) return const SizedBox.shrink();

    Color color;
    IconData icon;

    switch (widget.type) {
      case 'warning':
        color = Colors.orange;
        icon = Icons.warning_amber_rounded;
        break;
      case 'alert':
        color = Colors.redAccent;
        icon = Icons.error_outline_rounded;
        break;
      default:
        color = Colors.blueAccent;
        icon = Icons.info_outline_rounded;
    }

    return Container(
      margin: const EdgeInsets.fromLTRB(24, 8, 24, 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              widget.text,
              style: GoogleFonts.outfit(
                color: color.withValues(alpha: 0.9),
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.close_rounded, color: color, size: 18),
            onPressed: () {
              setState(() => _isDismissed = true);
              context.read<AppState>().dismissAnnouncement(widget.timestamp);
            },
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            tooltip: 'Dismiss',
          ),
        ],
      ),
    );
  }
}
