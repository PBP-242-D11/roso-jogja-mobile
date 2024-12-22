import 'dart:convert';

List<Order> orderFromJson(String str) => List<Order>.from(json.decode(str).map((x) => Order.fromJson(x)));

String orderToJson(List<Order> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Order {
    String model;
    int pk;
    Fields fields;

    Order({
        required this.model,
        required this.pk,
        required this.fields,
    });

    factory Order.fromJson(Map<String, dynamic> json) => Order(
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
    String orderId;
    String user;
    String restaurant;
    String notes;
    String paymentMethod;
    String totalPrice;
    DateTime createdAt;
    String promoCut;

    Fields({
        required this.orderId,
        required this.user,
        required this.restaurant,
        required this.notes,
        required this.paymentMethod,
        required this.totalPrice,
        required this.createdAt,
        required this.promoCut,
    });

    factory Fields.fromJson(Map<String, dynamic> json) => Fields(
        orderId: json["order_id"],
        user: json["user"],
        restaurant: json["restaurant"],
        notes: json["notes"],
        paymentMethod: json["payment_method"],
        totalPrice: json["total_price"],
        createdAt: DateTime.parse(json["created_at"]),
        promoCut: json["promo_cut"],
    );

    Map<String, dynamic> toJson() => {
        "order_id": orderId,
        "user": user,
        "restaurant": restaurant,
        "notes": notes,
        "payment_method": paymentMethod,
        "total_price": totalPrice,
        "created_at": createdAt.toIso8601String(),
        "promo_cut": promoCut,
    };
}


