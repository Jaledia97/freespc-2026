class TransactionModel {
  final String id;
  final String userId;
  final String venueId;
  final String venueName;
  final double amount; // Positive for deposit/win, Negative for spend
  final String
  description; // e.g. "Raffle Win", "Ticket Purchase", "Daily Check-in"
  final DateTime timestamp;

  const TransactionModel({
    required this.id,
    required this.userId,
    required this.venueId,
    required this.venueName,
    required this.amount,
    required this.description,
    required this.timestamp,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      venueId: json['venueId'] ?? '',
      venueName: json['venueName'] ?? 'Unknown Venue',
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
      'venueId': venueId,
      'venueName': venueName,
      'amount': amount,
      'description': description,
      'timestamp': timestamp.millisecondsSinceEpoch,
    };
  }
}
