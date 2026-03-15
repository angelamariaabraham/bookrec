import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/book.dart';
import '../providers/app_state.dart';
import '../services/database_service.dart';
import 'home_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _searchController = TextEditingController();
  final _focusNode = FocusNode();
  List<Book> _searchResults = [];
  bool _isSearching = false;

  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      if (!_focusNode.hasFocus) {
        final query = _searchController.text.trim();
        if (query.isNotEmpty) {
          context.read<AppState>().addRecentSearch(query);
        }
      }
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _focusNode.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      return;
    }

    setState(() => _isSearching = true);

    _debounce = Timer(const Duration(milliseconds: 300), () async {
      final results = await DatabaseService.instance.searchBooks(query.trim());
      if (!mounted) return;

      setState(() {
        _searchResults = results;
        _isSearching = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Custom App Bar Area
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_rounded),
                    onPressed: () {
                      // Save current unsubmitted search before we leave
                      final query = _searchController.text.trim();
                      if (query.isNotEmpty) {
                        context.read<AppState>().addRecentSearch(query);
                      }

                      if (Navigator.canPop(context)) {
                        Navigator.pop(context);
                      } else {
                        context.read<AppState>().setSelectedTabIndex(0);
                      }
                    },
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Search',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),

            // Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 12.0,
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                    color: theme.colorScheme.primary.withValues(alpha: 0.2),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: theme.colorScheme.primary.withValues(alpha: 0.05),
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                clipBehavior: Clip.antiAlias,
                child: TextField(
                  controller: _searchController,
                  focusNode: _focusNode,
                  autofocus: false,
                  textInputAction: TextInputAction.search,
                  onChanged: _onSearchChanged,
                  onSubmitted: (query) {
                    if (query.isNotEmpty && !mounted) return;
                    context.read<AppState>().addRecentSearch(query);
                    _onSearchChanged(query);
                  },
                  decoration: InputDecoration(
                    hintText: 'Search books, authors, genres...',
                    hintStyle: TextStyle(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                      fontSize: 15,
                    ),
                    prefixIcon: Container(
                      padding: const EdgeInsets.all(12),
                      child: Icon(
                        Icons.search_rounded,
                        color: theme.colorScheme.primary,
                        size: 22,
                      ),
                    ),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.close_rounded, size: 20),
                            color: theme.colorScheme.onSurface.withValues(
                              alpha: 0.4,
                            ),
                            onPressed: () {
                              _searchController.clear();
                              _onSearchChanged('');
                            },
                          )
                        : null,
                    border: InputBorder.none,
                    filled: true,
                    fillColor: theme.colorScheme.surface.withValues(alpha: 0.5),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                  ),
                ),
              ),
            ),

            // Content Area
            Expanded(
              child: _isSearching
                  ? const Center(child: CircularProgressIndicator())
                  : _searchController.text.isEmpty
                  ? _buildEmptySearchState(theme)
                  : _searchResults.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.search_off_rounded,
                            size: 64,
                            color: theme.colorScheme.onSurface.withValues(
                              alpha: 0.2,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No books found',
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: theme.colorScheme.onSurface.withValues(
                                alpha: 0.6,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  : GridView.builder(
                      padding: const EdgeInsets.all(24.0),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 4,
                            childAspectRatio: 0.55,
                            crossAxisSpacing: 12.0,
                            mainAxisSpacing: 24.0,
                          ),
                      itemCount: _searchResults.length,
                      itemBuilder: (context, index) {
                        return BookCard(
                          book: _searchResults[index],
                          onTap: () {
                            final query = _searchController.text;
                            if (query.isNotEmpty) {
                              context.read<AppState>().addRecentSearch(query);
                            }
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  // Exploratory initial state when not searching
  Widget _buildEmptySearchState(ThemeData theme) {
    final recentSearches = context.watch<AppState>().recentSearches;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recent Searches',
                style: GoogleFonts.outfit(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              if (recentSearches.isNotEmpty)
                TextButton.icon(
                  onPressed: () => context.read<AppState>().clearRecentSearches(),
                  icon: const Icon(Icons.delete_sweep_rounded, size: 18),
                  label: const Text('Clear All'),
                  style: TextButton.styleFrom(
                    foregroundColor: theme.colorScheme.primary,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          if (recentSearches.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 60),
                child: Column(
                  children: [
                    Icon(
                      Icons.search_rounded,
                      size: 80,
                      color: theme.colorScheme.primary.withValues(alpha: 0.1),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Search for your next favorite book',
                      style: GoogleFonts.inter(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            Column(
              children: recentSearches
                  .map((query) => _buildRecentSearchItem(query, theme))
                  .toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildRecentSearchItem(String query, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        onTap: () {
          _searchController.text = query;
          _onSearchChanged(query);
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: theme.colorScheme.outline.withValues(alpha: 0.05),
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.05),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.history_rounded,
                  size: 18,
                  color: theme.colorScheme.primary.withValues(alpha: 0.6),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  query,
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded, size: 18),
                onPressed: () {
                  context.read<AppState>().removeRecentSearch(query);
                },
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
              ),
            ],
          ),
        ),
      ),
    );
  }


}
