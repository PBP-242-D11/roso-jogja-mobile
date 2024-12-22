import 'dart:convert';

List<OrderItem> orderItemFromJson(String str) => List<OrderItem>.from(json.decode(str).map((x) => OrderItem.fromJson(x)));

String orderItemToJson(List<OrderItem> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class OrderItem {
    String model;
    int pk;
    Fields fields;

    OrderItem({
        required this.model,
        required this.pk,
        required this.fields,
    });

    factory OrderItem.fromJson(Map<String, dynamic> json) => OrderItem(
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
    int order;
    String food;
    int quantity;
    String priceAtOrder;

    Fields({
        required this.order,
        required this.food,
        required this.quantity,
        required this.priceAtOrder,
    });

    factory Fields.fromJson(Map<String, dynamic> json) => Fields(
        order: json["order"],
        food: json["food"],
        quantity: json["quantity"],
        priceAtOrder: json["price_at_order"],
    );

    Map<String, dynamic> toJson() => {
        "order": order,
        "food": food,
        "quantity": quantity,
        "price_at_order": priceAtOrder,
    };
}
