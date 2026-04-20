import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'home/presentation/home_screen.dart';
import 'scan/presentation/scan_screen.dart';
import 'profile/presentation/profile_screen.dart';
import 'wallet/presentation/wallet_screen.dart';
import 'my_venues/presentation/my_venues_screen.dart';
import '../core/widgets/notification_badge.dart';
import '../services/session_context_controller.dart';
import 'manager/presentation/manager_dashboard_screen.dart';
import 'manager/presentation/venue_ledger_screen.dart';
import 'manager/presentation/venue_activity_screen.dart';
import 'manager/presentation/cms/manage_personnel_screen.dart';

final bottomNavIndexProvider = StateProvider.autoDispose<int>((ref) => 0);

class MainLayout extends ConsumerWidget {
  const MainLayout({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(bottomNavIndexProvider);
    final session = ref.watch(sessionContextProvider);

    final isBusiness = session.isBusiness;

    final screens = isBusiness
        ? const [
            VenueActivityScreen(),
            VenueLedgerScreen(),
            ManagerDashboardScreen(),
            ManagePersonnelScreen(),
          ]
        : const [
            HomeScreen(),
            WalletScreen(),
            MyHallsScreen(),
            ProfileScreen(),
          ];

    final scaffold = Scaffold(
      extendBody: true,
      body: screens[currentIndex],
      floatingActionButton: isBusiness 
          ? null 
          : FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ScanScreen()),
                );
              },
              shape: const CircleBorder(),
              child: const Icon(Icons.qr_code_scanner),
            ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8.0,
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            IconButton(
              icon: Icon(
                isBusiness ? Icons.dashboard : Icons.home,
                color: currentIndex == 0 ? Theme.of(context).primaryColor : null,
              ),
              onPressed: () => ref.read(bottomNavIndexProvider.notifier).state = 0,
            ),
            IconButton(
              icon: Icon(
                isBusiness ? Icons.library_books : Icons.account_balance_wallet,
                color: currentIndex == 1 ? Theme.of(context).primaryColor : null,
              ),
              onPressed: () => ref.read(bottomNavIndexProvider.notifier).state = 1,
            ),
            if (!isBusiness) const SizedBox(width: 48), // Spacer for FAB
            IconButton(
              icon: Icon(
                isBusiness ? Icons.admin_panel_settings : Icons.favorite,
                color: currentIndex == 2 ? Theme.of(context).primaryColor : null,
              ),
              onPressed: () => ref.read(bottomNavIndexProvider.notifier).state = 2,
            ),
            IconButton(
              icon: Icon(
                isBusiness ? Icons.people : Icons.person,
                color: currentIndex == 3 ? Theme.of(context).primaryColor : null,
              ),
              onPressed: () => ref.read(bottomNavIndexProvider.notifier).state = 3,
            ),
          ],
        ),
      ),
    );

    return PopScope(
      canPop: isBusiness ? false : (currentIndex == 0),
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        
        if (isBusiness) {
          if (currentIndex != 2) {
            // Manager Dashboard is the home of business mode (index 2)
            ref.read(bottomNavIndexProvider.notifier).state = 2;
          } else {
            // They are on the Manager Dashboard, prompt to exit
            final shouldExit = await showDialog<bool>(
              context: context,
              builder: (ctx) => AlertDialog(
                backgroundColor: const Color(0xFF222222),
                title: const Text("Exit Manager Mode?", style: TextStyle(color: Colors.white)),
                content: const Text(
                  "You will need to scan your ID or enter your PIN to access this dashboard again.",
                  style: TextStyle(color: Colors.white70),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx, false),
                    child: const Text("CANCEL", style: TextStyle(color: Colors.grey)),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(ctx, true),
                    child: const Text("EXIT", style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            );
            if (shouldExit == true && context.mounted) {
              ref.read(sessionContextProvider.notifier).switchToPersonal();
            }
          }
        } else {
          // Personal Mode
          if (currentIndex != 0) {
            ref.read(bottomNavIndexProvider.notifier).state = 0;
          }
        }
      },
      child: scaffold,
    );
  }
}
