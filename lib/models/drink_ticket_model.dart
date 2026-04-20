import 'package:freezed_annotation/freezed_annotation.dart';

part 'drink_ticket_model.freezed.dart';
part 'drink_ticket_model.g.dart';

@freezed
abstract class DrinkTicketModel with _$DrinkTicketModel {
  const DrinkTicketModel._();

  @JsonSerializable(explicitToJson: true)
  const factory DrinkTicketModel({
    required String id,
    required String userId,
    required String venueId,
    required String venueName,
    required String title,
    required String description,
    required DateTime issuedAt,
    DateTime? expiresAt,
    @Default(true) bool isValid,
    String? imageUrl,
  }) = _DrinkTicketModel;

  factory DrinkTicketModel.fromJson(Map<String, Object?> json) =>
      _$DrinkTicketModelFromJson(json);
}
