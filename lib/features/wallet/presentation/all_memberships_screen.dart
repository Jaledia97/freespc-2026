import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../wallet/repositories/wallet_repository.dart';
import '../../../models/venue_membership_model.dart';
import '../../home/repositories/venue_repository.dart';
import 'wallet_screen.dart'; // Import focusedMembershipProvider

class AllMembershipsScreen extends ConsumerStatefulWidget {
  final String userId;
  const AllMembershipsScreen({super.key, required this.userId});

  @override
  ConsumerState<AllMembershipsScreen> createState() => _AllMembershipsScreenState();
}

class _AllMembershipsScreenState extends ConsumerState<AllMembershipsScreen> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final membershipsAsync = ref.watch(myMembershipsStreamProvider(widget.userId));

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: const Text('All Memberships'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Search & Filter Row
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    onChanged: (val) => setState(() => _searchQuery = val.toLowerCase()),
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: "Search places...",
                      hintStyle: const TextStyle(color: Colors.white54),
                      prefixIcon: const Icon(Icons.search, color: Colors.white54),
                      filled: true,
                      fillColor: Colors.white10,
                      contentPadding: const EdgeInsets.symmetric(vertical: 0),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white10,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.filter_list, color: Colors.white),
                    onPressed: () {
                      // Alpha filter is default for now.
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Filtered A-Z')),
                      );
                    },
                  ),
                )
              ],
            ),
          ),

          // Grid View
          Expanded(
            child: membershipsAsync.when(
              data: (memberships) {
                // Apply Search and sort Alphabetically by default
                var filtered = memberships.where((m) {
                  return m.venueName.toLowerCase().contains(_searchQuery);
                }).toList();
                
                filtered.sort((a, b) => a.venueName.compareTo(b.venueName));

                if (filtered.isEmpty) {
                  return const Center(child: Text("No memberships found.", style: TextStyle(color: Colors.white54)));
                }

                return GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 220,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 0.85,
                  ),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    return _CompactMembershipCard(membership: filtered[index]);
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('Error: $err', style: const TextStyle(color: Colors.red))),
            ),
          ),
        ],
      ),
    );
  }
}

class _CompactMembershipCard extends ConsumerWidget {
  final VenueMembershipModel membership;
  const _CompactMembershipCard({required this.membership});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hallAsync = ref.watch(venueStreamProvider(membership.venueId));

    return hallAsync.when(
      data: (venue) {
        final venueName = venue?.name ?? membership.venueName;
        final logoUrl = venue?.logoUrl ?? membership.bannerUrl;

        return GestureDetector(
          onTap: () {
            ref.read(focusedMembershipProvider.notifier).state = membership;
            Navigator.of(context).pop();
          },
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E1E),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white12),
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Avatar
                CircleAvatar(
                radius: 28,
                backgroundColor: Colors.amber.withOpacity(0.2),
                backgroundImage: logoUrl != null ? NetworkImage(logoUrl) : null,
                child: logoUrl == null 
                  ? Text(
                      venueName.isNotEmpty ? venueName[0].toUpperCase() : '?',
                      style: const TextStyle(color: Colors.amber, fontSize: 24, fontWeight: FontWeight.bold),
                    )
                  : null,
              ),
              const SizedBox(height: 12),
              
              // Name
              Text(
                venueName,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              
              // Distance Mock
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.location_on, size: 12, color: Colors.white54),
                  const SizedBox(width: 4),
                  Text(
                    "1.2 mi",
                    style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 11),
                  ),
                ],
              ),
              const Spacer(),
              
              // Points Balance
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.black38,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      NumberFormat.compact().format(membership.balance),
                      style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    const SizedBox(width: 4),
                    const Text("PT", style: TextStyle(color: Colors.white54, fontSize: 10)),
                  ],
                ),
              ),
            ],
          ), // Closes Column
        ), // Closes Container
        ); // Closes GestureDetector
      },
      loading: () => Container(
        decoration: BoxDecoration(
          color: Colors.white10,
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Container(
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Icon(Icons.error, color: Colors.red),
      ),
    );
  }
}
