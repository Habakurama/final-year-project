
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';

part 'spending.g.dart';
@JsonSerializable()
class Spending{

  @JsonKey(name: "id")
  final String? id;

  @JsonKey(name: "name")
  final String? name;

  @JsonKey(name: "amount")
  final double? amount;

  @JsonKey(name: "date")
  final DateTime? date;

  @JsonKey(name: "userId") // ADDED userId field
  final String? userId;

  @JsonKey(name: "expenseId") // ADDED userId field
  final String? expenseId;


  Spending( {
    required this.id,
    required this.name,
    required this.amount,
    required this.date,
    required this.userId,
    required this.expenseId,

  });

  // From JSON: Convert Timestamp to DateTime
  factory Spending.fromJson(Map<String, dynamic> json) {
    return Spending(
      id: json['id'] as String?,
      name: json['name'] as String?,
      amount: (json['amount'] as num?)?.toDouble(),
      date: (json['date'] as Timestamp?)?.toDate(),  // Convert Timestamp to DateTime
      userId: json['userId'] as String?,
      expenseId: json['expenseId'] as String?,
      // ADDED userId parsing
    );
  }

  // To JSON: Firestore expects DateTime as a Timestamp
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'amount': amount,
      'date': date,           // Firestore will convert DateTime to Timestamp
      'userId': userId,
      'expenseId':expenseId,

    };
  }

}