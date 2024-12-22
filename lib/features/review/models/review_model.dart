// To parse this JSON data, do
//
//     final productEntry = productEntryFromJson(jsonString);

import 'dart:convert';

ProductEntry productEntryFromJson(String str) => ProductEntry.fromJson(json.decode(str));

String productEntryToJson(ProductEntry data) => json.encode(data.toJson());

class ProductEntry {
    List<Review> reviews;

    ProductEntry({
        required this.reviews,
    });

    factory ProductEntry.fromJson(Map<String, dynamic> json) => ProductEntry(
        reviews: List<Review>.from(json["reviews"].map((x) => Review.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "reviews": List<dynamic>.from(reviews.map((x) => x.toJson())),
    };
}

class Review {
    int id;
    String user;
    int rating;
    String comment;
    DateTime createdAt;

    Review({
        required this.id,
        required this.user,
        required this.rating,
        required this.comment,
        required this.createdAt,
    });

    factory Review.fromJson(Map<String, dynamic> json) => Review(
        id: json["id"],
        user: json["user"],
        rating: json["rating"],
        comment: json["comment"],
        createdAt: DateTime.parse(json["created_at"]),
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "user": user,
        "rating": rating,
        "comment": comment,
        "created_at": createdAt.toIso8601String(),
    };
}
