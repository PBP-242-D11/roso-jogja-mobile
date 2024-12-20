import 'dart:convert';

OrderResponse orderResponseFromJson(String str) => OrderResponse.fromJson(json.decode(str));

class OrderResponse {
  final int totalOrder;
  final String totalSpent;
  final List<FlutterOrder> orders;

  OrderResponse({
    required this.totalOrder,
    required this.totalSpent,
    required this.orders,
  });

  factory OrderResponse.fromJson(Map<String, dynamic> json) {
    return OrderResponse(
      totalOrder: json["total_order"] ?? 0,
      totalSpent: json["total_spent"] ?? "0",
      orders: json["orders"] == null
          ? []
          : List<FlutterOrder>.from(json["orders"].map((x) => FlutterOrder.fromJson(x))),
    );
  }
}

class FlutterOrder {
  final String id;
  final String notes;
  final String paymentMethod;
  final String totalPrice;
  final String promoCut;
  final String restaurant;
  final String createdAt;
  final List<FlutterOrderItem> orderItems;

  FlutterOrder({
    required this.id,
    required this.notes,
    required this.paymentMethod,
    required this.totalPrice,
    required this.promoCut,
    required this.restaurant,
    required this.createdAt,
    required this.orderItems,
  });

  factory FlutterOrder.fromJson(Map<String, dynamic> json) {
    return FlutterOrder(
      id: json["id"] ?? "",
      notes: json["notes"] ?? "",
      paymentMethod: json["payment_method"] ?? "",
      totalPrice: json["total_price"] ?? "0",
      promoCut: json["promo_cut"] ?? "0",
      restaurant: json["restaurant"] ?? "",
      createdAt: json["created_at"] ?? "",
      orderItems: json["order_items"] == null
          ? []
          : List<FlutterOrderItem>.from(json["order_items"].map((x) => FlutterOrderItem.fromJson(x))),
    );
  }
}

class FlutterOrderItem {
  final String foodName;
  final String quantity;
  final String priceAtOrder;

  FlutterOrderItem({
    required this.foodName,
    required this.quantity,
    required this.priceAtOrder,
  });

  factory FlutterOrderItem.fromJson(Map<String, dynamic> json) {
    return FlutterOrderItem(
      foodName: json["food_name"] ?? "",
      quantity: json["quantity"] ?? "0",
      priceAtOrder: json["price_at_order"] ?? "0",
    );
  }
}