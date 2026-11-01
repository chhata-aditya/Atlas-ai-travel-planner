class PassportStamp {
  final String id;
  final String destination;
  final String country;
  final String emoji;
  final String dateVisited;
  final String stampColorHex;
  final String stampType; // 'entry', 'exit', 'vip', 'visa'
  final String airportCode;

  const PassportStamp({
    required this.id,
    required this.destination,
    required this.country,
    required this.emoji,
    required this.dateVisited,
    required this.stampColorHex,
    this.stampType = 'entry',
    this.airportCode = 'INTL',
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'destination': destination,
    'country': country,
    'emoji': emoji,
    'dateVisited': dateVisited,
    'stampColorHex': stampColorHex,
    'stampType': stampType,
    'airportCode': airportCode,
  };

  factory PassportStamp.fromJson(Map<String, dynamic> json) => PassportStamp(
    id: json['id'] as String,
    destination: json['destination'] as String,
    country: json['country'] as String,
    emoji: json['emoji'] as String,
    dateVisited: json['dateVisited'] as String,
    stampColorHex: json['stampColorHex'] as String? ?? '#BA135D',
    stampType: json['stampType'] as String? ?? 'entry',
    airportCode: json['airportCode'] as String? ?? 'INTL',
  );
}

class UserProfile {
  final String name;
  final String email;
  final String bio;
  final String avatarUrl;
  final String photoUrl;
  final String dateOfBirth;
  final String placeOfIssue;
  final String dateOfIssue;
  final String licenseNumber;
  final String signature;
  final String cardColor; // 'yellow', 'blue', 'mint', 'pink'
  final int countriesVisited;
  final int totalTrips;
  final int milesTraveled;
  final List<String> travelPreferences;
  final List<PassportStamp> stamps;

  const UserProfile({
    required this.name,
    required this.email,
    required this.bio,
    required this.avatarUrl,
    this.photoUrl = 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=600&q=80',
    this.dateOfBirth = '03/06/1996',
    this.placeOfIssue = 'Kyoto, Japan',
    this.dateOfIssue = '06/25/2024',
    this.licenseNumber = 'ATL-6252026',
    this.signature = '',
    this.cardColor = 'yellow',
    required this.countriesVisited,
    required this.totalTrips,
    required this.milesTraveled,
    required this.travelPreferences,
    required this.stamps,
  });

  String get effectiveSignature => signature.isNotEmpty ? signature : (name.isNotEmpty ? name : 'Traveler');

  UserProfile copyWith({
    String? name,
    String? email,
    String? bio,
    String? avatarUrl,
    String? photoUrl,
    String? dateOfBirth,
    String? placeOfIssue,
    String? dateOfIssue,
    String? licenseNumber,
    String? signature,
    String? cardColor,
    int? countriesVisited,
    int? totalTrips,
    int? milesTraveled,
    List<String>? travelPreferences,
    List<PassportStamp>? stamps,
  }) {
    return UserProfile(
      name: name ?? this.name,
      email: email ?? this.email,
      bio: bio ?? this.bio,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      photoUrl: photoUrl ?? this.photoUrl,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      placeOfIssue: placeOfIssue ?? this.placeOfIssue,
      dateOfIssue: dateOfIssue ?? this.dateOfIssue,
      licenseNumber: licenseNumber ?? this.licenseNumber,
      signature: signature ?? this.signature,
      cardColor: cardColor ?? this.cardColor,
      countriesVisited: countriesVisited ?? this.countriesVisited,
      totalTrips: totalTrips ?? this.totalTrips,
      milesTraveled: milesTraveled ?? this.milesTraveled,
      travelPreferences: travelPreferences ?? this.travelPreferences,
      stamps: stamps ?? this.stamps,
    );
  }
}
