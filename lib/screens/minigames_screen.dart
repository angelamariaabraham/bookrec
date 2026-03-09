import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/shared_styles.dart';

class MinigamesScreen extends StatelessWidget {
  const MinigamesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Global Premium Background
          SharedStyles.minigameBackground(context),

          CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 180.0,
                floating: false,
                pinned: true,
                backgroundColor: Colors.transparent,
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(
                    'Minigames Hub',
                    style: GoogleFonts.outfit(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Theme.of(context).colorScheme.primary,
                              Colors.deepPurpleAccent,
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                      ),
                      // Decorative icon in header
                      const Positioned(
                        right: -30,
                        bottom: -30,
                        child: Icon(
                          Icons.gamepad,
                          size: 150,
                          color: Colors.white12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.all(24.0),
                sliver: SliverGrid.count(
                  crossAxisCount: 2,
                  mainAxisSpacing: 20,
                  crossAxisSpacing: 20,
                  childAspectRatio: 0.85,
                  children: [
                    _buildGameCard(
                      context,
                      title: 'Cover Reveal',
                      subtitle: 'Guess the blurred cover',
                      icon: Icons.visibility,
                      color: Colors.purpleAccent,
                      route: '/minigames/cover_reveal',
                    ),
                    _buildGameCard(
                      context,
                      title: 'Decryption',
                      subtitle: 'Sentence by sentence',
                      icon: Icons.password,
                      color: Colors.orangeAccent,
                      route: '/minigames/decryption',
                    ),
                    _buildGameCard(
                      context,
                      title: 'Timeline',
                      subtitle: 'Sort by release date',
                      icon: Icons.timeline,
                      color: Colors.greenAccent,
                      route: '/minigames/timeline',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGameCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required String route,
  }) {
    return GlassCard(
      onTap: () => Navigator.pushNamed(context, route),
      color: color.withValues(alpha: 0.2), // The tint of the glass
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withValues(alpha: 0.2),
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.4),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Icon(icon, size: 40, color: Colors.white),
          ),
          const SizedBox(height: 24),
          Text(
            title,
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(fontSize: 12, color: Colors.white70),
          ),
        ],
      ),
    );
  }
}
