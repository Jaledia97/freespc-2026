import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../repositories/raffle_manager_repository.dart';
import '../../../../models/raffle_model.dart'; // Import Model

class RaffleToolScreen extends ConsumerStatefulWidget {
  final String hallId;
  final RaffleModel raffle; // Requirement

  const RaffleToolScreen({super.key, required this.hallId, required this.raffle});

  @override
  ConsumerState<RaffleToolScreen> createState() => _RaffleToolScreenState();
}

class _RaffleToolScreenState extends ConsumerState<RaffleToolScreen> {
  bool _complianceAccepted = false;
  // _raffleNameCtrl Removed - we use widget.raffle.name

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _showComplianceDialog());
  }

  void _showComplianceDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: const Text("Compliance Certification", style: TextStyle(color: Colors.redAccent)),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("By proceeding, you certify that:", style: TextStyle(color: Colors.white)),
            SizedBox(height: 12),
            Text("1. You hold all necessary local gaming licenses.", style: TextStyle(color: Colors.white70)),
            SizedBox(height: 8),
            Text("2. You accept full liability for this event.", style: TextStyle(color: Colors.white70)),
            SizedBox(height: 8),
            Text("3. No purchase was required for entry.", style: TextStyle(color: Colors.white70)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
               Navigator.pop(ctx);
               Navigator.pop(context); // Go back if denied
            },
            child: const Text("CANCEL", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () {
              setState(() => _complianceAccepted = true);
              Navigator.pop(ctx);
            },
            child: const Text("I ACCEPT", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_complianceAccepted) {
      return const Scaffold(backgroundColor: Color(0xFF141414)); // Wait for dialog
    }

    // We use the hallId + raffleId to make unique session key if needed, or just hallId?
    // Repository logic uses 'hallId' as the document key currently. 
    // To support multiple concurrent raffles, we should probably use raffleId. 
    // BUT for simplicity/MVP refactor, let's keep it one session per hall at a time.
    final sessionAsync = ref.watch(activeRaffleSessionProvider(widget.hallId));

    return Scaffold(
      backgroundColor: const Color(0xFF141414),
      appBar: AppBar(
        title: Text('Run: ${widget.raffle.name}'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(activeRaffleSessionProvider(widget.hallId)),
          ),
        ],
      ),
      body: sessionAsync.when(
        data: (session) {
          if (session == null) return _buildStartScreen();
          
          final status = session['status'] as String? ?? 'unknown';
          switch(status) {
            case 'roll_call': return _buildRollCallScreen(session);
            case 'locked': return _buildLockedScreen(session);
            case 'active_draw': return _buildDrawScreen(session);
            case 'winner_drawn': return _buildWinnerScreen(session);
            default: return const Center(child: Text("Unknown State"));
          }
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, __) => Center(child: Text("Error: $e")),
      ),
    );
  }

  Widget _buildStartScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.play_circle_fill, size: 80, color: Colors.blueAccent),
          const SizedBox(height: 24),
          Text("Ready to start '${widget.raffle.name}'", style: const TextStyle(color: Colors.white, fontSize: 20)),
          const SizedBox(height: 32),
          ElevatedButton.icon(
             icon: const Icon(Icons.play_arrow),
             label: const Text("Start Roll Call Session"),
             style: ElevatedButton.styleFrom(
               backgroundColor: Colors.blueAccent,
               padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
             ),
             onPressed: () {
               ref.read(raffleManagerRepositoryProvider).startRollCall(widget.hallId);
             },
          ),
        ],
      ),
    );
  }

  Widget _buildRollCallScreen(Map<String, dynamic> session) {
    final code = session['code'] ?? '----';
    final participants = (session['participants'] as List?) ?? [];

    return Column(
      children: [
        // Code Display
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(32),
          color: const Color(0xFF1E1E1E),
          child: Column(
            children: [
              const Text("ROLL CALL ACTIVE", style: TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold, letterSpacing: 2)),
              const SizedBox(height: 16),
              Text(code, style: const TextStyle(color: Colors.white, fontSize: 64, fontWeight: FontWeight.bold, letterSpacing: 8)),
              const SizedBox(height: 8),
              const Text("Display this code to players", style: TextStyle(color: Colors.white54)),
            ],
          ),
        ),
        
        const SizedBox(height: 16),
        Text("${participants.length} Analyzed Presence(s)", style: const TextStyle(color: Colors.white, fontSize: 18)),
        const Divider(color: Colors.white24),
        
        Expanded(
          child: ListView.builder(
            itemCount: participants.length,
            itemBuilder: (ctx, i) {
              final p = participants[i];
              return ListTile(
                leading: const Icon(Icons.person, color: Colors.blueAccent),
                title: Text(p['name'] ?? 'Unknown', style: const TextStyle(color: Colors.white)),
                subtitle: Text("ID: ${p['uid']}", style: const TextStyle(color: Colors.white38, fontSize: 10)),
              );
            },
          ),
        ),
        
        Padding(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, minimumSize: const Size.fromHeight(50)),
            onPressed: () {
               ref.read(raffleManagerRepositoryProvider).lockRollCall(widget.hallId);
            },
            child: const Text("CONFIRM & LOCK LIST"),
          ),
        ),
      ],
    );
  }

  Widget _buildLockedScreen(Map<String, dynamic> session) {
    final participants = (session['participants'] as List?) ?? [];
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.lock, size: 64, color: Colors.orange),
          const SizedBox(height: 24),
          Text("${participants.length} Players Locked In", style: const TextStyle(color: Colors.white, fontSize: 24)),
          const SizedBox(height: 32),
          
          Text(
            "Distributing Tickets for:\n${widget.raffle.name}",
            textAlign: TextAlign.center, 
            style: const TextStyle(color: Colors.white54, fontSize: 16)
          ),
          const SizedBox(height: 32),
          
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green, minimumSize: const Size.fromHeight(50)),
            onPressed: () {
               // Use widget.raffle.id and name!
               ref.read(raffleManagerRepositoryProvider).distributeTickets(
                 widget.hallId, 
                 widget.raffle.name, 
                 raffleId: widget.raffle.id, // Pass real ID
                 imageUrl: widget.raffle.imageUrl // Pass image
               );
            },
            child: const Text("DISTRIBUTE TICKETS"),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawScreen(Map<String, dynamic> session) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.local_activity, size: 80, color: Colors.purpleAccent),
          const SizedBox(height: 24),
          const Text("Tickets Distributed", style: TextStyle(color: Colors.white, fontSize: 24)),
          const Text("Ready to Draw", style: TextStyle(color: Colors.white54)),
          const SizedBox(height: 48),
          
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.purple, padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 24)),
            onPressed: () {
               ref.read(raffleManagerRepositoryProvider).drawWinner(widget.hallId);
            },
            child: const Text("DRAW WINNER", style: TextStyle(fontSize: 20)),
          ),
        ],
      ),
    );
  }

  Widget _buildWinnerScreen(Map<String, dynamic> session) {
    final winner = session['winner'];
    final name = winner?['name'] ?? 'Unknown';
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text("WINNER", style: TextStyle(color: Colors.amber, fontSize: 16, letterSpacing: 4)),
          const SizedBox(height: 24),
          const Icon(Icons.emoji_events, size: 100, color: Colors.amber),
          const SizedBox(height: 32),
          Text(name, style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
          const SizedBox(height: 48),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
               OutlinedButton(
                 onPressed: () {
                   ref.read(raffleManagerRepositoryProvider).resetSession(widget.hallId);
                   Navigator.pop(context); // Exit after reset
                 }, 
                 child: const Text("Close Session")
               ),
            ],
          ),
        ],
      ),
    );
  }
}
