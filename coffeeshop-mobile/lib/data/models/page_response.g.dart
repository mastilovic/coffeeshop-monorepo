// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'page_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PageResponseDtoImpl _$$PageResponseDtoImplFromJson(
  Map<String, dynamic> json,
) => _$PageResponseDtoImpl(
  content:
      (json['content'] as List<dynamic>?)
          ?.map((e) => e as Map<String, dynamic>)
          .toList() ??
      const [],
  page: (json['page'] as num).toInt(),
  size: (json['size'] as num).toInt(),
  totalElements: (json['totalElements'] as num).toInt(),
  totalPages: (json['totalPages'] as num).toInt(),
);

Map<String, dynamic> _$$PageResponseDtoImplToJson(
  _$PageResponseDtoImpl instance,
) => <String, dynamic>{
  'content': instance.content,
  'page': instance.page,
  'size': instance.size,
  'totalElements': instance.totalElements,
  'totalPages': instance.totalPages,
};
