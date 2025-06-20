import 'package:cloud_firestore/cloud_firestore.dart';

class Expense {
  final String? id;
  final String? category;
  final double? amount;
  final DateTime? date;
  final String? userId;
  final double? remaining;
  final double? used;
  
  Expense({
    required this.id,
    required this.category,
    required this.amount,
    required this.date,
    required this.userId,
    this.remaining,  // Optional field
    this.used,       // Optional field
  });
  
  // From JSON: Convert Timestamp to DateTime and ensure proper double conversion
  factory Expense.fromJson(Map<String, dynamic> json) {
    return Expense(
      id: json['id'] as String?,
      category: json['category'] as String?,
      amount: (json['amount'] as num?)?.toDouble(),
      date: (json['date'] as Timestamp?)?.toDate(),  // Convert Timestamp to DateTime
      userId: json['userId'] as String?,
      remaining: (json['remaining'] as num?)?.toDouble(),
      used: (json['used'] as num?)?.toDouble(),
    );
  }
  
  // To JSON: Firestore expects DateTime as a Timestamp
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'category': category,
      'amount': amount,
      'date': date,  // Firestore will convert DateTime to Timestamp
      'userId': userId,
      'remaining': remaining,
      'used': used,
    };
  }
  
  // Helper method to calculate remaining amount
  double get calculatedRemaining {
    if (amount == null || used == null) return 0.0;
    return amount! - used!;
  }
  
  // Helper method to calculate used percentage
  double get usedPercentage {
    if (amount == null || amount == 0 || used == null) return 0.0;
    return (used! / amount!) * 100;
  }
  
  // Helper method to create a copy with updated values
  Expense copyWith({
    String? id,
    String? category,
    double? amount,
    DateTime? date,
    String? userId,
    double? remaining,
    double? used,
  }) {
    return Expense(
      id: id ?? this.id,
      category: category ?? this.category,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      userId: userId ?? this.userId,
      remaining: remaining ?? this.remaining,
      used: used ?? this.used,
    );
  }
}