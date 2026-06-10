// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_create_request.freezed.dart';
part 'user_create_request.g.dart';

@freezed
class UserCreateRequest with _$UserCreateRequest {
  const factory UserCreateRequest({
    required String name,
    required String username,
    required String email,
    String? password,
    @JsonKey(name: 'user_type') required String userType,
  }) = _UserCreateRequest;

  factory UserCreateRequest.fromJson(Map<String, dynamic> json) =>
      _$UserCreateRequestFromJson(json);
}
