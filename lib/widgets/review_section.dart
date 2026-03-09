import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/app_state.dart';
import '../services/firestore_service.dart';

class ReviewSection extends StatelessWidget {
  final int bookId;

  const ReviewSection({super.key, required this.bookId});

  void _showWriteReviewDialog(BuildContext context, AppState state) {
    double _rating = 0;
    final _textController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Write a Review'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      return IconButton(
                        icon: Icon(
                          index < _rating ? Icons.star : Icons.star_border,
                          color: Colors.amber,
                        ),
                        onPressed: () {
                          setState(() {
                            _rating = index + 1.0;
                          });
                        },
                      );
                    }),
                  ),
                  TextField(
                    controller: _textController,
                    decoration: const InputDecoration(
                      hintText: 'What did you think of the book?',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 4,
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (_rating == 0) return; // Basic validation
                    await state.addReview(
                      bookId,
                      _rating,
                      _textController.text,
                    );
                    Navigator.pop(context);
                  },
                  child: const Text('Submit'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Community Reviews',
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (state.isLoggedIn)
              TextButton.icon(
                icon: const Icon(Icons.edit, size: 18),
                label: const Text('Write Review'),
                onPressed: () => _showWriteReviewDialog(context, state),
              ),
          ],
        ),
        const SizedBox(height: 16),
        StreamBuilder<List<ReviewModel>>(
          stream: state.getBookReviews(bookId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 24.0),
                child: Text('No reviews yet. Be the first!'),
              );
            }

            final reviews = snapshot.data!;
            return ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: reviews.length,
              separatorBuilder: (context, index) => const Divider(),
              itemBuilder: (context, index) {
                final review = reviews[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 16,
                            child: Text(review.userName[0].toUpperCase()),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            review.userName,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const Spacer(),
                          Row(
                            children: [
                              const Icon(
                                Icons.star,
                                color: Colors.amber,
                                size: 16,
                              ),
                              Text(review.rating.toString()),
                            ],
                          ),
                        ],
                      ),
                      if (review.text.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0, left: 40.0),
                          child: Text(review.text),
                        ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }
}
