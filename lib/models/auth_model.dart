import 'dart:convert';

class User {
  final String userid;
  final String fullName;
  final String email;
  final String cattleFarmName;
  final String location;
  final String phoneNumber;
  late final int credit;

  User({
    required this.userid,
    required this.fullName,
    required this.email,
    required this.cattleFarmName,
    required this.location,
    required this.phoneNumber,
    required this.credit
  });

  // JSON serialization
  Map<String, dynamic> toMap() {
    return {
      'userid': userid,
      'full_name': fullName,
      'email': email,
      'cattle_farm_name': cattleFarmName,
      'location': location,
      'phone_number': phoneNumber,
      'credit': credit,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      userid: map['userid'] ?? '',
      fullName: map['full_name'] ?? '',
      email: map['email'] ?? '',
      cattleFarmName: map['cattle_farm_name'] ?? '',
      location: map['location'] ?? '',
      phoneNumber: map['phone_number'] ?? '',
      credit: map['credit'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory User.fromJson(String source) => User.fromMap(json.decode(source));
}
