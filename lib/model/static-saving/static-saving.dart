import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';

class StaticSaving {
  String? id;
  String userId;
  double amount;
  DateTime date;
  String type;
  String description;
  String source;
  double percentage;
  double? originalIncomeAmount; // The income amount this saving was deducted from
  DateTime createdAt;
  DateTime? updatedAt;

  StaticSaving({
    this.id,
    required this.userId,
    required this.amount,
    required this.date,
    this.type = 'automatic_deduction',
    this.description = 'Automatic 5% income deduction',
    this.source = 'income_update',
    this.percentage = 5.0,
    this.originalIncomeAmount,
    required this.createdAt,
    this.updatedAt,
  });

  // Convert StaticSaving object to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'amount': amount,
      'date': date.toIso8601String(),
      'type': type,
      'description': description,
      'source': source,
      'percentage': percentage,
      'originalIncomeAmount': originalIncomeAmount,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  // Create StaticSaving object from Firestore document
  factory StaticSaving.fromMap(Map<String, dynamic> map, {String? documentId}) {
    return StaticSaving(
      id: documentId,
      userId: map['userId'] ?? '',
      amount: _parseDouble(map['amount']),
      date: _parseDateTime(map['date']),
      type: map['type'] ?? 'automatic_deduction',
      description: map['description'] ?? 'Automatic 5% income deduction',
      source: map['source'] ?? 'income_update',
      percentage: _parseDouble(map['percentage']) != 0.0
          ? _parseDouble(map['percentage'])
          : 5.0,
      originalIncomeAmount: map['originalIncomeAmount'] != null
          ? _parseDouble(map['originalIncomeAmount'])
          : null,
      createdAt: _parseDateTime(map['createdAt']),
      updatedAt: map['updatedAt'] != null
          ? _parseDateTime(map['updatedAt'])
          : null,
    );
  }

  // Create StaticSaving from Firestore DocumentSnapshot
  factory StaticSaving.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return StaticSaving.fromMap(data, documentId: doc.id);
  }

  // Helper method to safely parse double values
  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  // Helper method to safely parse DateTime values
  static DateTime _parseDateTime(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is DateTime) return value;
    if (value is String) {
      try {
        return DateTime.parse(value);
      } catch (e) {
        return DateTime.now();
      }
    }
    if (value is Timestamp) return value.toDate();
    return DateTime.now();
  }

  // Create a copy of StaticSaving with updated fields
  StaticSaving copyWith({
    String? id,
    String? userId,
    double? amount,
    DateTime? date,
    String? type,
    String? description,
    String? source,
    double? percentage,
    double? originalIncomeAmount,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return StaticSaving(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      type: type ?? this.type,
      description: description ?? this.description,
      source: source ?? this.source,
      percentage: percentage ?? this.percentage,
      originalIncomeAmount: originalIncomeAmount ?? this.originalIncomeAmount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Convert to JSON string
  String toJson() {
    return jsonEncode(toMap());
  }

  // Create from JSON string
  factory StaticSaving.fromJson(String jsonString) {
    return StaticSaving.fromMap(jsonDecode(jsonString));
  }

  // Get formatted amount string
  String get formattedAmount => "${amount.toStringAsFixed(2)} Frw";

  // Get formatted date string
  String get formattedDate {
    return "${date.day}/${date.month}/${date.year}";
  }

  // Get formatted percentage string
  String get formattedPercentage => "${percentage.toStringAsFixed(1)}%";

  // Check if this static saving was created today
  bool get isToday {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  // Check if this static saving was created this month
  bool get isThisMonth {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month;
  }

  // Get age of this static saving in days
  int get ageInDays {
    return DateTime.now().difference(date).inDays;
  }

  @override
  String toString() {
    return 'StaticSaving{id: $id, userId: $userId, amount: $amount, date: $date, type: $type, percentage: $percentage}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is StaticSaving &&
        other.id == id &&
        other.userId == userId &&
        other.amount == amount &&
        other.date == date &&
        other.type == type &&
        other.percentage == percentage;
  }

  @override
  int get hashCode {
    return id.hashCode ^
    userId.hashCode ^
    amount.hashCode ^
    date.hashCode ^
    type.hashCode ^
    percentage.hashCode;
  }
}