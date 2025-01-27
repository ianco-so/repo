// A contact model class
import 'location.dart';
import 'status.dart';
class Contact {
  String firstName;
  String lastName;
  String email;
  String phone;
  Status status;
  Location location;
  String photoUrl;
  
  Contact({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.status,
    required this.location,
    required this.photoUrl,
  });

  factory Contact.fromJson(Map<String, dynamic> json) {
    return Contact(
      firstName: json['firstName'],
      lastName: json['lastName'],
      email: json['email'],
      phone: json['phone'],
      status: Status.values[json['status']],
      location: Location.fromJson(json['location']),
      photoUrl: json['photoUrl'],
    );
  }
}