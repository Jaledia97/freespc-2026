
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:freespc/features/wallet/repositories/wallet_repository.dart';
import 'package:freespc/models/transaction_model.dart';

class TransactionHistoryList extends ConsumerWidget {
  final String userId;
  const TransactionHistoryList({super.key, required this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Correctly watch the provider. It's defined in wallet_repository.dart
    final txAsync = ref.watch(myTransactionsStreamProvider(userId));

    return txAsync.when(
      data: (transactions) {
        if (transactions.isEmpty) {
          return const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Text("No transactions yet.", style: TextStyle(color: Colors.white38)),
          );
        }

        // Group by Date + Hall (A "Visit")
        // Logic: Transactions on the same day at the same hall are grouped.
        final groupedVisits = <String, List<TransactionModel>>{};
        
        for (var tx in transactions) {
          final dateKey = DateFormat('yyyy-MM-dd').format(tx.timestamp);
          final key = "$dateKey|${tx.hallName}"; // Format: 2026-02-18|Mary Esther Bingo
          
          if (!groupedVisits.containsKey(key)) {
            groupedVisits[key] = [];
          }
          groupedVisits[key]!.add(tx);
        }

        // Convert Map to List for display
        final visitKeys = groupedVisits.keys.toList();

        return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: visitKeys.length,
          separatorBuilder: (c, i) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final key = visitKeys[index];
            final visitTx = groupedVisits[key]!;
            final parts = key.split('|');
            final dateStr = parts[0];
            final hallName = parts[1];
            
            final date = DateTime.parse(dateStr);
            final formattedDate = _isToday(date) ? "Today" : _isYesterday(date) ? "Yesterday" : DateFormat('MMM d, y').format(date);

            // Calculate Net Change for this visit
            final netChange = visitTx.fold(0.0, (sum, tx) => sum + tx.amount);
            final isPositive = netChange >= 0;

            return ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Theme(
                data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                child: ExpansionTile(
                  collapsedBackgroundColor: const Color(0xFF1E1E1E),
                  backgroundColor: const Color(0xFF252525),
                  title: Text(hallName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  subtitle: Text("$formattedDate • ${visitTx.length} Activities", style: const TextStyle(color: Colors.white54, fontSize: 12)),
                  trailing: Container(
                     padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                     decoration: BoxDecoration(
                       color: isPositive ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                       borderRadius: BorderRadius.circular(8),
                     ),
                     child: Text(
                       "${isPositive ? '+' : ''}${netChange.toStringAsFixed(0)}",
                       style: TextStyle(color: isPositive ? Colors.green : Colors.red, fontWeight: FontWeight.bold),
                     ),
                  ),
                  children: visitTx.map<Widget>((tx) { // Explicitly type map<Widget>
                    final txPositive = tx.amount >= 0;
                    return ListTile(
                      dense: true,
                      contentPadding: const EdgeInsets.only(left: 16, right: 16, bottom: 4),
                      visualDensity: VisualDensity.compact,
                      title: Text(tx.description, style: const TextStyle(color: Colors.white70)),
                      subtitle: Text(DateFormat('h:mm a').format(tx.timestamp), style: const TextStyle(color: Colors.white38, fontSize: 10)),
                      trailing: Text(
                        "${txPositive ? '+' : ''}${tx.amount.toStringAsFixed(0)}",
                         style: TextStyle(color: txPositive ? Colors.greenAccent : Colors.redAccent, fontSize: 12),
                      ),
                    );
                  }).toList(),
                ),
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, s) => SizedBox(child: Text("Error: $e", style: const TextStyle(color: Colors.red))),
    );
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return now.year == date.year && now.month == date.month && now.day == date.day;
  }
  
  bool _isYesterday(DateTime date) {
      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      return yesterday.year == date.year && yesterday.month == date.month && yesterday.day == date.day;
  }
}
