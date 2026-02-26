import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../models/store_item_model.dart';
import '../../../store/repositories/store_repository.dart';
import 'edit_store_item_screen.dart';

class ManageStoreScreen extends ConsumerStatefulWidget {
  final String hallId;

  const ManageStoreScreen({super.key, required this.hallId});

  @override
  ConsumerState<ManageStoreScreen> createState() => _ManageStoreScreenState();
}

class _ManageStoreScreenState extends ConsumerState<ManageStoreScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    final itemsAsync = ref.watch(storeItemsProvider(widget.hallId));

    return Scaffold(
      backgroundColor: const Color(0xFF141414),
      appBar: AppBar(
        title: const Text('Manage Store'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.blueAccent,
          labelColor: Colors.blueAccent,
          unselectedLabelColor: Colors.white54,
          tabs: const [
             Tab(text: "Active"),
             Tab(text: "Drafts / Inactive"),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => EditStoreItemScreen(hallId: widget.hallId))),
        label: const Text("Add Item"),
        icon: const Icon(Icons.add),
        backgroundColor: Colors.blueAccent,
      ),
      body: itemsAsync.when(
        data: (items) {
          final activeItems = items.where((i) => i.isActive).toList();
          final inactiveItems = items.where((i) => !i.isActive).toList();

          return TabBarView(
            controller: _tabController,
            children: [
              _ItemsList(items: activeItems, hallId: widget.hallId, isDraftsTab: false),
              _ItemsList(items: inactiveItems, hallId: widget.hallId, isDraftsTab: true),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text("Error: $e", style: const TextStyle(color: Colors.red))),
      ),
    );
  }
}

class _ItemsList extends StatelessWidget {
  final List<StoreItemModel> items;
  final String hallId;
  final bool isDraftsTab;

  const _ItemsList({required this.items, required this.hallId, this.isDraftsTab = false});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
             const Icon(Icons.store_mall_directory, size: 64, color: Colors.white10),
             const SizedBox(height: 16),
             Text("No Items Here", style: TextStyle(color: Colors.white.withValues(alpha: 0.3))),
          ],
        ),
      );
    }

    // If not drafts tab, just render simple list
    if (!isDraftsTab) {
      return ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: items.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) => _buildItemCard(context, items[index]),
      );
    }

    // If Drafts tab, categorize them
    // A draft is considered anything missing a cost, title, or image (though our model requires title/img).
    // Let's rely on simple heuristic: If cost is 0 or title is 'New Item', etc.
    // Actually, maybe Drafts = "Inactive and cost == 0" or something similar? 
    // Wait, the user just wants the list visually separated if we can define Drafts vs Inactive.
    // Let's define Draft: cost == 0 OR description is empty. Otherwise, it's just 'Inactive' (ready but paused).
    final drafts = items.where((i) => i.cost == 0 || i.description.isEmpty).toList();
    final inactive = items.where((i) => i.cost > 0 && i.description.isNotEmpty).toList();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (drafts.isNotEmpty) ...[
          const Padding(
            padding: EdgeInsets.only(bottom: 12, left: 4),
            child: Text("Drafts (Incomplete)", style: TextStyle(color: Colors.white54, fontSize: 13, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
          ),
          ...drafts.map((item) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildItemCard(context, item),
          )),
          const SizedBox(height: 16),
        ],
        
        if (inactive.isNotEmpty) ...[
          const Padding(
            padding: EdgeInsets.only(bottom: 12, left: 4),
            child: Text("Inactive (Ready to Publish)", style: TextStyle(color: Colors.white54, fontSize: 13, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
          ),
          ...inactive.map((item) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildItemCard(context, item),
          )),
        ],
      ],
    );
  }

  Widget _buildItemCard(BuildContext context, StoreItemModel item) {
    return InkWell(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => EditStoreItemScreen(hallId: hallId, existingItem: item))),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E1E),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
        ),
        child: Row(
          children: [
            // Thumbnail
             Container(
               width: 60, height: 60,
               decoration: BoxDecoration(
                 borderRadius: BorderRadius.circular(8),
                 image: DecorationImage(image: NetworkImage(item.imageUrl), fit: BoxFit.cover),
               ),
             ),
             const SizedBox(width: 16),
             
             // Details
             Expanded(
               child: Column(
                 crossAxisAlignment: CrossAxisAlignment.start,
                 children: [
                    Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   Text(item.title, style: TextStyle(color: item.isActive ? Colors.white : Colors.white54, fontWeight: FontWeight.bold, fontSize: 16)),
                   if (item.perCustomerLimit != null)
                     Text("Limit: ${item.perCustomerLimit}/person", style: const TextStyle(color: Colors.amber, fontSize: 10)),
                   if (item.dailyLimit != null)
                     Text("Daily Max: ${item.dailyLimit}", style: const TextStyle(color: Colors.amber, fontSize: 10)),
                ],
              ),
                    const SizedBox(height: 4),
                    Text("${item.cost} PTS", style: const TextStyle(color: Colors.amberAccent, fontWeight: FontWeight.bold, fontSize: 12)),
                 ],
               ),
             ),
             
             const Icon(Icons.chevron_right, color: Colors.white24),
          ],
        ),
      ),
    );
  }
}
