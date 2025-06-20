// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'spending.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Spending _$SpendingFromJson(Map<String, dynamic> json) => Spending(
      id: json['id'] as String?,
      name: json['name'] as String?,
      amount: (json['amount'] as num?)?.toDouble(),
      date:
          json['date'] == null ? null : DateTime.parse(json['date'] as String),
      userId: json['userId'] as String?,
      expenseId: json['expenseId'] as String?,
    );

Map<String, dynamic> _$SpendingToJson(Spending instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'amount': instance.amount,
      'date': instance.date?.toIso8601String(),
      'userId': instance.userId,
      'expenseId': instance.expenseId,
    };
