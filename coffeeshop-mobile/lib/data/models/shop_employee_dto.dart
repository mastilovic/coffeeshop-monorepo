// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';

part 'shop_employee_dto.freezed.dart';
part 'shop_employee_dto.g.dart';

@freezed
class ShopEmployeeDto with _$ShopEmployeeDto {
  const factory ShopEmployeeDto({
    @JsonKey(name: 'user_id') required String userId,
    @JsonKey(name: 'shop_id') required String shopId,
    required String name,
    required String email,
    @JsonKey(name: 'is_owner') @Default(false) bool isOwner,
  }) = _ShopEmployeeDto;

  factory ShopEmployeeDto.fromJson(Map<String, dynamic> json) =>
      _$ShopEmployeeDtoFromJson(json);
}

@freezed
class AssignEmployeeRequest with _$AssignEmployeeRequest {
  const factory AssignEmployeeRequest({
    @JsonKey(name: 'shop_id') required String shopId,
    @JsonKey(name: 'user_id') required String userId,
  }) = _AssignEmployeeRequest;

  factory AssignEmployeeRequest.fromJson(Map<String, dynamic> json) =>
      _$AssignEmployeeRequestFromJson(json);
}

@freezed
class RemoveEmployeeRequest with _$RemoveEmployeeRequest {
  const factory RemoveEmployeeRequest({
    @JsonKey(name: 'shop_id') required String shopId,
    @JsonKey(name: 'user_id') required String userId,
  }) = _RemoveEmployeeRequest;

  factory RemoveEmployeeRequest.fromJson(Map<String, dynamic> json) =>
      _$RemoveEmployeeRequestFromJson(json);
}
