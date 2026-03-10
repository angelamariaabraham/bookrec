import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/app_state.dart';
import 'home_screen.dart'; // To use BookCard

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final theme = Theme.of(context);

    // Mock favorites from state for the UI
    final favorites = state.books.take(3).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Profile',
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24.0),
          children: [
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: theme.colorScheme.primary.withValues(
                      alpha: 0.15,
                    ),
                    child: Icon(
                      Icons.person_rounded,
                      size: 50,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    state.userName ?? 'Guest',
                    style: theme.textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.edit_outlined, size: 18),
                    label: const Text('Edit Profile'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: theme.colorScheme.primary,
                      side: BorderSide(
                        color: theme.colorScheme.primary.withValues(alpha: 0.5),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 48),

            // Reading Stats Overview
            _buildSectionTitle('Reading Stats', theme),
            const SizedBox(height: 16),
            _buildStatsRow(theme),
            const SizedBox(height: 32),

            // Reading Goals
            _buildSectionTitle('2026 Reading Goal', theme),
            const SizedBox(height: 16),
            _buildGoalsCard(theme),
            const SizedBox(height: 32),

            // Favorite Books / Top Shelf
            if (favorites.isNotEmpty) ...[
              _buildSectionTitle('Top Shelf', theme),
              const SizedBox(height: 16),
              SizedBox(
                height: 250,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: favorites.length,
                  itemBuilder: (context, index) {
                    return BookCard(book: favorites[index]);
                  },
                ),
              ),
              const SizedBox(height: 32),
            ] else ...[
              _buildSectionTitle('Top Shelf', theme),
              const SizedBox(height: 16),
              const Center(
                child: Text("Start reading to add shelf favorites!"),
              ),
              const SizedBox(height: 32),
            ],

            // Badges
            _buildSectionTitle('Badges & Achievements', theme),
            const SizedBox(height: 16),
            _buildBadgesRow(theme),
            const SizedBox(height: 48),

            Text(
              'Account',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Card(
              elevation: 0,
              color: theme.colorScheme.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(
                  color: theme.colorScheme.outline.withValues(alpha: 0.1),
                ),
              ),
              child: Column(
                children: [
                  ListTile(
                    leading: Icon(
                      Icons.settings_outlined,
                      color: theme.colorScheme.primary,
                    ),
                    title: const Text('Settings'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {},
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: Icon(
                      Icons.help_outline,
                      color: theme.colorScheme.primary,
                    ),
                    title: const Text('Help & Support'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {},
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.logout, color: Colors.red),
                    title: const Text(
                      'Logout',
                      style: TextStyle(color: Colors.red),
                    ),
                    onTap: () {
                      state.logout();
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        '/',
                        (route) => false,
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, ThemeData theme) {
    return Text(
      title,
      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
    );
  }

  Widget _buildStatsRow(ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildStatItem('Books Read', '24', Icons.menu_book_rounded, theme),
        _buildStatItem('Pages Read', '8.5k', Icons.auto_stories_rounded, theme),
        _buildStatItem(
          'Day Streak',
          '12',
          Icons.local_fire_department_rounded,
          theme,
        ),
      ],
    );
  }

  Widget _buildStatItem(
    String label,
    String value,
    IconData icon,
    ThemeData theme,
  ) {
    return Expanded(
      child: Card(
        elevation: 0,
        color: theme.colorScheme.primary.withValues(alpha: 0.1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
          child: Column(
            children: [
              Icon(icon, color: theme.colorScheme.primary),
              const SizedBox(height: 8),
              Text(
                value,
                style: GoogleFonts.outfit(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: theme.textTheme.labelSmall,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGoalsCard(ThemeData theme) {
    return Card(
      elevation: 0,
      color: theme.colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: theme.colorScheme.outline.withValues(alpha: 0.1),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '24 / 50 Books',
                  style: GoogleFonts.outfit(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                Text(
                  '48%',
                  style: GoogleFonts.outfit(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: 0.48,
                minHeight: 12,
                backgroundColor: theme.colorScheme.primary.withValues(
                  alpha: 0.2,
                ),
                valueColor: AlwaysStoppedAnimation<Color>(
                  theme.colorScheme.primary,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'You are 2 books ahead of schedule!',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.green[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBadgesRow(ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildBadgeItem(Icons.star_rounded, 'Early Bird', Colors.amber),
        _buildBadgeItem(Icons.menu_book_rounded, 'Bookworm', Colors.green),
        _buildBadgeItem(
          Icons.local_fire_department_rounded,
          'On Fire',
          Colors.orange,
        ),
        _buildBadgeItem(
          Icons.gamepad_rounded,
          'Player 1',
          theme.colorScheme.primary,
        ),
      ],
    );
  }

  Widget _buildBadgeItem(IconData icon, String label, Color color) {
    return Column(
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color.withValues(alpha: 0.15),
            border: Border.all(color: color.withValues(alpha: 0.5), width: 2),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.2),
                blurRadius: 10,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Icon(icon, size: 32, color: color),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color:
                Colors.black54, // Avoid theme depending error for text contrast
          ),
        ),
      ],
    );
  }
}
