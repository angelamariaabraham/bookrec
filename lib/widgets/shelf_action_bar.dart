import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/app_state.dart';

class ShelfActionBar extends StatefulWidget {
  final int bookId;

  const ShelfActionBar({super.key, required this.bookId});

  @override
  State<ShelfActionBar> createState() => _ShelfActionBarState();
}

class _ShelfActionBarState extends State<ShelfActionBar> {
  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required bool isSelected,
    required Color activeColor,
    required VoidCallback onTap,
  }) {
    final color = isSelected ? activeColor : Colors.grey[400];
    return Expanded(
      child: InkWell(
        onTap: onTap,
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 32, color: color),
              const SizedBox(height: 8),
              Text(
                label,
                style: GoogleFonts.inter(
                  color: color,
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    if (!state.isLoggedIn) {
      return const SizedBox.shrink(); // hide if not logged in
    }

    final shelfBook = state.getShelfBook(widget.bookId);
    final currentStatus = shelfBook?.status ?? 'none';
    final currentRating = shelfBook?.rating ?? 0.0;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: const Color(0xFF2C3440), // Letterboxd similar dark slate
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildActionButton(
                icon: currentStatus == 'read'
                    ? Icons.visibility
                    : Icons.visibility_outlined,
                label: 'Read',
                isSelected: currentStatus == 'read',
                activeColor: const Color(0xFF00E054), // Vibrant green
                onTap: () {
                  if (currentStatus == 'read') {
                    state.removeBookFromShelf(widget.bookId);
                  } else {
                    state.updateShelfStatus(
                      widget.bookId,
                      'read',
                      dateRead: DateTime.now(),
                    );
                  }
                },
              ),
              _buildActionButton(
                icon: currentStatus == 'currently_reading'
                    ? Icons.menu_book
                    : Icons.menu_book_outlined,
                label: 'Reading',
                isSelected: currentStatus == 'currently_reading',
                activeColor: Colors.orangeAccent,
                onTap: () {
                  if (currentStatus == 'currently_reading') {
                    state.removeBookFromShelf(widget.bookId);
                  } else {
                    state.updateShelfStatus(widget.bookId, 'currently_reading');
                  }
                },
              ),
              _buildActionButton(
                icon: currentStatus == 'want_to_read'
                    ? Icons.more_time
                    : Icons.schedule_outlined,
                label: 'Want to Read',
                isSelected: currentStatus == 'want_to_read',
                activeColor: Colors.blueAccent,
                onTap: () {
                  if (currentStatus == 'want_to_read') {
                    state.removeBookFromShelf(widget.bookId);
                  } else {
                    state.updateShelfStatus(widget.bookId, 'want_to_read');
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(color: Colors.white24, height: 1),
          const SizedBox(height: 12),
          Text(
            'Rate',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(color: Colors.grey[400], fontSize: 14),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) {
              final isFilled = index < currentRating;
              return InkWell(
                onTap: () {
                  final newRating = index + 1.0;
                  final ratingToSave = (currentRating == newRating)
                      ? 0.0
                      : newRating;

                  final statusToSave = currentStatus == 'none'
                      ? 'read'
                      : currentStatus;
                  final dateToSave = currentStatus == 'none'
                      ? DateTime.now()
                      : null;

                  state.updateShelfStatus(
                    widget.bookId,
                    statusToSave,
                    rating: ratingToSave,
                    dateRead: dateToSave,
                  );
                },
                customBorder: const CircleBorder(),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Icon(
                    isFilled ? Icons.star : Icons.star_border,
                    color: isFilled
                        ? const Color(0xFF00E054)
                        : Colors.grey[600],
                    size: 36,
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
