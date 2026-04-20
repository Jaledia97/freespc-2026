import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../services/auth_service.dart';
import '../../home/repositories/venue_repository.dart';
import '../../wallet/repositories/wallet_repository.dart';
import 'widgets/profile_header.dart';
import '../../settings/presentation/account_settings_screen.dart'; // Added
import '../../settings/presentation/privacy_settings_screen.dart';
import '../../settings/presentation/display_settings_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'public_profile_screen.dart';
import '../../../core/widgets/notification_badge.dart'; // Import NotificationBadge
import '../../my_venues/presentation/my_venues_screen.dart'; // Import MyVenuesScreen
import '../../home/presentation/upcoming_games_screen.dart'; // Import UpcomingGamesScreen
import '../../friends/presentation/friends_screen.dart'; // Import FriendsScreen
import '../../messaging/presentation/messaging_hub_screen.dart';
import '../../auth/presentation/login_screen.dart';
import '../../auth/presentation/auth_wrapper.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Watch real user data
    final userAsync = ref.watch(userProfileProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF121212), // Dark bg
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const NotificationBadge(
              showForGeneral: false,
              showForManager: false,
              child: Icon(Icons.chat_bubble_outline),
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const MessagingHubScreen()),
              );
            },
          ),
          IconButton(
            icon: const NotificationBadge(
              showForGeneral: false,
              showForMessages:
                  false, // Don't show personal chat badges on the manager settings
              child: Icon(Icons.settings),
            ),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                backgroundColor: const Color(0xFF1E1E1E),
                builder: (context) => SafeArea(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Workspaces are now handled via AccountSettingsScreen

                        ListTile(
                          leading: const Icon(
                            Icons.manage_accounts,
                            color: Colors.blueGrey,
                          ),
                          title: const Text(
                            'Account Settings',
                            style: TextStyle(color: Colors.white),
                          ),
                          onTap: () {
                            Navigator.pop(context); // Close sheet
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const AccountSettingsScreen(),
                              ),
                            );
                          },
                        ),
                        ListTile(
                          leading: const Icon(
                            Icons.settings_display,
                            color: Colors.blueGrey,
                          ),
                          title: const Text(
                            'Display Settings',
                            style: TextStyle(color: Colors.white),
                          ),
                          onTap: () {
                            Navigator.pop(context); // Close sheet
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const DisplaySettingsScreen(),
                              ),
                            );
                          },
                        ),
                        ListTile(
                          leading: const Icon(
                            Icons.security,
                            color: Colors.blueGrey,
                          ),
                          title: const Text(
                            'Privacy & Safety',
                            style: TextStyle(color: Colors.white),
                          ),
                          onTap: () {
                            Navigator.pop(context); // Close sheet
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const PrivacySettingsScreen(),
                              ),
                            );
                          },
                        ),
                        ListTile(
                          leading: const Icon(
                            Icons.logout,
                            color: Colors.redAccent,
                          ),
                          title: const Text(
                            'Logout',
                            style: TextStyle(color: Colors.redAccent),
                          ),
                          onTap: () {
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(builder: (_) => const AuthWrapper()),
                              (route) => false,
                            );
                            ref.read(authServiceProvider).signOut();
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: userAsync.when(
        data: (user) {
          if (user == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("You are logged out.", style: TextStyle(color: Colors.white54)),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (_) => const LoginScreen()),
                        (route) => false,
                      );
                    },
                    child: const Text("Login / Sign Up"),
                  ),
                ],
              ),
            );
          }
          return CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 1. Header (Avatar, Name, Edit)
                      ProfileHeader(user: user),

                      const SizedBox(height: 24),

                      // 2. Action Row (Friends, Tournaments, Raffles)
                      SizedBox(
                        height: 48,
                        child: Row(
                          children: [
                            Expanded(
                              child: _buildActionBtn(
                                context,
                                "Friends",
                                Icons.people,
                                Colors.greenAccent,
                                () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const FriendsScreen(),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _buildActionBtn(
                                context,
                                "Events",
                                Icons.calendar_month,
                                Colors.indigoAccent,
                                () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const UpcomingGamesScreen(
                                      initialCategory: null,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _buildActionBtn(
                                context,
                                "My Places",
                                Icons.storefront,
                                Colors.amber,
                                () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const MyVenuesScreen(),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),

              SliverPersistentHeader(
                pinned: true,
                delegate: _SliverAppBarDelegate(
                  TabBar(
                    controller: _tabController,
                    indicatorColor: Colors.purpleAccent,
                    labelColor: Colors.purpleAccent,
                    unselectedLabelColor: Colors.white54,
                    onTap: (index) {
                      setState(() {});
                    },
                    tabs: const [
                      Tab(text: "THE WALL", icon: Icon(Icons.list_alt)),
                      Tab(text: "PHOTOS", icon: Icon(Icons.grid_on)),
                    ],
                  ),
                ),
              ),

              if (_tabController.index == 0) ...[
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: 300,
                    child: Center(
                      child: Text(
                        "The Wall Component Coming Soon",
                        style: TextStyle(color: Colors.white54),
                      ),
                    ),
                  ),
                ),
              ] else ...[
                // 4. Gallery Grid
                Consumer(
                  builder: (context, ref, _) {
                    final galleryAsync = ref.watch(
                      profileGalleryProvider(user.uid),
                    );

                    return galleryAsync.when(
                      data: (images) {
                        if (images.isEmpty) {
                          return const SliverToBoxAdapter(
                            child: Padding(
                              padding: EdgeInsets.all(32.0),
                              child: Center(
                                child: Text(
                                  "No photos yet.",
                                  style: TextStyle(color: Colors.white54),
                                ),
                              ),
                            ),
                          );
                        }

                        return SliverPadding(
                          padding: const EdgeInsets.symmetric(horizontal: 1),
                          sliver: SliverGrid(
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 3,
                                  crossAxisSpacing: 2,
                                  mainAxisSpacing: 2,
                                  childAspectRatio: 1.0,
                                ),
                            delegate: SliverChildBuilderDelegate((
                              context,
                              index,
                            ) {
                              return CachedNetworkImage(
                                imageUrl: images[index],
                                fit: BoxFit.cover,
                                placeholder: (context, url) =>
                                    Container(color: Colors.white10),
                                errorWidget: (context, url, error) => Container(
                                  color: Colors.white10,
                                  child: const Icon(
                                    Icons.error,
                                    color: Colors.white24,
                                  ),
                                ),
                              );
                            }, childCount: images.length),
                          ),
                        );
                      },
                      loading: () => const SliverToBoxAdapter(
                        child: Center(child: CircularProgressIndicator()),
                      ),
                      error: (e, st) => const SliverToBoxAdapter(
                        child: Center(child: Text("Failed to load gallery.")),
                      ),
                    );
                  },
                ),
              ],

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24.0,
                    vertical: 24.0,
                  ),
                  child: Column(
                    children: [
                      // 5. Developer Tools (Collapsible) - RESTRICTED
                      if (user.systemRole == 'super-admin' ||
                          user.systemRole == 'superadmin')
                        Theme(
                          data: Theme.of(
                            context,
                          ).copyWith(dividerColor: Colors.transparent),
                          child: ExpansionTile(
                            title: const Text(
                              "Developer Options",
                              style: TextStyle(
                                color: Colors.redAccent,
                                fontSize: 14,
                              ),
                            ),
                            iconColor: Colors.redAccent,
                            collapsedIconColor: Colors.redAccent,
                            children: [
                              ListTile(
                                title: const Text(
                                  'ADMIN: Seed Mock Venue',
                                  style: TextStyle(color: Colors.red),
                                ),
                                trailing: const Icon(
                                  Icons.add_box,
                                  color: Colors.white54,
                                ),
                                onTap: () {
                                  ref
                                      .read(venueRepositoryProvider)
                                      .createMockHall();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Mock Venue Created'),
                                    ),
                                  );
                                },
                              ),
                              ListTile(
                                title: const Text(
                                  'ADMIN: Seed Mary Esther Env',
                                  style: TextStyle(color: Colors.blue),
                                ),
                                subtitle: const Text(
                                  'Sets You as Owner + Resets Data',
                                ),
                                trailing: const Icon(
                                  Icons.build,
                                  color: Colors.white54,
                                ),
                                onTap: () async {
                                  try {
                                    final repo = ref.read(
                                      venueRepositoryProvider,
                                    );
                                    // 1. Reset Venue & User
                                    await repo.seedMaryEstherEnv(user.uid);
                                    // 2. Reset Raffles (Sync with Wallet)
                                    await repo.seedRaffles('mary-esther-bingo');
                                    // 3. Reset Wallet Data
                                    await ref
                                        .read(walletRepositoryProvider)
                                        .seedWalletData(user.uid);

                                    if (context.mounted) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            'Master Reset Complete! (User, Venue, Raffles, Wallet)',
                                          ),
                                        ),
                                      );
                                    }
                                  } catch (e) {
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(content: Text("Error: $e")),
                                      );
                                    }
                                  }
                                },
                              ),
                              ListTile(
                                title: const Text(
                                  'ADMIN: Seed Specials (5 items)',
                                  style: TextStyle(color: Colors.green),
                                ),
                                trailing: const Icon(
                                  Icons.cloud_upload,
                                  color: Colors.white54,
                                ),
                                onTap: () async {
                                  await ref
                                      .read(venueRepositoryProvider)
                                      .seedSpecials();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Specials Seeded!'),
                                    ),
                                  );
                                  // Force refresh of map might be needed
                                },
                              ),
                              ListTile(
                                title: const Text(
                                  'ADMIN: Seed Carousels (Tourneys/Raffles)',
                                  style: TextStyle(color: Colors.blueAccent),
                                ),
                                trailing: const Icon(
                                  Icons.view_carousel,
                                  color: Colors.white54,
                                ),
                                onTap: () async {
                                  await ref
                                      .read(venueRepositoryProvider)
                                      .seedCarouselEvents();
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Carousels Seeded! Check Home Screen.',
                                        ),
                                      ),
                                    );
                                  }
                                },
                              ),
                              ListTile(
                                title: const Text(
                                  'ADMIN: Seed Wallet Data',
                                  style: TextStyle(color: Colors.amber),
                                ),
                                trailing: const Icon(
                                  Icons.account_balance_wallet,
                                  color: Colors.white54,
                                ),
                                onTap: () async {
                                  try {
                                    await ref
                                        .read(walletRepositoryProvider)
                                        .seedWalletData(user.uid);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Wallet Data Seeded!'),
                                      ),
                                    );
                                  } catch (e) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('Error: $e')),
                                    );
                                  }
                                },
                              ),
                              ListTile(
                                title: const Text(
                                  'ADMIN: Promote to Super Admin',
                                  style: TextStyle(color: Colors.purpleAccent),
                                ),
                                subtitle: const Text(
                                  'Grants full access without resetting data',
                                ),
                                trailing: const Icon(
                                  Icons.security,
                                  color: Colors.white54,
                                ),
                                onTap: () async {
                                  await ref
                                      .read(venueRepositoryProvider)
                                      .promoteToSuperAdmin(user.uid);
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'You are now a Super Admin!',
                                        ),
                                      ),
                                    );
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                      const SizedBox(height: 80),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text("Error: $e")),
      ),
    );
  }

  Widget _buildActionBtn(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white10),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar _tabBar;

  _SliverAppBarDelegate(this._tabBar);

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(color: const Color(0xFF121212), child: _tabBar);
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}
