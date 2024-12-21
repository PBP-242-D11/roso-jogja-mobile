import 'dart:convert';

List<CartItem> cartItemFromJson(String str) => List<CartItem>.from(json.decode(str).map((x) => CartItem.fromJson(x)));

String cartItemToJson(List<CartItem> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class CartItem {
    String model;
    int pk;
    Fields fields;

    CartItem({
        required this.model,
        required this.pk,
        required this.fields,
    });

    factory CartItem.fromJson(Map<String, dynamic> json) => CartItem(
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
    String cart;
    String food;
    int quantity;

    Fields({
        required this.cart,
        required this.food,
        required this.quantity,
    });

    factory Fields.fromJson(Map<String, dynamic> json) => Fields(
        cart: json["cart"],
        food: json["food"],
        quantity: json["quantity"],
    );

    Map<String, dynamic> toJson() => {
        "cart": cart,
        "food": food,
        "quantity": quantity,
    };
}
