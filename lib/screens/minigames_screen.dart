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
                leading: Navigator.canPop(context)
                    ? Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.3),
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            icon: const Icon(
                              Icons.arrow_back_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ),
                      )
                    : null,
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
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 40.0),
                  child: Center(
                    child: Wrap(
                      spacing: 32,
                      runSpacing: 32,
                      alignment: WrapAlignment.center,
                      children: [
                        SizedBox(
                          width: 280,
                          height: 280,
                          child: _buildGameCard(
                            context,
                            title: 'Cover Reveal',
                            subtitle: 'Guess the blurred cover artwork',
                            icon: Icons.visibility_rounded,
                            color: Colors.purpleAccent,
                            route: '/minigames/cover_reveal',
                          ),
                        ),
                        SizedBox(
                          width: 280,
                          height: 280,
                          child: _buildGameCard(
                            context,
                            title: 'Decryption',
                            subtitle: 'Decode the secret book quotes',
                            icon: Icons.password_rounded,
                            color: Colors.orangeAccent,
                            route: '/minigames/decryption',
                          ),
                        ),
                      ],
                    ),
                  ),
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
