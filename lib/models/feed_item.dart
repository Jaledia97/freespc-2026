import 'package:freezed_annotation/freezed_annotation.dart';

import 'check_in_model.dart';
import 'raffle_model.dart';
import 'special_model.dart';
import 'tournament_model.dart';
import 'win_post_model.dart';
import 'text_post_model.dart';
import 'trivia_model.dart';

part 'feed_item.freezed.dart';

@freezed
sealed class FeedItem with _$FeedItem {
  const FeedItem._();

  const factory FeedItem.tournament(TournamentModel data) = _FeedItemTournament;
  const factory FeedItem.raffle(RaffleModel data) = _FeedItemRaffle;
  const factory FeedItem.special(SpecialModel data) = _FeedItemSpecial;
  const factory FeedItem.checkIn(CheckInModel data) = _FeedItemCheckIn;
  const factory FeedItem.winPost(WinPostModel data) = _FeedItemWinPost;
  const factory FeedItem.textPost(TextPostModel data) = _FeedItemTextPost;
  const factory FeedItem.trivia(TriviaModel data) = _FeedItemTrivia;
}
