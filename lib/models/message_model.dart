import 'package:freezed_annotation/freezed_annotation.dart';

part 'message_model.freezed.dart';
part 'message_model.g.dart';

@freezed
abstract class MessageModel with _$MessageModel {
  const MessageModel._();

  const factory MessageModel({
    required String id,
    required String chatId,
    required String senderId,
    required String text,
    required DateTime createdAt,
    // Reply data
    String? replyToMessageId,
    String? replyToText,
    String? replyToSenderName,
    // Rich Embedded Widget data
    String? payloadType, // 'tournament', 'raffle', etc
    String? payloadId,
  }) = _MessageModel;

  factory MessageModel.fromJson(Map<String, Object?> json) =>
      _$MessageModelFromJson(json);
}
