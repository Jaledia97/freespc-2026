import '../../../models/squad_model.dart';
import '../../../models/bingo_hall_model.dart';

double calculateSquadBonus(
  SquadModel? userSquad,
  List<String> currentlyCheckedInUserIds,
  BingoHallModel hall,
) {
  if (userSquad == null) return 1.0;
  if (!userSquad.isValidSquad) return 1.0;
  if (!hall.squadBonusConfig.isSquadBonusActive) return 1.0;
  
  final config = hall.squadBonusConfig;
  final now = DateTime.now();
  if (config.startTime != null && now.isBefore(config.startTime!)) return 1.0;
  if (config.endTime != null && now.isAfter(config.endTime!)) return 1.0;

  int squadMembersCheckedIn = 0;
  for (String memberId in userSquad.memberIds) {
    if (currentlyCheckedInUserIds.contains(memberId)) {
      squadMembersCheckedIn++;
    }
  }

  // The 51% Rule: Greater than 50% of the squad must be checked in
  double percentage = squadMembersCheckedIn / userSquad.memberIds.length;
  if (percentage > 0.50) {
    return config.squadBonusMultiplier;
  }

  return 1.0;
}
