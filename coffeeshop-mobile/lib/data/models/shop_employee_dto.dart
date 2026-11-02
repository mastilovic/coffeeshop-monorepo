// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';

part 'shop_employee_dto.freezed.dart';
part 'shop_employee_dto.g.dart';

@freezed
class ShopEmployeeDto with _$ShopEmployeeDto {
  const factory ShopEmployeeDto({
    required String userId,
    required String shopId,
    required String name,
    required String email,
    @Default(false) bool isOwner,
  }) = _ShopEmployeeDto;

  factory ShopEmployeeDto.fromJson(Map<String, dynamic> json) =>
      _$ShopEmployeeDtoFromJson(json);
}

@freezed
class AssignEmployeeRequest with _$AssignEmployeeRequest {
  const factory AssignEmployeeRequest({
    required String shopId,
    required String userId,
  }) = _AssignEmployeeRequest;

  factory AssignEmployeeRequest.fromJson(Map<String, dynamic> json) =>
      _$AssignEmployeeRequestFromJson(json);
}

@freezed
class RemoveEmployeeRequest with _$RemoveEmployeeRequest {
  const factory RemoveEmployeeRequest({
    required String shopId,
    required String userId,
  }) = _RemoveEmployeeRequest;

  factory RemoveEmployeeRequest.fromJson(Map<String, dynamic> json) =>
      _$RemoveEmployeeRequestFromJson(json);
}
