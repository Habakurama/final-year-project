import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';

part 'budget.g.dart';

@JsonSerializable()
class Budget {
  @JsonKey(name: "id")
  final String? id;

  @JsonKey(name: "amount")
  final double? amount;

  @JsonKey(name: "startDate")
  final DateTime? startDate;

  @JsonKey(name: "endDate")
  final DateTime? endDate;

  @JsonKey(name: "userId")
  final String? userId;


  Budget(
      this.id,
      this.amount,
      this.startDate,
      this.endDate,
      this.userId,
      );

  factory Budget.fromJson(Map<String, dynamic> json) {
    return Budget(
      json['id'] as String?,
      (json['amount'] as num?)?.toDouble(),
      (json['startDate'] as Timestamp?)?.toDate(),
      (json['endDate'] as Timestamp?)?.toDate(),
      json['userId'] as String?,

    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'amount': amount,
      'startDate': startDate,
      'endDate': endDate,
      'userId': userId,

    };
  }
}
