import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/widgets/glass_container.dart';
import '../../../models/venue_claim_model.dart';
import '../repositories/admin_repository.dart';
import 'package:cached_network_image/cached_network_image.dart';

class SuperadminDashboardScreen extends ConsumerWidget {
  const SuperadminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final claimsAsync = ref.watch(pendingClaimsProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Superadmin Dashboard', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.black,
      ),
      body: claimsAsync.when(
        data: (claims) {
          if (claims.isEmpty) {
            return const Center(
              child: Text(
                "No pending claims.",
                style: TextStyle(color: Colors.white54, fontSize: 16),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.only(bottom: 100, top: 16, left: 16, right: 16),
            itemCount: claims.length,
            separatorBuilder: (_, __) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              return _VenueClaimCard(claim: claims[index]);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator(color: Colors.blueAccent)),
        error: (error, _) => Center(child: Text("Error: \$error", style: const TextStyle(color: Colors.red))),
      ),
    );
  }
}

class _VenueClaimCard extends ConsumerStatefulWidget {
  final VenueClaimModel claim;

  const _VenueClaimCard({required this.claim});

  @override
  ConsumerState<_VenueClaimCard> createState() => _VenueClaimCardState();
}

class _VenueClaimCardState extends ConsumerState<_VenueClaimCard> {
  bool _isProcessing = false;

  void _handleAction(bool approve) async {
    setState(() => _isProcessing = true);
    try {
      if (approve) {
        await ref.read(adminRepositoryProvider).approveClaim(widget.claim.id);
      } else {
        await ref.read(adminRepositoryProvider).rejectClaim(widget.claim.id);
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(approve ? "Claim Approved" : "Claim Rejected"),
            backgroundColor: approve ? Colors.green : Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: \$e"), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  void _viewEvidence() {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        child: GlassContainer(
          borderRadius: BorderRadius.circular(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Align(
                alignment: Alignment.topRight,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              CachedNetworkImage(
                imageUrl: widget.claim.evidenceUrl,
                fit: BoxFit.contain,
                placeholder: (context, url) => const Padding(
                  padding: EdgeInsets.all(48.0),
                  child: CircularProgressIndicator(color: Colors.blueAccent),
                ),
                errorWidget: (context, url, error) => const Padding(
                  padding: EdgeInsets.all(48.0),
                  child: Icon(Icons.broken_image, color: Colors.white54, size: 48),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.businessCenter, color: Colors.blueAccent, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    "Venue ID: \${widget.claim.requestedVenueId}",
                    style: const TextStyle(color: Colors.white, fontWeight: superBold, fontSize: 16),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              "User ID: \${widget.claim.userId}",
              style: const TextStyle(color: Colors.white54, fontSize: 13),
            ),
            Text(
              "Submitted: \${widget.claim.submittedAt.toLocal().toString().split('.').first}",
              style: const TextStyle(color: Colors.white54, fontSize: 13),
            ),
            const SizedBox(height: 16),
            const Divider(color: Colors.white12),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.blueAccent.withOpacity(0.5)),
                      foregroundColor: Colors.blueAccent,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: _viewEvidence,
                    icon: const Icon(Icons.visibility, size: 16),
                    label: const Text("Evidence", style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(width: 12),
                if (_isProcessing)
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24.0),
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.blueAccent),
                    ),
                  )
                else ...[
                  IconButton(
                    style: IconButton.styleFrom(backgroundColor: Colors.green.withOpacity(0.1)),
                    icon: const Icon(Icons.check, color: Colors.green),
                    onPressed: () => _handleAction(true),
                  ),
                  IconButton(
                    style: IconButton.styleFrom(backgroundColor: Colors.red.withOpacity(0.1)),
                    icon: const Icon(Icons.close, color: Colors.red),
                    onPressed: () => _handleAction(false),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

const FontWeight superBold = FontWeight.w900;
