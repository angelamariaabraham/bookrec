import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/app_state.dart';
import 'home_screen.dart'; // To use BookCard
import 'admin/admin_layout.dart';
import 'edit_profile_screen.dart';
import 'settings_screen.dart';
import 'help_support_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final theme = Theme.of(context);

    // Real favorites from shelf (books rated 4 or 5 stars)
    final favoriteShelfBooks = state.userShelf
        .where((b) => b.rating != null && b.rating! >= 4)
        .toList();
    final favorites = favoriteShelfBooks
        .map((sb) => state.books.firstWhere((b) => b.id == sb.bookId))
        .toList();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            } else {
              context.read<AppState>().setSelectedTabIndex(0);
            }
          },
        ),
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
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const EditProfileScreen(),
                          fullscreenDialog: true,
                        ),
                      );
                    },
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
            _buildStatsRow(state, theme),
            const SizedBox(height: 32),

            // Reading Goals
            _buildSectionTitle('${DateTime.now().year} Reading Goal', theme),
            const SizedBox(height: 16),
            _buildGoalsCard(state, theme),
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
            _buildBadgesRow(state, theme),
            const SizedBox(height: 48),

            _buildAccountSection(context, state, theme),
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

  Widget _buildStatsRow(AppState state, ThemeData theme) {
    final booksReadCount = state.userShelf
        .where((b) => b.status == 'read')
        .length;
    final pagesRead = booksReadCount * 300; // Estimate
    final pagesStr = pagesRead >= 1000
        ? '${(pagesRead / 1000).toStringAsFixed(1)}k'
        : pagesRead.toString();

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildStatItem(
          'Books Read',
          booksReadCount.toString(),
          Icons.menu_book_rounded,
          theme,
        ),
        _buildStatItem(
          'Pages Read',
          pagesStr,
          Icons.auto_stories_rounded,
          theme,
        ),
        _buildStatItem(
          'Day Streak',
          state.streakCount.toString(),
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

  Widget _buildGoalsCard(AppState state, ThemeData theme) {
    final booksReadCount = state.userShelf
        .where((b) => b.status == 'read')
        .length;
    final goal = state.yearlyReadingGoal;
    final progress = (booksReadCount / goal).clamp(0.0, 1.0);
    final percent = (progress * 100).toInt();

    // Logic for "ahead of schedule"
    final now = DateTime.now();
    final dayOfYear = now.difference(DateTime(now.year, 1, 1)).inDays + 1;
    final expectedCount = (goal * dayOfYear) / 365;
    final ahead = booksReadCount - expectedCount;

    String aheadText;
    Color aheadColor;
    if (ahead >= 1) {
      aheadText = 'You are ${ahead.floor()} books ahead of schedule!';
      aheadColor = Colors.green[600]!;
    } else if (ahead <= -1) {
      aheadText = 'You are ${ahead.abs().floor()} books behind schedule.';
      aheadColor = Colors.orange[700]!;
    } else {
      aheadText = 'You are right on track!';
      aheadColor = theme.colorScheme.primary;
    }

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
                  '$booksReadCount / $goal Books',
                  style: GoogleFonts.outfit(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                Text(
                  '$percent%',
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
                value: progress,
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
              aheadText,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: aheadColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBadgesRow(AppState state, ThemeData theme) {
    final booksReadCount = state.userShelf
        .where((b) => b.status == 'read')
        .length;
    final hasStarted = state.userShelf.isNotEmpty;
    final streak = state.streakCount;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildBadgeItem(
          Icons.star_rounded,
          'Early Bird',
          Colors.amber,
          description: 'Unlock by adding your first book to your shelf!',
          isUnlocked: hasStarted,
        ),
        _buildBadgeItem(
          Icons.menu_book_rounded,
          'Bookworm',
          Colors.green,
          description: 'Unlock by finishing 10 books!',
          isUnlocked: booksReadCount >= 10,
        ),
        _buildBadgeItem(
          Icons.local_fire_department_rounded,
          'On Fire',
          Colors.orange,
          description: 'Unlock by maintaining a 3-day reading streak!',
          isUnlocked: streak >= 3,
        ),
        _buildBadgeItem(
          Icons.gamepad_rounded,
          'Player 1',
          theme.colorScheme.primary,
          description: 'Unlocked by playing your first minigame!',
          isUnlocked: true, // Milestone reached via minigames
        ),
      ],
    );
  }

  Widget _buildBadgeItem(
    IconData icon,
    String label,
    Color color, {
    required String description,
    required bool isUnlocked,
  }) {
    final gradient = isUnlocked
        ? LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [color.withValues(alpha: 0.8), color],
          )
        : null;

    return Tooltip(
      message: description,
      preferBelow: false,
      child: Column(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: gradient,
              color: isUnlocked ? null : Colors.white.withValues(alpha: 0.1),
              border: isUnlocked
                  ? null
                  : Border.all(
                      color: Colors.grey.withValues(alpha: 0.3),
                      width: 1.5,
                      style: BorderStyle.solid,
                    ),
              boxShadow: isUnlocked
                  ? [
                      BoxShadow(
                        color: color.withValues(alpha: 0.3),
                        blurRadius: 15,
                        spreadRadius: 2,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : [],
            ),
            child: Icon(
              icon,
              size: 32,
              color: isUnlocked ? Colors.white : Colors.grey[500],
            ),
          ),
          const SizedBox(height: 10),
          Text(
            label,
            style: GoogleFonts.outfit(
              fontSize: 13,
              fontWeight: isUnlocked ? FontWeight.w700 : FontWeight.w500,
              color: isUnlocked ? Colors.black87 : Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountSection(BuildContext context, AppState state, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Account', theme),
        const SizedBox(height: 20),
        if (state.isAdmin)
          _buildAccountItem(
            icon: Icons.admin_panel_settings_rounded,
            title: 'Enter Admin Mode',
            theme: theme,
            onTap: () => _showAdminVerification(context),
          ),
        _buildAccountItem(
          icon: Icons.settings_rounded,
          title: 'Settings',
          theme: theme,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SettingsScreen()),
            );
          },
        ),
        _buildAccountItem(
          icon: Icons.help_outline_rounded,
          title: 'Help & Support',
          theme: theme,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const HelpSupportScreen()),
            );
          },
        ),
        _buildAccountItem(
          icon: Icons.logout_rounded,
          title: 'Logout',
          theme: theme,
          isDanger: true,
          onTap: () {
            state.logout();
            // Using context is better than passing it, but this is a Stateless widget
          },
          contextForLogout: (context) {
            state.logout();
            Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
          },
        ),
      ],
    );
  }

  Widget _buildAccountItem({
    required IconData icon,
    required String title,
    required ThemeData theme,
    required VoidCallback onTap,
    bool isDanger = false,
    Function(BuildContext)? contextForLogout,
  }) {
    final color = isDanger ? Colors.red[400]! : theme.colorScheme.primary;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Builder(
        builder: (context) {
          return InkWell(
            onTap: isDanger && contextForLogout != null
                ? () => contextForLogout(context)
                : onTap,
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDanger
                    ? Colors.red.withValues(alpha: 0.05)
                    : theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isDanger
                      ? Colors.red.withValues(alpha: 0.1)
                      : theme.colorScheme.outline.withValues(alpha: 0.05),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(icon, color: color, size: 22),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    title,
                    style: GoogleFonts.outfit(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isDanger
                          ? Colors.red[700]
                          : theme.colorScheme.onSurface,
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    Icons.chevron_right_rounded,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
                    size: 20,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _showAdminVerification(BuildContext context) {
    final TextEditingController pinController = TextEditingController();
    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.admin_panel_settings_rounded,
                color: theme.colorScheme.primary,
                size: 32,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Admin Verification',
              style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Please enter your secure 4-digit PIN to access administrative controls.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            TextField(
              controller: pinController,
              obscureText: true,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              maxLength: 4,
              style: GoogleFonts.outfit(
                fontSize: 24,
                letterSpacing: 16,
                fontWeight: FontWeight.bold,
              ),
              decoration: InputDecoration(
                counterText: '',
                filled: true,
                fillColor: theme.colorScheme.surfaceContainerHighest.withValues(
                  alpha: 0.3,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                hintText: '••••',
                hintStyle: TextStyle(color: theme.colorScheme.outline),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(color: theme.colorScheme.outline),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              if (pinController.text == '8888') {
                Navigator.pop(context); // Close dialog
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const AdminLayout(),
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Invalid PIN. Access Denied.'),
                    backgroundColor: Colors.redAccent,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Verify'),
          ),
        ],
      ),
    );
  }
}
