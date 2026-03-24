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
    String? ownerId, // The creator/admin of the group chat
    required List<String> participantIds,
    @Default([])
    List<String>
    pendingParticipantIds, // Users added by non-owners waiting for owner approval
    @Default({})
    Map<String, String> participantNames, // Denormalized for 0-read UI
    @Default('') String lastMessage,
    required DateTime lastMessageAt,
    @Default('') String lastMessageSenderId,
    @Default({}) Map<String, int> unreadCounts,
    @Default([]) List<String> mutedBy, // Array of User IDs who muted this chat
    @Default([])
    List<String> deletedBy, // Array of User IDs who deleted/hid this chat
    @Default([]) List<String> isTyping, // Array of User IDs currently typing
    @Default({})
    Map<String, String> clearedAt, // UserID to ISO8601 deletion timestamp
  }) = _ChatModel;

  factory ChatModel.fromJson(Map<String, Object?> json) =>
      _$ChatModelFromJson(json);
}
