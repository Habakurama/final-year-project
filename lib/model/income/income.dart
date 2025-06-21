import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';

part 'income.g.dart';

@JsonSerializable()
class Income {
  @JsonKey(name: "id")
  final String? id;

  @JsonKey(name: "name")
  final String? name;

  @JsonKey(name: "amount")
  final double? amount;

  @JsonKey(name: "date")
  final DateTime? date;

  @JsonKey(name: "userId")
  final String? userId;

  @JsonKey(name: "emm")
  final bool shared; // ✅ NEW: shared field

  Income({
    required this.id,
    required this.name,
    required this.amount,
    required this.date,
    required this.userId,
    this.shared = false, // ✅ default to false if not provided
  });

  // ✅ From JSON: Convert Timestamp to DateTime and parse shared
  factory Income.fromJson(Map<String, dynamic> json) {
    return Income(
      id: json['id'] as String?,
      name: json['name'] as String?,
      amount: (json['amount'] as num?)?.toDouble(),
      date: (json['date'] as Timestamp?)?.toDate(),
      userId: json['userId'] as String?,
      shared: json['shared'] as bool? ?? false, // ✅ default to false if null
    );
  }

  // ✅ To JSON: Include shared
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'amount': amount,
      'date': date,
      'userId': userId,
      'shared': shared, // ✅ include in Firestore document
    };
  }
}
