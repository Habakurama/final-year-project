// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'income.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Income _$IncomeFromJson(Map<String, dynamic> json) => Income(
      id: json['id'] as String?,
      name: json['name'] as String?,
      amount: (json['amount'] as num?)?.toDouble(),
      date:
          json['date'] == null ? null : DateTime.parse(json['date'] as String),
      userId: json['userId'] as String?,
         shared: json['shared'] as bool? ?? true, 
    );

Map<String, dynamic> _$IncomeToJson(Income instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'amount': instance.amount,
      'date': instance.date?.toIso8601String(),
      'userId': instance.userId,
      'shared': instance.shared, 
    };
