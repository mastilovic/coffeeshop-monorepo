// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'table_response_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$TableResponseDtoImpl _$$TableResponseDtoImplFromJson(
  Map<String, dynamic> json,
) => _$TableResponseDtoImpl(
  id: json['id'] as String,
  number: (json['number'] as num).toInt(),
  capacity: (json['capacity'] as num).toInt(),
  shopId: json['shopId'] as String?,
  reservations:
      (json['reservations'] as List<dynamic>?)
          ?.map((e) => e as Map<String, dynamic>)
          .toList() ??
      const [],
);

Map<String, dynamic> _$$TableResponseDtoImplToJson(
  _$TableResponseDtoImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'number': instance.number,
  'capacity': instance.capacity,
  'shopId': instance.shopId,
  'reservations': instance.reservations,
};

_$TableSummaryDtoImpl _$$TableSummaryDtoImplFromJson(
  Map<String, dynamic> json,
) => _$TableSummaryDtoImpl(
  id: json['id'] as String,
  number: (json['number'] as num).toInt(),
  capacity: (json['capacity'] as num).toInt(),
);

Map<String, dynamic> _$$TableSummaryDtoImplToJson(
  _$TableSummaryDtoImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'number': instance.number,
  'capacity': instance.capacity,
};

_$TableCreateRequestImpl _$$TableCreateRequestImplFromJson(
  Map<String, dynamic> json,
) => _$TableCreateRequestImpl(
  number: (json['number'] as num).toInt(),
  capacity: (json['capacity'] as num).toInt(),
  shopId: json['shopId'] as String,
);

Map<String, dynamic> _$$TableCreateRequestImplToJson(
  _$TableCreateRequestImpl instance,
) => <String, dynamic>{
  'number': instance.number,
  'capacity': instance.capacity,
  'shopId': instance.shopId,
};
