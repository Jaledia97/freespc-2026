import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../store/repositories/store_repository.dart';
import '../../../models/store_item_model.dart';
import '../../../../core/widgets/glass_container.dart'; // Optional usage
import '../../../services/auth_service.dart';
import '../../wallet/services/transaction_service.dart';

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

class _StoreItemCard extends ConsumerStatefulWidget {
  final StoreItemModel item;
  const _StoreItemCard({required this.item});

  @override
  ConsumerState<_StoreItemCard> createState() => _StoreItemCardState();
}

class _StoreItemCardState extends ConsumerState<_StoreItemCard> {
  int _quantity = 1;
  bool _isLoading = false;

  void _increment() {
    final limit = widget.item.perCustomerLimit;
    if (limit != null && _quantity >= limit) return;
    setState(() => _quantity++);
  }

  void _decrement() {
    if (_quantity > 1) {
      setState(() => _quantity--);
    }
  }

  Future<void> _redeem() async {
    final user = ref.read(userProfileProvider).value;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Error: User not found.")));
      return;
    }

    setState(() => _isLoading = true);

    try {
      final totalCost = widget.item.cost * _quantity;
      await ref.read(transactionServiceProvider).redeemItem(
        userId: user.uid,
        hallId: widget.item.hallId,
        itemId: widget.item.id,
        itemName: widget.item.title,
        quantity: _quantity,
        totalCost: totalCost,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Successfully redeemed ${_quantity}x ${widget.item.title}!"),
          backgroundColor: Colors.green,
        ));
        // Reset quantity
        setState(() => _quantity = 1);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(e.toString().replaceAll("Exception: ", "")),
          backgroundColor: Colors.redAccent,
        ));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final limit = widget.item.perCustomerLimit;
    final isMax = limit != null && _quantity >= limit;
    final isMin = _quantity <= 1;
    final isLimitOne = limit == 1;

    final totalCost = widget.item.cost * _quantity;

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
                imageUrl: widget.item.imageUrl,
                fit: BoxFit.cover,
                placeholder: (_,__) => Container(color: Colors.grey[900]),
                errorWidget: (_,__,___) => const Icon(Icons.broken_image, color: Colors.grey),
              ),
            ),
          ),
          
          // Content
          Expanded(
            flex: 3,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(widget.item.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.white), maxLines: 1, overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 2),
                      Text(widget.item.description, style: const TextStyle(color: Colors.white54, fontSize: 10), maxLines: 2, overflow: TextOverflow.ellipsis),
                      if (limit != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Text("Limit: $limit per person", style: const TextStyle(color: Colors.redAccent, fontSize: 9, fontStyle: FontStyle.italic)),
                        ),
                    ],
                  ),
                  
                  // Quantity Picker
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      InkWell(
                        onTap: (isMin || isLimitOne) ? null : _decrement,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: (isMin || isLimitOne) ? Colors.white12 : Colors.white24,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Icon(Icons.remove, size: 14, color: (isMin || isLimitOne) ? Colors.white38 : Colors.white),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text("$_quantity", style: TextStyle(color: isLimitOne ? Colors.white54 : Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                      ),
                      InkWell(
                        onTap: (isMax || isLimitOne) ? null : _increment,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: (isMax || isLimitOne) ? Colors.white12 : Colors.white24,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Icon(Icons.add, size: 14, color: (isMax || isLimitOne) ? Colors.white38 : Colors.white),
                        ),
                      ),
                    ],
                  ),

                  // Cost & Redeem
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("$totalCost PTS", style: const TextStyle(color: Colors.amberAccent, fontWeight: FontWeight.bold, fontSize: 13)),
                      _isLoading 
                        ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2))
                        : InkWell(
                            onTap: _redeem,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.blueAccent,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Text("GET", style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
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
