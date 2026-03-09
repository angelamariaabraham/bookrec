class Book {
  final int? id;
  final String title;
  final String? author;
  final String? description;
  final String? genres;
  final String? rating;
  final String? coverImageUrl;
  final String? publishDate;
  final String? normalizedDescription;
  final int? numRatings;

  Book({
    this.id,
    required this.title,
    this.author,
    this.description,
    this.genres,
    this.rating,
    this.coverImageUrl,
    this.publishDate,
    this.normalizedDescription,
    this.numRatings,
  });

  factory Book.fromJson(Map<String, dynamic> json) {
    return Book(
      id: json['id'],
      title: json['title'] ?? 'Unknown Title',
      author: json['author'],
      description: json['description'],
      genres: json['genres'],
      rating: json['rating'],
      coverImageUrl: json['cover_image_url'],
      publishDate: json['publish_date'],
      normalizedDescription: json['normalized_description'],
      numRatings: json['num_ratings'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'author': author,
      'description': description,
      'genres': genres,
      'rating': rating,
      'cover_image_url': coverImageUrl,
      'publish_date': publishDate,
      'normalized_description': normalizedDescription,
      'num_ratings': numRatings,
    };
  }
}
