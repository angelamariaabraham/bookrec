import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:ui';
import 'dart:async';
import '../../providers/app_state.dart';
import '../../models/book.dart';
import '../../widgets/animated_score_counter.dart';
import '../../widgets/shared_styles.dart';

class CoverRevealScreen extends StatefulWidget {
  const CoverRevealScreen({super.key});

  @override
  State<CoverRevealScreen> createState() => _CoverRevealScreenState();
}

class _CoverRevealScreenState extends State<CoverRevealScreen> {
  Map<String, dynamic>? _gameData;
  int _score = 0;
  bool _answered = false;
  int? _selectedId;
  double _blurAmount = 20.0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _loadGame();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _loadGame() {
    _timer?.cancel();
    setState(() {
      _gameData = context.read<AppState>().getCoverRevealGame();
      _answered = false;
      _selectedId = null;
      _blurAmount = 25.0; // Start very blurry
    });

    // Gradually reduce blur over 10 seconds
    _timer = Timer.periodic(const Duration(milliseconds: 200), (timer) {
      if (_answered || !mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        _blurAmount -= 0.5;
        if (_blurAmount <= 0) {
          _blurAmount = 0;
          timer.cancel();
        }
      });
    });
  }

  void _handleAnswer(int id) {
    if (_answered) return;

    // Stop the blur animation
    _timer?.cancel();

    final correctId = (_gameData!['correct_book'] as Book).id;
    final isCorrectGuess = (id == correctId);

    int pointsEarned = 0;

    setState(() {
      _answered = true;
      _selectedId = id;

      if (isCorrectGuess) {
        if (_blurAmount > 0) {
          // Score based on how blurry it was (faster = better)
          pointsEarned = (_blurAmount * 2).ceil() + 10;
        } else {
          // No points if fully revealed
          pointsEarned = 0;
        }
        _score += pointsEarned;
      }

      _blurAmount = 0.0; // Instantly reveal
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isCorrectGuess
              ? 'Correct! +$pointsEarned points.'
              : 'Oops! That was incorrect.',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: isCorrectGuess ? Colors.green : Colors.red,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_gameData == null) {
      return Scaffold(
        body: Stack(
          children: [
            SharedStyles.minigameBackground(context),
            const Center(child: CircularProgressIndicator()),
          ],
        ),
      );
    }

    final theme = Theme.of(context);
    final correctBook = _gameData!['correct_book'] as Book;
    final options = _gameData!['options'] as List<Book>;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          'Cover Reveal',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline, color: Colors.white),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('How to Play'),
                  content: const Text(
                    'Try to guess the book from the heavily blurred cover! The blur will slowly reduce over 10 seconds. The faster you guess, the more points you earn.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Got it!'),
                    ),
                  ],
                ),
              );
            },
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Center(child: AnimatedScoreCounter(score: _score)),
          ),
        ],
      ),
      body: Stack(
        children: [
          SharedStyles.minigameBackground(context),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  Expanded(
                    flex: 3,
                    child: Center(
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.black54,
                                  blurRadius: 20,
                                  offset: Offset(0, 10),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: AnimatedSwitcher(
                                duration: const Duration(milliseconds: 300),
                                child: ImageFiltered(
                                  key: ValueKey<double>(_blurAmount),
                                  imageFilter: ImageFilter.blur(
                                    sigmaX: _blurAmount,
                                    sigmaY: _blurAmount,
                                  ),
                                  child: Image.network(
                                    correctBook.coverImageUrl!,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Which book is this?',
                    style: GoogleFonts.outfit(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    flex: 4,
                    child: ListView.builder(
                      itemCount: options.length,
                      itemBuilder: (context, index) {
                        final option = options[index];
                        final isCorrect = option.id == correctBook.id;
                        final isSelected = option.id == _selectedId;

                        Color itemColor = Colors.white.withValues(alpha: 0.1);

                        if (_answered) {
                          if (isCorrect) {
                            itemColor = Colors.green.withValues(alpha: 0.3);
                          } else if (isSelected) {
                            itemColor = Colors.red.withValues(alpha: 0.3);
                          }
                        }

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: GlassCard(
                            onTap: () => _handleAnswer(option.id!),
                            color: itemColor,
                            padding: const EdgeInsets.all(18),
                            child: Row(
                              children: [
                                if (_answered && isCorrect)
                                  const Icon(
                                    Icons.check_circle,
                                    color: Colors.green,
                                    size: 20,
                                  )
                                else if (_answered && isSelected)
                                  const Icon(
                                    Icons.cancel,
                                    color: Colors.red,
                                    size: 20,
                                  )
                                else
                                  const Icon(
                                    Icons.radio_button_unchecked,
                                    color: Colors.white54,
                                    size: 20,
                                  ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    option.title,
                                    style: GoogleFonts.inter(
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  if (_answered)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _loadGame,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          backgroundColor: theme.colorScheme.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Text(
                          'Next Game',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
