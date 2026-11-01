enum ActivityCategory {
  sightseeing,
  food,
  adventure,
  relaxation,
  culture,
  transport,
}

class ActivityItem {
  final String id;
  final String time;
  final String title;
  final String description;
  final ActivityCategory category;
  final String location;
  final String duration;
  final double estimatedCost;
  bool isCompleted;

  ActivityItem({
    required this.id,
    required this.time,
    required this.title,
    required this.description,
    required this.category,
    required this.location,
    required this.duration,
    this.estimatedCost = 0.0,
    this.isCompleted = false,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'time': time,
    'title': title,
    'description': description,
    'category': category.name,
    'location': location,
    'duration': duration,
    'estimatedCost': estimatedCost,
    'isCompleted': isCompleted,
  };

  factory ActivityItem.fromJson(Map<String, dynamic> json) {
    return ActivityItem(
      id: json['id'] as String,
      time: json['time'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      category: ActivityCategory.values.firstWhere(
        (c) => c.name == json['category'],
        orElse: () => ActivityCategory.sightseeing,
      ),
      location: json['location'] as String,
      duration: json['duration'] as String,
      estimatedCost: (json['estimatedCost'] as num?)?.toDouble() ?? 0.0,
      isCompleted: json['isCompleted'] as bool? ?? false,
    );
  }
}

class ItineraryDay {
  final int dayNumber;
  final String date;
  final String title;
  final List<ActivityItem> activities;

  ItineraryDay({
    required this.dayNumber,
    required this.date,
    required this.title,
    required this.activities,
  });

  Map<String, dynamic> toJson() => {
    'dayNumber': dayNumber,
    'date': date,
    'title': title,
    'activities': activities.map((a) => a.toJson()).toList(),
  };

  factory ItineraryDay.fromJson(Map<String, dynamic> json) {
    return ItineraryDay(
      dayNumber: json['dayNumber'] as int,
      date: json['date'] as String,
      title: json['title'] as String,
      activities: (json['activities'] as List<dynamic>?)
              ?.map((a) => ActivityItem.fromJson(a as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}
