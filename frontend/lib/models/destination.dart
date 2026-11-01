class DestinationAttraction {
  final String name;
  final String description;
  final String emoji;
  final double rating;

  const DestinationAttraction({
    required this.name,
    required this.description,
    required this.emoji,
    required this.rating,
  });
}

class DestinationReview {
  final String author;
  final String avatar;
  final double rating;
  final String date;
  final String comment;

  const DestinationReview({
    required this.author,
    required this.avatar,
    required this.rating,
    required this.date,
    required this.comment,
  });
}

class Destination {
  final String id;
  final String name;
  final String country;
  final String region;
  final String category;
  final String emoji;
  final String description;
  final double rating;
  final int reviewCount;
  final double pricePerNight;
  final String bestTimeToVisit;
  final String weather;
  final List<String> tags;
  final List<DestinationAttraction> attractions;
  final List<DestinationReview> reviews;
  final List<String> gradientColorsHex;
  final bool isFeatured;

  const Destination({
    required this.id,
    required this.name,
    required this.country,
    required this.region,
    required this.category,
    required this.emoji,
    required this.description,
    required this.rating,
    required this.reviewCount,
    required this.pricePerNight,
    required this.bestTimeToVisit,
    required this.weather,
    required this.tags,
    required this.attractions,
    required this.reviews,
    required this.gradientColorsHex,
    this.isFeatured = false,
  });
}
