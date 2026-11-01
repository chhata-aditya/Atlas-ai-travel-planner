import 'itinerary.dart';

enum TripStatus {
  planning,
  upcoming,
  completed,
}

class PackingItem {
  final String id;
  final String title;
  final String category;
  bool isPacked;

  PackingItem({
    required this.id,
    required this.title,
    required this.category,
    this.isPacked = false,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'category': category,
    'isPacked': isPacked,
  };

  factory PackingItem.fromJson(Map<String, dynamic> json) => PackingItem(
    id: json['id'] as String,
    title: json['title'] as String,
    category: json['category'] as String? ?? 'General',
    isPacked: json['isPacked'] as bool? ?? false,
  );
}

class Trip {
  final String id;
  final String title;
  final String destinationId;
  final String destinationName;
  final String destinationCountry;
  final String destinationEmoji;
  final DateTime startDate;
  final DateTime endDate;
  final String travelStyle;
  final double totalBudget;
  double spentAmount;
  final int travelersCount;
  TripStatus status;
  final List<ItineraryDay> days;
  final List<PackingItem> packingList;
  final List<String> gradientColorsHex;

  Trip({
    required this.id,
    required this.title,
    required this.destinationId,
    required this.destinationName,
    required this.destinationCountry,
    required this.destinationEmoji,
    required this.startDate,
    required this.endDate,
    required this.travelStyle,
    required this.totalBudget,
    this.spentAmount = 0.0,
    this.travelersCount = 1,
    this.status = TripStatus.upcoming,
    required this.days,
    required this.packingList,
    required this.gradientColorsHex,
  });

  int get durationInDays => endDate.difference(startDate).inDays + 1;

  int get daysUntilDeparture {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tripStart = DateTime(startDate.year, startDate.month, startDate.day);
    return tripStart.difference(today).inDays;
  }

  double get completionProgress {
    int total = 0;
    int done = 0;
    for (final day in days) {
      for (final act in day.activities) {
        total++;
        if (act.isCompleted) done++;
      }
    }
    if (total == 0) return 0.0;
    return done / total;
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'destinationId': destinationId,
    'destinationName': destinationName,
    'destinationCountry': destinationCountry,
    'destinationEmoji': destinationEmoji,
    'startDate': startDate.toIso8601String(),
    'endDate': endDate.toIso8601String(),
    'travelStyle': travelStyle,
    'totalBudget': totalBudget,
    'spentAmount': spentAmount,
    'travelersCount': travelersCount,
    'status': status.name,
    'days': days.map((d) => d.toJson()).toList(),
    'packingList': packingList.map((p) => p.toJson()).toList(),
    'gradientColorsHex': gradientColorsHex,
  };

  factory Trip.fromJson(Map<String, dynamic> json) => Trip(
    id: json['id'] as String,
    title: json['title'] as String,
    destinationId: json['destinationId'] as String,
    destinationName: json['destinationName'] as String,
    destinationCountry: json['destinationCountry'] as String,
    destinationEmoji: json['destinationEmoji'] as String,
    startDate: DateTime.parse(json['startDate'] as String),
    endDate: DateTime.parse(json['endDate'] as String),
    travelStyle: json['travelStyle'] as String? ?? 'Explorer',
    totalBudget: (json['totalBudget'] as num?)?.toDouble() ?? 1500.0,
    spentAmount: (json['spentAmount'] as num?)?.toDouble() ?? 0.0,
    travelersCount: json['travelersCount'] as int? ?? 1,
    status: TripStatus.values.firstWhere(
      (s) => s.name == json['status'],
      orElse: () => TripStatus.upcoming,
    ),
    days: (json['days'] as List<dynamic>?)
            ?.map((d) => ItineraryDay.fromJson(d as Map<String, dynamic>))
            .toList() ??
        [],
    packingList: (json['packingList'] as List<dynamic>?)
            ?.map((p) => PackingItem.fromJson(p as Map<String, dynamic>))
            .toList() ??
        [],
    gradientColorsHex: (json['gradientColorsHex'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList() ??
        ['#0F4C75', '#3282B8'],
  );
}
