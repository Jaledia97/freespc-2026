import 'package:freezed_annotation/freezed_annotation.dart';

part 'chat_model.freezed.dart';
part 'chat_model.g.dart';

@freezed
abstract class ChatModel with _$ChatModel {
  const ChatModel._();

  const factory ChatModel({
    required String id,
    String? name, // Null for 1-on-1, string for groups
    required bool isGroup,
    required List<String> participantIds,
    @Default({}) Map<String, String> participantNames, // Denormalized for 0-read UI
    @Default('') String lastMessage,
    required DateTime lastMessageAt,
    @Default('') String lastMessageSenderId,
    @Default({}) Map<String, int> unreadCounts,
    @Default([]) List<String> mutedBy, // Array of User IDs who muted this chat
  }) = _ChatModel;

  factory ChatModel.fromJson(Map<String, Object?> json) => _$ChatModelFromJson(json);
}
