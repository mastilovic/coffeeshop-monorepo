// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_summary_dto.freezed.dart';
part 'user_summary_dto.g.dart';

@freezed
class UserSummaryDto with _$UserSummaryDto {
  const factory UserSummaryDto({
    required String id,
    required String name,
    String? username,
  }) = _UserSummaryDto;

  factory UserSummaryDto.fromJson(Map<String, dynamic> json) =>
      _$UserSummaryDtoFromJson(json);
}
