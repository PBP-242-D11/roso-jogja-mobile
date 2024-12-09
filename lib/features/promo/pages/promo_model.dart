// To parse this JSON data, do
//
//     final promo = promoFromJson(jsonString);

import 'dart:convert';

Promo promoFromJson(String str) => Promo.fromJson(json.decode(str));

String promoToJson(Promo data) => json.encode(data.toJson());

class Promo {
    List<PromoElement> promos;
    List<dynamic> otherPromos;
    String message;

    Promo({
        required this.promos,
        required this.otherPromos,
        required this.message,
    });

    factory Promo.fromJson(Map<String, dynamic> json) => Promo(
        promos: List<PromoElement>.from(json["promos"].map((x) => PromoElement.fromJson(x))),
        otherPromos: List<dynamic>.from(json["other_promos"].map((x) => x)),
        message: json["message"],
    );

    Map<String, dynamic> toJson() => {
        "promos": List<dynamic>.from(promos.map((x) => x.toJson())),
        "other_promos": List<dynamic>.from(otherPromos.map((x) => x)),
        "message": message,
    };
}

class PromoElement {
    String userId;
    String id;
    String type;
    int value;
    int minPayment;
    String promoCode;
    DateTime expiryDate;
    int maxUsage;
    bool shownToPublic;

    PromoElement({
        required this.userId,
        required this.id,
        required this.type,
        required this.value,
        required this.minPayment,
        required this.promoCode,
        required this.expiryDate,
        required this.maxUsage,
        required this.shownToPublic,
    });

    factory PromoElement.fromJson(Map<String, dynamic> json) => PromoElement(
        userId: json["user_id"],
        id: json["id"],
        type: json["type"],
        value: json["value"],
        minPayment: json["min_payment"],
        promoCode: json["promo_code"],
        expiryDate: DateTime.parse(json["expiry_date"]),
        maxUsage: json["max_usage"],
        shownToPublic: json["shown_to_public"],
    );

    Map<String, dynamic> toJson() => {
        "user_id": userId,
        "id": id,
        "type": type,
        "value": value,
        "min_payment": minPayment,
        "promo_code": promoCode,
        "expiry_date": "${expiryDate.year.toString().padLeft(4, '0')}-${expiryDate.month.toString().padLeft(2, '0')}-${expiryDate.day.toString().padLeft(2, '0')}",
        "max_usage": maxUsage,
        "shown_to_public": shownToPublic,
    };
}
