import 'dart:convert';

List<Cart> cartFromJson(String str) => List<Cart>.from(json.decode(str).map((x) => Cart.fromJson(x)));

String cartToJson(List<Cart> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Cart {
    String model;
    String pk;
    Fields fields;

    Cart({
        required this.model,
        required this.pk,
        required this.fields,
    });

    factory Cart.fromJson(Map<String, dynamic> json) => Cart(
        model: json["model"],
        pk: json["pk"],
        fields: Fields.fromJson(json["fields"]),
    );

    Map<String, dynamic> toJson() => {
        "model": model,
        "pk": pk,
        "fields": fields.toJson(),
    };
}

class Fields {
    String restaurant;

    Fields({
        required this.restaurant,
    });

    factory Fields.fromJson(Map<String, dynamic> json) => Fields(
        restaurant: json["restaurant"],
    );

    Map<String, dynamic> toJson() => {
        "restaurant": restaurant,
    };
}
