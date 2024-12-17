// To parse this JSON data, do
//
//     final user = userFromJson(jsonString);

import 'dart:convert';

User userFromJson(String str) => User.fromJson(json.decode(str));

String userToJson(User data) => json.encode(data.toJson());

class User {
  String id;
  String role;
  String username;
  String phoneNumber;
  String address;
  String? profilePicture;

  User({
    required this.id,
    required this.role,
    required this.username,
    required this.phoneNumber,
    required this.address,
    this.profilePicture,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
        id: json["id"],
        role: json["role"],
        username: json["username"],
        phoneNumber: json["phone_number"],
        address: json["address"],
        profilePicture: json["profile_picture"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "role": role,
        "username": username,
        "phone_number": phoneNumber,
        "address": address,
        "profile_picture": profilePicture,
      };
}
