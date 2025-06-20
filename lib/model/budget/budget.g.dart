// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'budget.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Budget _$BudgetFromJson(Map<String, dynamic> json) => Budget(
      json['id'] as String?,
      (json['amount'] as num?)?.toDouble(),
      json['startDate'] == null
          ? null
          : DateTime.parse(json['startDate'] as String),
      json['endDate'] == null
          ? null
          : DateTime.parse(json['endDate'] as String),
      json['userId'] as String?,
    );

Map<String, dynamic> _$BudgetToJson(Budget instance) => <String, dynamic>{
      'id': instance.id,
      'amount': instance.amount,
      'startDate': instance.startDate?.toIso8601String(),
      'endDate': instance.endDate?.toIso8601String(),
      'userId': instance.userId,
    };
