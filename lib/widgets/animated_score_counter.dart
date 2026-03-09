import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AnimatedScoreCounter extends StatefulWidget {
  final int score;
  const AnimatedScoreCounter({super.key, required this.score});

  @override
  State<AnimatedScoreCounter> createState() => _AnimatedScoreCounterState();
}

class _AnimatedScoreCounterState extends State<AnimatedScoreCounter>
    with SingleTickerProviderStateMixin {
  late int _displayedScore;
  int _lastScoreAdded = 0;

  late AnimationController _animController;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _displayedScore = widget.score;

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _scaleAnimation =
        TweenSequence([
          TweenSequenceItem(
            tween: Tween<double>(begin: 1.0, end: 1.4),
            weight: 1,
          ),
          TweenSequenceItem(
            tween: Tween<double>(begin: 1.4, end: 1.0),
            weight: 1,
          ),
        ]).animate(
          CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
        );

    _slideAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0, -2.5),
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));

    _fadeAnimation = TweenSequence([
      TweenSequenceItem(tween: Tween<double>(begin: 0.0, end: 1.0), weight: 1),
      TweenSequenceItem(tween: Tween<double>(begin: 1.0, end: 0.0), weight: 1),
    ]).animate(CurvedAnimation(parent: _animController, curve: Curves.linear));
  }

  @override
  void didUpdateWidget(AnimatedScoreCounter oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.score > oldWidget.score) {
      _lastScoreAdded = widget.score - oldWidget.score;
      _animController.forward(from: 0.0);

      // Animate the actual displayed number
      Future.delayed(const Duration(milliseconds: 150), () {
        if (mounted) {
          setState(() {
            _displayedScore = widget.score;
          });
        }
      });
    } else if (widget.score != oldWidget.score) {
      _displayedScore = widget.score; // If it just resets
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      clipBehavior: Clip.none,
      children: [
        // The main score text in an attractive pill container
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: Colors.amberAccent.withValues(alpha: 0.5),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.amberAccent.withValues(alpha: 0.2),
                blurRadius: 8,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.stars, color: Colors.amberAccent, size: 24),
              const SizedBox(width: 8),
              ScaleTransition(
                scale: _scaleAnimation,
                child: Text(
                  '$_displayedScore',
                  style: GoogleFonts.outfit(
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
        // The floating "+10" text
        if (_lastScoreAdded > 0)
          Positioned(
            right: -20,
            top: -10,
            child: SlideTransition(
              position: _slideAnimation,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Text(
                  '+$_lastScoreAdded',
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w900,
                    fontSize: 24,
                    color: Colors.greenAccent,
                    shadows: [
                      Shadow(
                        color: Colors.black.withValues(alpha: 0.6),
                        offset: const Offset(1, 1),
                        blurRadius: 4,
                      ),
                      const Shadow(color: Colors.greenAccent, blurRadius: 12),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
