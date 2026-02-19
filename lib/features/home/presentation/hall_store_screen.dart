import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../store/repositories/store_repository.dart';
import '../../../models/store_item_model.dart';
import '../../../../core/widgets/glass_container.dart'; // Optional usage

class HallStoreScreen extends ConsumerStatefulWidget {
  final String hallId;
  final String hallName;

  const HallStoreScreen({super.key, required this.hallId, required this.hallName});

  @override
  ConsumerState<HallStoreScreen> createState() => _HallStoreScreenState();
}

class _HallStoreScreenState extends ConsumerState<HallStoreScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<String> _categories = ['All', 'Merchandise', 'Food & Beverage', 'Sessions', 'Pull Tabs', 'Electronics', 'Other'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _categories.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Fetch all active items
    final activeItemsStream = ref.watch(storeRepositoryProvider).getActiveStoreItems(widget.hallId);

    return Scaffold(
      backgroundColor: const Color(0xFF141414),
      appBar: AppBar(
        title: Text("${widget.hallName} Store"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          labelColor: Colors.blueAccent,
          unselectedLabelColor: Colors.grey,
          indicatorColor: Colors.blueAccent,
          tabAlignment: TabAlignment.start,
          tabs: _categories.map((c) => Tab(text: c)).toList(),
        ),
      ),
      body: StreamBuilder<List<StoreItemModel>>(
        stream: activeItemsStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
             return Center(child: Text("Error: ${snapshot.error}", style: const TextStyle(color: Colors.white)));
          }

          final allItems = snapshot.data ?? [];

          return TabBarView(
            controller: _tabController,
            children: _categories.map((category) {
              // Filter items
              final filtered = category == 'All' 
                  ? allItems 
                  : allItems.where((item) => item.category == category).toList();
              
              if (filtered.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.category_outlined, size: 64, color: Colors.white12),
                      const SizedBox(height: 16),
                      Text("No items in $category", style: const TextStyle(color: Colors.white54)),
                    ],
                  ),
                );
              }

              return GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.75,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: filtered.length,
                itemBuilder: (context, index) {
                  return _StoreItemCard(item: filtered[index]);
                },
              );
            }).toList(),
          );
        },
      ),
    );
  }
}

class _StoreItemCard extends StatelessWidget {
  final StoreItemModel item;
  const _StoreItemCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4)),
        ],
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Image
          Expanded(
            flex: 3,
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: CachedNetworkImage(
                imageUrl: item.imageUrl,
                fit: BoxFit.cover,
                placeholder: (_,__) => Container(color: Colors.grey[900]),
                errorWidget: (_,__,___) => const Icon(Icons.broken_image, color: Colors.grey),
              ),
            ),
          ),
          
          // Content
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.white), maxLines: 1, overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 4),
                      Text(item.description, style: const TextStyle(color: Colors.white54, fontSize: 10), maxLines: 2, overflow: TextOverflow.ellipsis),
                      if (item.perCustomerLimit != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text("Limit: ${item.perCustomerLimit} per person", style: const TextStyle(color: Colors.redAccent, fontSize: 9, fontStyle: FontStyle.italic)),
                        ),
                    ],
                  ),
                  
                  // Cost & Redeem
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("${item.cost} PTS", style: const TextStyle(color: Colors.amberAccent, fontWeight: FontWeight.bold, fontSize: 12)),
                      InkWell(
                        onTap: () {
                           ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Redemption logic coming soon!")));
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.blueAccent,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text("GET", style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
