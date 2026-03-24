import 'package:freezed_annotation/freezed_annotation.dart';

part 'squad_model.freezed.dart';
part 'squad_model.g.dart';

@freezed
abstract class SquadModel with _$SquadModel {
  const SquadModel._();

  const factory SquadModel({
    required String id,
    required String name,
    @Default([]) List<String> memberIds,
    required String captainId,
  }) = _SquadModel;

  factory SquadModel.fromJson(Map<String, dynamic> json) =>
      _$SquadModelFromJson(json);

  bool get isValidSquad => memberIds.length >= 5;
}
