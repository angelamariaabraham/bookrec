import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/app_state.dart';
import '../../models/book.dart';
import '../../widgets/animated_score_counter.dart';
import '../../widgets/shared_styles.dart';

class SentenceDecryptionScreen extends StatefulWidget {
  const SentenceDecryptionScreen({super.key});

  @override
  State<SentenceDecryptionScreen> createState() =>
      _SentenceDecryptionScreenState();
}

class _SentenceDecryptionScreenState extends State<SentenceDecryptionScreen> {
  Map<String, dynamic>? _gameData;
  int _score = 0;
  bool _answered = false;
  int? _selectedId;
  int _revealedSentencesCount = 1;

  @override
  void initState() {
    super.initState();
    _loadGame();
  }

  void _loadGame() {
    setState(() {
      _gameData = context.read<AppState>().getSentenceDecryptionGame();
      _answered = false;
      _selectedId = null;
      _revealedSentencesCount = 1;
    });
  }

  void _revealNext() {
    final sentences = _gameData!['sentences'] as List<String>;
    if (_revealedSentencesCount < sentences.length) {
      setState(() {
        _revealedSentencesCount++;
      });
    }
  }

  void _handleAnswer(int id) {
    if (_answered) return;

    final correctId = (_gameData!['correct_book'] as Book).id;
    final isCorrectGuess = (id == correctId);

    setState(() {
      _answered = true;
      _selectedId = id;

      if (isCorrectGuess) {
        // More points if you guessed with fewer sentences
        _score += 10 + (10 ~/ _revealedSentencesCount);
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isCorrectGuess ? 'Correct! Nice job.' : 'Oops! That was incorrect.',
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
    final sentences = _gameData!['sentences'] as List<String>;

    // Display revealed sentences
    String revealedText = sentences.take(_revealedSentencesCount).join(' ');

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Decryption', style: TextStyle(color: Colors.white)),
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
                    'Guess the book based on its description! Read the description sentence by sentence. You can reveal more hints if you need them. Guessing it with fewer hints earns more points!',
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
                    flex: 4,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        GlassCard(
                          padding: const EdgeInsets.all(24.0),
                          child: SingleChildScrollView(
                            child: Column(
                              children: [
                                const Icon(
                                  Icons.format_quote,
                                  size: 40,
                                  color: Colors.white54,
                                ),
                                AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 500),
                                  transitionBuilder:
                                      (
                                        Widget child,
                                        Animation<double> animation,
                                      ) {
                                        return FadeTransition(
                                          opacity: animation,
                                          child: child,
                                        );
                                      },
                                  child: Text(
                                    revealedText,
                                    key: ValueKey<String>(revealedText),
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.inter(
                                      fontSize: 18,
                                      height: 1.6,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 24),
                                if (!_answered &&
                                    _revealedSentencesCount <
                                        sentences.length) ...[
                                  Text(
                                    '${_revealedSentencesCount} of ${sentences.length} sentences revealed',
                                    style: const TextStyle(
                                      color: Colors.white54,
                                      fontSize: 12,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  ElevatedButton.icon(
                                    onPressed: _revealNext,
                                    icon: const Icon(Icons.visibility),
                                    label: const Text('Reveal Next Hint'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.white12,
                                      foregroundColor: Colors.white,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Which book is this from?',
                    style: GoogleFonts.outfit(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    flex: 5,
                    child: ListView.builder(
                      itemCount: options.length,
                      itemBuilder: (context, index) {
                        final option = options[index];
                        final isCorrect = option.id == correctBook.id;
                        final isSelected = option.id == _selectedId;

                        Color itemColor = Colors.white.withValues(alpha: 0.1);

                        if (_answered) {
                          if (isCorrect)
                            itemColor = Colors.green.withValues(alpha: 0.3);
                          else if (isSelected)
                            itemColor = Colors.red.withValues(alpha: 0.3);
                        }

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: GlassCard(
                            onTap: () => _handleAnswer(option.id!),
                            color: itemColor,
                            padding: const EdgeInsets.all(16),
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
                          'Next Question',
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
