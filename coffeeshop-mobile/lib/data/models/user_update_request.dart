// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_update_request.freezed.dart';
part 'user_update_request.g.dart';

@freezed
class UserUpdateRequest with _$UserUpdateRequest {
  const factory UserUpdateRequest({
    required String name,
    String? username,
    String? email,
    String? password,
    required String userType,
  }) = _UserUpdateRequest;

  factory UserUpdateRequest.fromJson(Map<String, dynamic> json) =>
      _$UserUpdateRequestFromJson(json);
}
