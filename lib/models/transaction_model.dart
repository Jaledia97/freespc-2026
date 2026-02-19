
class TransactionModel {
  final String id;
  final String userId;
  final String hallId;
  final String hallName;
  final double amount; // Positive for deposit/win, Negative for spend
  final String description; // e.g. "Raffle Win", "Ticket Purchase", "Daily Check-in"
  final DateTime timestamp;

  const TransactionModel({
    required this.id,
    required this.userId,
    required this.hallId,
    required this.hallName,
    required this.amount,
    required this.description,
    required this.timestamp,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      hallId: json['hallId'] ?? '',
      hallName: json['hallName'] ?? 'Unknown Hall',
      amount: (json['amount'] ?? 0).toDouble(),
      description: json['description'] ?? '',
      timestamp: json['timestamp'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(json['timestamp']) 
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'hallId': hallId,
      'hallName': hallName,
      'amount': amount,
      'description': description,
      'timestamp': timestamp.millisecondsSinceEpoch,
    };
  }
}
