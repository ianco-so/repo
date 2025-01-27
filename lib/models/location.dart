// A location has an latitude and logitude values

class Location {
  final String latitude;
  final String longitude;

  const Location({
    required this.latitude,
    required this.longitude,
  });

  factory Location.fromJson(Map<dynamic, dynamic> json) {
    return Location(
      latitude: json['latitude'].toString(),
      longitude: json['longitude'].toString(),
    );
  }
}