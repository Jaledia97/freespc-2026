import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'home/presentation/home_screen.dart';
import 'scan/presentation/scan_screen.dart';
import 'profile/presentation/profile_screen.dart';
import 'wallet/presentation/wallet_screen.dart';
import 'my_halls/presentation/my_halls_screen.dart';

final bottomNavIndexProvider = StateProvider<int>((ref) => 0);

class MainLayout extends ConsumerWidget {
  const MainLayout({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(bottomNavIndexProvider);

    final screens = const [
      HomeScreen(),     // 0
      WalletScreen(),   // 1
      MyHallsScreen(),  // 2
      ProfileScreen(),  // 3
    ];

    return Scaffold(
      extendBody: true,
      body: screens[currentIndex],
      floatingActionButton: FloatingActionButton(
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
                Icons.home,
                color: currentIndex == 0 ? Theme.of(context).primaryColor : null,
              ),
              onPressed: () => ref.read(bottomNavIndexProvider.notifier).state = 0,
            ),
            IconButton(
              icon: Icon(
                Icons.account_balance_wallet,
                color: currentIndex == 1 ? Theme.of(context).primaryColor : null,
              ),
              onPressed: () => ref.read(bottomNavIndexProvider.notifier).state = 1,
            ),
            const SizedBox(width: 48), // Spacer for FAB
            IconButton(
              icon: Icon(
                Icons.favorite,
                color: currentIndex == 2 ? Theme.of(context).primaryColor : null,
              ),
              onPressed: () => ref.read(bottomNavIndexProvider.notifier).state = 2,
            ),
            IconButton(
              icon: Icon(
                Icons.person,
                color: currentIndex == 3 ? Theme.of(context).primaryColor : null,
              ),
              onPressed: () => ref.read(bottomNavIndexProvider.notifier).state = 3,
            ),
          ],
        ),
      ),
    );
  }
}
