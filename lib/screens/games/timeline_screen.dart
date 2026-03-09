import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/app_state.dart';
import '../../models/book.dart';
import '../../widgets/animated_score_counter.dart';
import '../../widgets/shared_styles.dart';

class TimelineScreen extends StatefulWidget {
  const TimelineScreen({super.key});

  @override
  State<TimelineScreen> createState() => _TimelineScreenState();
}

class _TimelineScreenState extends State<TimelineScreen> {
  Map<String, dynamic>? _gameData;
  List<Map<String, dynamic>> _currentItems = [];
  int _score = 0;
  bool _answered = false;
  int _correctPlacements = 0;

  @override
  void initState() {
    super.initState();
    _loadGame();
  }

  void _loadGame() {
    setState(() {
      _gameData = context.read<AppState>().getTimelineGame();
      if (_gameData != null) {
        _currentItems = List.from(_gameData!['items']);
      }
      _answered = false;
      _correctPlacements = 0;
    });
  }

  void _submitOrder() {
    if (_gameData == null || _answered) return;

    final correctIds = _gameData!['correct_order_ids'] as List<int>;
    final currentIds = _currentItems
        .map((e) => (e['book'] as Book).id)
        .toList();

    int correct = 0;
    for (int i = 0; i < correctIds.length; i++) {
      if (correctIds[i] == currentIds[i]) {
        correct++;
      }
    }

    setState(() {
      _answered = true;
      _correctPlacements = correct;
      if (correct == correctIds.length) {
        _score += 20; // Perfect bonus
      } else {
        _score += correct * 2;
      }
    });
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
    final correctIds = _gameData!['correct_order_ids'] as List<int>;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          'Timeline Tool',
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
                    'Drag and drop the books to arrange them in their original chronological release order! Oldest books at the top, newest on the bottom. You get a bonus for a perfect score.',
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
                  Text(
                    'Drag and drop to sort by original publication date',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.outfit(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '(Oldest at the top, Newest at the bottom)',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Expanded(
                    child: Theme(
                      data: Theme.of(
                        context,
                      ).copyWith(canvasColor: Colors.transparent),
                      child: ReorderableListView.builder(
                        itemCount: _currentItems.length,
                        onReorder: (int oldIndex, int newIndex) {
                          if (_answered) return;
                          setState(() {
                            if (oldIndex < newIndex) {
                              newIndex -= 1;
                            }
                            final item = _currentItems.removeAt(oldIndex);
                            _currentItems.insert(newIndex, item);
                          });
                        },
                        itemBuilder: (context, index) {
                          final item = _currentItems[index];
                          final book = item['book'] as Book;
                          final isCorrectSpot = _answered
                              ? correctIds[index] == book.id
                              : null;

                          // Show the actual year if answered
                          String yearStr = _answered ? '${item['year']}' : '';

                          Color borderColor = Colors.white.withValues(
                            alpha: 0.1,
                          );
                          if (_answered) {
                            borderColor = isCorrectSpot!
                                ? Colors.greenAccent
                                : Colors.redAccent;
                          }

                          return Container(
                            key: ValueKey(book.id),
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.05),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: borderColor, width: 2),
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              leading: ReorderableDragStartListener(
                                index: index,
                                child: Icon(
                                  Icons.drag_handle,
                                  color: _answered
                                      ? Colors.white30
                                      : Colors.white,
                                ),
                              ),
                              title: Text(
                                book.title,
                                style: GoogleFonts.inter(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              subtitle: Text(
                                book.author ?? '',
                                style: const TextStyle(color: Colors.white70),
                              ),
                              trailing: _answered
                                  ? Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          yearStr,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.amberAccent,
                                            fontSize: 16,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Icon(
                                          isCorrectSpot!
                                              ? Icons.check_circle
                                              : Icons.cancel,
                                          color: isCorrectSpot
                                              ? Colors.greenAccent
                                              : Colors.redAccent,
                                        ),
                                      ],
                                    )
                                  : null,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  if (_answered)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 24.0),
                      child: Text(
                        'You got $_correctPlacements out of ${correctIds.length} in the correct exact spots!',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.outfit(
                          fontSize: 18,
                          color: Colors.amberAccent,
                        ),
                      ),
                    ),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _answered ? _loadGame : _submitOrder,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        backgroundColor: theme.colorScheme.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Text(
                        _answered ? 'Next Round' : 'Submit Timeline Order',
                        style: const TextStyle(
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
