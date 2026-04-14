# Changelog

All notable changes to the FreeSPC project will be documented in this file.

## [0.0.1+75] - 2026-04-14 - Business Registration & Workspace Visibility

### Added
- **Sandbox Provisioning**: Refactored `CreateVenueScreen` to instantly generate an invisible "Sandbox" venue (`isActive: false`) when a new business signs up, immediately granting them "Pending" access mapped to their workspaces.
- **Appeals & Rejection Pipeline**: Designed the `AccountSettingsScreen` to explicitly reflect `PENDING` or `DENIED` states. Denied applications feature a modal with Superadmin feedback and native "Submit Appeal" triggers.
- **Superadmin CMS Hub**: Upgraded the `SuperadminDashboardScreen` to display pending claims seamlessly, added a button to natively preview Sandbox configurations, and enforced a mandatory "Denial Reason" text field upon rejection.
- **Secure Cloud Functions**: Implemented `onApproveClaim` and `onRejectClaim` on the backend to securely manage role elevation to "owner" natively upon approval, alongside dynamic dispatching of push notifications.

### Changed
- **Unified Approvals**: Modified the backend Cloud Functions to properly authorize standard `admin` users alongside `superadmin` users when reviewing claims.

### Fixed
- **Missing Workspace Visibility**: Resolved a silent `collectionGroup` index bug crashing the "Your Workspaces" feed. Added a single-field override targeting the `team` subcollection's `uid` natively inside `firestore.indexes.json` so newly approved venues instantly populate the applicant's UI without issues.

## [0.0.1+74] - 2026-04-10 - Privacy Constraints, Admin Caching, & Business Registration

### Added
- **Unlisted Venue Builder**: Scrapped the legacy unstructured alert box previously backing "Can't find your hall", replacing it natively with `CreateVenueScreen`, an interactive onboarding funnel sequentially retrieving vital architecture (Domain, Email, City, Address) natively for seamless Superadmin verifications.
- **Spoof Session Caching**: Built out a local `SharedPreferences` memory index directly natively into `SpoofWorkspaceScreen`. Up to 10 persistent Workspace spoof targets are organically cataloged underneath the Admin search bar for accelerated platform maneuvers.
- **Map View UI Clarification**: Scrubbed the ambiguous fallback `+` floating action within the Native `my_halls_screen.dart` AppBar, mapping it rigidly over to an expanded `FilledButton.icon` explicitly labeling "Map View".

### Changed
- **Privacy Search Constraints**: Recalculated the core Global User Search algorithms explicitly blocking `"{FirstName} {LastName}"` payloads if `realNameVisibility` falls short of `Everyone`. Silently downgrades visibility natively to `"@{Username}"` suppressing rogue exposure.
- **Ghost Presences**: Smashed the `_reportPresence` loop globally appending `Last Seen` logic against all `AuthWrapper` initializations. Restructured mathematically to conditionally intercept `offline` UserModel declarations bypassing timestamp logging indefinitely preventing offline bleeding. 
- **Verbiage Generalization**: Expanded the remaining Onboarding sequences, rewriting restrictive bingo-centric phrasing to generalize community platforms, events, and venues universally.

### Fixed
- **Permission Pipeline Rejection**: Traced a catastrophic Permission Denied crash inside `ClaimVenueScreen.dart` resolving out to an unmapped Firebase endpoint array. Successfully mapped the write permissions natively onto the verified `venue_claims` platform where Superadmin listens flawlessly.
- **Compilation Payload Trace**: Resolved a broken Native VM restart pipeline crashing due to undefined `type` parameters failing FCM extraction inside `lib/main.dart`'s notification handler natively.

## [0.0.1+73] - 2026-04-09 - Onboarding UI Polish & Feed Restabilization

### Added
- **Unified Permissions Sequencing**: Removed disjointed manual toggle buttons from the Step 5 Onboarding screen. Permissions (Location, Bluetooth, Contacts, Notifications) are cleanly sequenced natively through a declarative `dense` layout, sequentially piping OS-level modals over a single tap to preserve phone real-estate.
- **Onboarding Padding Compression**: Rewrote the global Onboarding `_buildStep` scaling architectures, aggressively purging dead white space (24px to 12px margins, 48px to 32px gaps) to dramatically hoist action buttons above the physical bottom screen-fold unconditionally.

### Changed
- **Multi-Venue Generalization**: Swept the Onboarding payloads strictly clearing legacy `bingo` references (like `hall` and `jackpot`) in favor of generalized community terms like `venues` and `massive events and prizes` across Steps 2, 5, and 6.

### Fixed
- **Algorithmic Feed Starvation**: Resolved a massive critical sequence failure where recurrent CMS Templates natively serialized `postedAt` metrics up to 14-days outwards. This mathematically forced the global Feed's descending `limit(20)` query block to pull days $+14$ to $+4$, physically cutting off today's events from the feed algorithm before they could even hit the client. Overrode the recurrence engines internally in `hall_repository.dart` natively clamping clones backwards securely to today's `publishedAt` time.

## [0.0.1+72] - 2026-03-30 - Multi-Entity RBAC & B2B Switcher Architecture

### Added
- **Multi-Entity Switcher**: Replaced the global `role` model with a rigorous `VenueTeamMemberModel` subcollection architecture. Users are explicitly mapped to individual venues via specific `assignedRole` ('owner', 'manager', 'worker') clearances.
- **Session Context Controller**: Engineered a core Riverpod controller isolating users inside a `'personal'` (Consumer) context by default. B2B Context transitions securely reroute the application shell to specialized Business Navigations exclusively when active.
- **Spoof Workspace Matrix**: Created a dedicated `SpoofWorkspaceScreen` allowing `superadmin` accounts to seamlessly inject themselves into any active Venue context natively bypassing traditional permission gates via exact 20-character IDs or partial string queries.
- **Personnel CMS**: Developed `ManagePersonnelScreen` and deployed `mutateStaffRole` Cloud Function routines orchestrating real-time promotion, demotion, and firing of staff with rigorous "Orphan Lock" protections preventing the demotion of a venue's final Owner.
- **Global Platform Roles**: Promoted `systemRole` ('user', 'admin', 'superadmin') to the frontend state, dynamically rendering Platform Administration hubs securely bypassing normal B2B gates.

### Changed
- **Content Authorship Alignment**: Rewired all User-Generated Content modules (Specials, Tournaments, TextPosts) to programmatically map `authorType: 'venue'` and `authorId: activeVenueId` upon creation while in B2B contexts, fundamentally shifting data ownership from standard users strictly onto the Host Venues.
- **Business Dashboard Feeds**: Replaced placeholder routing screens with a highly optimized `VenueActivityScreen` dynamically pulling live stream feeds exclusively for the targeted `ActiveVenueId` directly from standard Firestore providers.

### Fixed
- **Rule Alignment**: Redeployed strict `firestore.rules` dropping legacy `role` syntax traversing `collectionGroup('team')` indices and securely resolving the "Role Array" Firebase errors natively.
- **SuperAdmin CMS Exceptions**: Resolved `AdminRepository.getPendingClaims` fatal stream mapping errors tearing the dashboard UI by wrapping `try-catch` structures preventing a single deformed legacy document from generating an `AsyncError` global crash.

## [0.0.1+71] - 2026-03-27 - End-to-End Bluetooth Check-in & S-Tier Notifications (Phases 47-52)

### Added
- **Native Bluetooth Scanning**: Engineered `ConsumerBeaconService` executing continuous foreground BLE broadcasts locally filtering out rogue beacons via an aggressive 3-ping `>-85 RSSI` squelch algorithm. Validated iOS/Android OS location permissons.
- **Glassmorphic Check-Ins**: Designed highly interactive Bottom Sheets explicitly surfacing when Squelch passes. Users can instantly execute a `checkIn` mutation natively attaching `userName` and `userProfilePicture` onto their target Hall's public Feed.
- **S-Tier Comment Reactions**: Overhauled Comment UI injecting native Facebook-styled dynamic Reaction models (❤️🔥😂😢😡👍). Backed by atomic `SetOptions(merge: true)` Cloud Firestore routines.
- **Dynamic Notification Batching**: Intercepted Notification Spam directly inside `lib/main.dart` Android Channels utilizing `setOnlyAlertOnce: true`. Comments and Reactions dynamically bundle over their parent `threadId` silently preventing secondary haptic rings.

### Fixed
- **RenderFlex Physics**: Swapped a constraint-locking `AnimatedContainer` with fluid `AnimatedSize` encapsulating the Search Pill intelligently eliminating horizontal layout overflow errors definitively.

## [0.0.1+70] - 2026-03-26 - S-Tier Media Chat Experience (Phases 39-43)

### Added
- **Native Media Compression**: Engineered severe local client compression workflows using `flutter_image_compress` and `video_compress`, intercepting and tightly downscaling massive user gallery files before triggering Firebase Storage uploads to aggressively protect native bandwidth.
- **Zero-Cost GIF CDN Routing**: Bypassed Firebase Storage completely for GIF interactions. Integrated `giphy_get` to exclusively map isolated 3rd-party CDN URL strings over the messaging payload, bringing GIF backend storage expenses exactly down to $0 organically.
- **Video Thumbnails & Fullscreen Player**: Restricted raw video auto-playback natively. Chat screens now purely render deeply-compressed pre-extracted Thumbnails enveloped in a darkened "Play Button" Stack which gracefully invokes a synchronous `Chewie` fullscreen `VideoPlayerDialog` natively when engaged.
- **Group Chat Avatar Stacking**: Completely replaced the generic read receipt logic explicitly mapping an intelligent `Future.wait` overlapping `Stack` boundary rendering exactly up to 5 concurrent miniaturized 14x14 CircleAvatars dynamically mimicking native iMessage cluster formats gracefully seamlessly.
- **Message Action Hooks**: Linked native `GestureDetector` payloads to long-press executions triggering a universal `MessageActionSheet`. Bound `deleteMessageLocally` to hide elements dynamically masking explicit arrays securely.

### Changed
- **Swipe Tuning**: Recalibrated the native `Dismissible` bounds replacing the default `0.4` threshold with an immediate `0.1` threshold explicitly, vastly decreasing swipe friction naturally.
- **Dynamic Text Masking**: Isolated raw string texts (e.g., "Sent a photo") cleanly rendering purely the physical CDN UI cards when media arrays define explicit `.mediaUrl` payload locks conditionally neatly cleanly smoothly securely.

## [0.0.1+69] - 2026-03-26 - The 13-Part Social Architecture Scaling (Phases 18-30)

### Added
- **Core Security**: Implemented strict `firestore.rules` denying global reads and building Manager-only execution locks securely encapsulating `transactions` to append-only.
- **Data Models**: Overhauled MongoDB-style loose structures into exact `Freezed` architectures (e.g., `MessageModel`, `RaffleModel`) enforcing strict Cloud-layer predictability natively.
- **Superadmin CMS**: Engineered custom Firebase Cloud Functions validating B2B Verification Claims escalating User roles silently over atomic Batch Writes.
- **Typo-Tolerant Search**: Mitigated Firebase read operations building local Fuzzy Substring Fallbacks intercepting misspellings via Debounced Native streams.
- **Rich Embedded DMs**: Constructed Native Feed Payloads injecting live Interactive Widgets directly into the standard `ChatScreen` explicitly bypassing Navigator push behaviors securely.
- **Hybrid Glassmorphic Shares**: Rewrote abstract `Share` parameters structurally rendering Canonical `freespc://feed` environments into dynamic Glassmorphic overlay menus.
- **Lazy Auth & Deferred Routing**: Dismantled enforced Registration screens bypassing Guest interactions securely mapping Deferred `app_links` payloads over `SharedPreferences`.

### Changed
- **Zero-Latency UI**: Extracted explicit Backend dependencies from `SocialInteractionBar` injecting purely Optimistic UI blocks forcing instant UI fulfillment backed by Native `Vibration` hardware.

## [0.0.1+68] - 2026-03-25 - Squad Creation & External Recruitment

### Added
- **Squad Creation**: Rebuilt the `FriendsScreen` SliverAppBar injecting a dedicated "Create Squad" entry point. Users can organically form squads mapped inherently to their live `friendsProfilesProvider`.
- **Backend Array Management**: Constructed `squad_repository.dart` guaranteeing atomic, multi-collection Batch Writes simultaneously across `users/` and `public_profiles/` architectures instantly.
- **External Recruitment SDK**: Integrated `share_plus` into the `CreateSquadSheet` allowing Captains to physically generate and ping OS-level deep-links (`freespc://add_friend?uid=...`) globally.
- **Minimum Array Lock**: Engineered a robust front-end validation explicitly restricting squad initialization to 51% bounds logic (4 selected members minimum before execution unlocks).

## [0.0.1+67] - 2026-03-25 - Raffle Recurrence & CMS UI Overhaul

### Added
- **Raffle Recurrence Engine**: Architected the `Template` engine natively into `RaffleModel` driving automated backend NodeJS triggers via `onRaffleWritten` logic.
- **Occurrence Restoration**: Formalized soft-delete states (`isCancelled`) dynamically routing cancelled events securely to the expired tab with stark `[CANCELLED]` visual chips.
- **Occurrence Lifecycles**: Built synchronized `Restore Occurrence` state buttons strictly bound to the CMS natively.

### Fixed
- **OS Layout Clipping**: Performed a massive UI sweep enforcing absolute `100px` bottom-padding limits onto every CMS ScrollView and Feed List Array globally, conclusively shielding Editor elements from native Apple and Android software navigation bars.
- **Legacy Modals**: Stripped disjointed "Use As Copy" and standard publish sheets natively, unifying everything under secure Editor form routing logic.

## [0.0.1+66] - 2026-03-24 - Privacy Hub & Push Notification Deep Links

### Added
- **Push Notification Deep Linking**: Architected a `GlobalKey<NavigatorState>` routing protocol into `main.dart` enabling Push Notifications to accurately intercept state and route `ChatScreens` seamlessly across foreground, background, and cold-boot application streams.
- **Privacy Hub Integration**: Finalized the `PrivacySettingsScreen` encompassing `BlockedUsersScreen` and `HiddenPostsScreen`. Engineered a localized caching mechanism via `SharedPreferences` to silently filter toxic UGC and natively injected a strict 24-hour unblock cooldown to mitigate abuse.
- **Optimistic RSVP Syncing**: Engaged instantaneous mutable `interestedUserIds` operations atop the `FeedPaginationController`, allowing Social Interaction Bar RSVPs to instantly reflect on the Home Feed without incurring heavy backend read costs.

### Fixed
- **FCM Kernel Blackholes**: Patched legacy Javascript Cloud functions aggressively stripping custom Deep Link `metadata`.
- **Foreground Payload Rendering**: Repaired V20 parameter syntax errors inside `flutter_local_notifications` and invoked explicit Apple/Android 13+ OS `requestPermission()` routines to natively bypass zero-day notification blackout periods.

## [0.0.1+65] - 2026-03-23 - Messaging Haptics & Permanence

### Added
- **Chat Haptic Feedback**: Engineered native `HapticFeedback.vibrate()` triggers directly into the messaging dispatch pipelines. Send-events instantly vibrate the local device, and Foreign message intercepts trigger haptics when natively rendering onto an active Chat Screen.
- **Push Notification Dispatch**: Wired `sendMessage` to passively generate raw `new_message` documents inside the recipient's secure `notifications` subcollection, allowing backend Cloud Functions to natively loop FCM Push notifications to offline devices.
- **Thread Permanence (Hard Clear)**: Rebuilt the "Hide Chat" logic to stamp a rigid `clearedAt` DateTime override onto the ChatModel. Initiating a new chat with the same user now definitively hides all legacy payload history sent prior to the clear stamp.

### Changed
- **Badge Isolation**: Striped the global bottom-navigation bar of all Chat Notification UI badges. Message unread bubbles now strictly only overlay explicit Messenger action icons (AppBars), keeping the primary UI feed uncluttered.
- **Username Hook Integrity**: Patched `find_friends_screen` to strictly map Firebase `username` variables into new chat metadata layers instead of occasionally falling back to `firstName` entries.

## [0.0.1+64] - 2026-03-19 - S-Tier Social Feed & Profile Alignment

### Added
- **Algorithmic Feed**: Replaced disjointed carousels with a unified `SliverList` feed wrapper, laying groundwork for `hypeScore` sorting logic.
- **Squad Infrastructure**: Integrated `SquadModel` mapping to enable loyalty logic scaling ("51% Rule" multipliers) for verified squads.
- **Feed Interactions**: Built a universal `SocialInteractionBar` with reactive Hype, Comment, RSVP, and native OS Share actions.
- **Advanced Hypes**: Engineered a long-press generic reaction overlay mimicking Facebook's (Hype, Haha, Love, Sad, Angry) and implemented Double-Tap-to-Hype gestures on feed cards.
- **RSVP Live Syncing**: Hardwired `toggleInteraction` array payloads strictly to Firestore so RSVP filter pills update users' custom feed flows in realtime.
- **Profile Parity**: Reconstructed the Private Profile explicitly to mirror the new Public layout. Switched to `CustomScrollView`, injected a native `SliverGrid` for user photos, and consolidated Bio and Stats symmetrically.
- **UGC Wrappers**: Built `WinPostModel` and `CheckInModel` wrappers to inject User-Generated Content cleanly into the global feed parser.

### Fixed
- **Friend List Visibility**: Corrected a rigorous `firestore.rules` constraint that inadvertently threw `PERMISSION_DENIED` errors when loading accepted friends.
- **Gallery Grid Population**: Repaired Firestore permissions authorizing `win_posts` and `check_ins` reads so they can natively populate the new profile grid architecture.

## [0.0.1+63] - 2026-03-16 - AAA Chat Experience & Onboarding Flow

### Added
- **Swipe-to-Reply**: Chat messages now feature native iOS-like dismissible physics when swiping right, locking into a "Reply" state with a smart preview bar anchored above the keyboard.
- **Swipe-to-Delete**: Inbox chats can now be elegantly hidden by swiping left-to-right to reveal a native Trash background. This leverages a `deletedBy` soft-delete approach so chat histories are preserved if the other participant replies.
- **Grouped Timestamps**: Upgraded chat timelines to use a Facebook Messenger aesthetic—merging messages and strictly displaying a centered timestamp header only when 60+ minutes pass between messages.
- **Onboarding Formatting**: Enforced strict auto-capitalization for Real Names and a 20-character limit counter for Usernames on the Onboarding Screen.
- **Robust Searching**: Converted system usernames to natively preserve upper/lowercase structure for distinct custom branding, while stealthily indexing a lowercase `.searchName` in Firebase to maintain robust prefix-based fast searches without bugs.
- **SafeArea Scaling**: Anchored the chat input textfield inside a dynamically expanding `SafeArea` widget to prevent the iOS Home indicator from clipping the user's typing.
- **Friend Loop Integration**: Hot-swapped the 'Pending' and 'Add Friend' buttons into instant 'Message' buttons across `find_friends_screen` and `public_profile_screen` when a relationship is verified.


## [0.0.1+62] - 2026-03-07 - Friend Requests & Public Profiles

### Added
- **Public Profiles**: Created `PublicProfileScreen` displaying user details, stats, bio, and dynamic friendship action buttons.
- **Improved Friend Requests**: Differentiated friend requests into `sent` and `received` statuses, rather than a generic `pending`.
- **Search UI Refinement**: The `FindFriendsScreen` now dynamically displays icons based on relationship status (Add Friend, Cancel Pending Request, Already Friends).
- **Pending Inbox**: Added a dedicated "Pending Requests" inbox to the top of the Search page to formally view and accept incoming requests.
- **Friend Request Notifications**: Users now receive a `friend_request` notification when invited.
- **Inline Notification Actions**: Injected immediate 'Accept', 'Decline', and 'Ignore' buttons directly into the notification tile to streamline request management.

### Fixed
- **Friend List Permission Denied**: Corrected Firestore security rules that were blocking the display of friends lists.
- **Hall Gallery Upload Permission**: Adjusted rules so users can properly upload photos to a hall gallery.
- **Notification Username Interpolation**: Fixed a bug where friend requests displayed the literal string `@$senderUsername` instead of the user's handle.

## [0.0.1+61] - 2026-03-03 - UI Polish & Bug Fixes

### Fixed
- **Notification Badges**: Added `markTypeAsRead` to `NotificationService.dart`. `PhotoApprovalScreen` now instantly clears `hall_photo_pending` notifications upon viewing.
- **Navigation**: Added a new Notification Bell icon to the `ProfileScreen` AppBar so users can actually view and clear general system notifications.
- **State Management**: Refactored `unreadNotificationsCountProvider` from a StreamProvider to a synchronous derived `Provider<int>` so the badge count reacts instantaneously to the underlying list state.
- **Gradle Version**: Fast-tracked an update to `gradle-8.13-bin.zip` in the Android properties to clear IDE false-positive warning spam from the Flutter updates.

## [0.0.1+60] - 2026-02-26 - Push Notifications (Phase 60)

### Added
- **Push Notification Infrastructure**: Integrated Firebase Cloud Messaging (FCM) and `flutter_local_notifications`.
- **Cloud Functions**: Added Node.js Cloud Function to automatically dispatch FCM pushes when notifications are written to Firestore.
- **Client Handling**: Device FCM tokens are now automatically synced to the `UserModel`, and foreground notification UI is enabled to ring/vibrate.
- **Dependency Update**: Enabled core library desugaring in Android Gradle build (`desugar_jdk_libs:2.1.4`) to support latest Flutter plugins.


## [0.0.1+59] - 2026-02-26 - S-Tier Chat & Privacy (Phase 59)

### Added
- **Privacy Settings**: Added `BlockedUsersScreen` to manage blocked accounts (unblocking support).
- **User Blocking**: Users can now block others directly from a 1-on-1 chat, which purges them from the Inbox feed and replaces future group messages with a placeholder.
- **Reporting System**: Universal report functionality to flag explicit chats or abusive users globally.
- **Chat Muting**: Users can toggle muting for any chat thread via the top right menu options.
- **Card UI Refinements**: `SpecialCard` expansion area is now strictly locked to the text container, and the OS native Share button elegantly overlays the top right of featured images.

### Known Issues (Pending Fixes)
- **Notification Routing**: Tapping a photo approval notification fails to route the user to the `PhotoDetailScreen`.
- **Notification Timestamps**: New photo approval notifications are still missing timestamps despite backend parsing fixes.
- **Notification Badges**: The red notification badge persists on the Profile icon and Settings cog even after a Manager approves the photo post.

## [0.0.1+58] - 2026-02-25 - Stability Patch

### Fixed
- **Serialization Crash**: Resolved an "Invalid Type" crash when saving Specials, Tournaments, or Raffles that included a Recurrence Schedule. Nested objects are now correctly serialized to JSON before being sent to Firestore.

## [0.0.1+57] - 2026-02-20 - Store Redemption (Phase 57)

### Added
- **Store Redemption**: Users can now spend their earned points in the Hall Store.
- **Quantity Picker**: Added a responsive quantity picker to store items.
- **Limit Enforcement**: `perCustomerLimit` is actively enforced on the quantity picker.
- **Backend Transaction**: Secure Point deduction (Membership and Global) alongside a `spend` transaction log.

## [0.0.1+34] - 2026-02-18 - Bluetooth & Beacon Support (Phase 48)

### Added
- **Bluetooth Settings**:
    - **Beacon Management**: CMS module to scan, connect, and configure Feasycom BP101E beacons.
    - **Security**: PIN-authenticated access to beacon settings.
    - **UUID Sync**: One-tap rotation updates both hardware and Firestore.
    - **Signal Control**: Custom "Heartbeat" (On/Off rhythm), TX Power, and Interval sliders.
- **Personnel Management**: Invite System, CMS integration, and Onboarding flow.

## [0.0.1+36] - 2026-02-18 - UI Polish & Critical Fixes
### Added
- **Hall Name Visibility**: Enhanced `SpecialCard` and `TournamentListCard` to prominently display the Hall Name with a location icon.
- **Dynamic Fallback**: Implemented robust fallback logic (`DynamicHallName`) to fetch and display hall names even if missing from the source data.

### Fixed
- **Infinite Loading**: Resolved the perpetual loading spinner on the "Tournaments" screen by refactoring `UpcomingGamesScreen` to use Riverpod `AsyncValue` caching correctly.
- [x] **Data Fetching**: Unified stream management for Raffles and Tournaments to prevent unnecessary re-fetches.

## [0.0.1+37] - 2026-02-19 - Store Management (Phase 52-53)
### Added
- **Store CMS**:
    - **Manage Store**: Full CRUD support for managing store items (Merchandise, Food, Pull Tabs, etc.).
    - **Item Limits**: Managers can set `Person Limit` (max items per player) and `Daily Limit` (max items sold per day).
    - **Categorization**: Items organize into tabs: Merchandise, Food & Beverage, Sessions, Pull Tabs, Electronics, Other.
- **Storefront**:
    - **Consumer View**: dedicated `HallStoreScreen` for players to browse and view items.
    - **Navigation**: "Store" button added to Hall Profile header.
    - **Visibility**: Items can be toggled Active/Inactive instantly.

## [0.0.1+35] - 2026-02-18
### Added
- **UI Consolidation**: Unified "Raffles" and "Tournaments" into a single Exploration UI.
- **My Items**: Active Raffles & Tournaments now appear at the top of the exploration list.
- **Account Settings**: Added "Delete Account" functionality (GDPR/App Store compliance).
- **Wallet History**: Added Transaction History grouped by visit/date.
- **Security**: Restricted "Developer Options" to Super Admin role only.

### Fixed
- **Raffle Navigation**: Tapping a ticket now correctly opens the "Raffles" tab.

### Todo
- [ ] Add Legal Links (Privacy Policy, Terms of Service).

## [0.0.1+33] - 2026-02-18 - Security Hardening (Phase 48)

### Security
- **Firestore Rules**: Hardened security rules to prevent Privilege Escalation. Users can no longer modify sensitive fields like `role` or `points`.
- **Access Control**: Restricted write access to `raffles` and `specials` collections to Managers only.
- **Privacy**: Implemented `PublicProfile` architecture. User search now queries a sanitized public collection, protecting private user data (email, phone).

### Changed
- **AuthService**: Implemented "Dual-Write" logic. Updating a user profile now syncs safe data (username, bio, photo) to `public_profiles`.
- **Search**: Updated `UserSearchDelegate` to return `PublicProfile` objects instead of full `UserModel`.

## [0.0.1+32] - 2026-02-18 - Performance & Scalability (Phase 47)

### Optimized
- **Image Caching**: Integrated `cached_network_image` across the app (`SpecialCard`, `HallProfile`, `TournamentList`, `Gallery`) to significantly reduce bandwidth and memory usage.
- **Background Processing**: Moved complex recurrence projection logic (`_projectSpecials`) to a background Isolate, preventing UI freezes during feed loading.
- **Database Efficiency**: Implemented strict `limit(100)` and `asyncMap` patterns in `HallRepository` to ensure the app scales without crashing.

### Fixed
- **Build System**: Resolved import errors in `special_projection_logic.dart` and cleaned up unused imports.

## [0.0.1+32] - 2026-04-02 - Feed Serialization & Timestamp Alignment

### Added
- **Global Presence Context**: Live implementation of time-scaled online statuses (Online, Away, Offline). Users dynamically decay toward "Offline" after exactly 12 hours of inactivity based on native server-tracked session pings.
- **Historic Feed Profiling**: Profile screens for Businesses natively partition historic and upcoming timelines, elegantly surfacing base legacy templates chronologically ("Facebook-style") while suppressing excessive clone iterations.

### Fixed
- **Recurrence Caching Override**: Eliminated a structural glitch corrupting automatically generated iteration clones where `postedAt` references falsely inherited the physical creation-date of their legacy blueprint 7+ weeks prior. The system natively bypasses the `postedAt` index to calculate HypeScores reliably via the active algorithmic `startTime`.
- **Feed Expiration Segmentation**: Natively guarded the root Pagination algorithms to purge standalone content exactly past their pre-ordained `endsAt` expiration. Chronological timeline displays now completely forbid expired 7-week anomalies from populating client feeds.
- **Firebase Indexing Crashes**: Successfully resolved invisible `FAILED_PRECONDITION` index faults blocking memory-refreshes. Natively published compound `isTemplate` + `createdAt`/`postedAt` arrays onto Google Cloud.

## [0.0.1+31] - 2026-02-17 - CMS Improvements (Phase 44-46)

### Added
- **Context-Aware FABs**: `ManageTournamentsScreen` now shows "Create Template" when on the Templates tab, consistent with Raffles.
- **Active Raffle Editing**: Managers can now choose to **Edit Details** or **Launch Raffle Tool** when tapping an active raffle, preventing lockout from critical last-minute changes.
- **Photo Approval Fix**: Resolved a Firestore Index error preventing the Photo Approval queue from loading.

## [0.0.1+30] - 2026-02-17 - Tournaments & Raffle Refactor (Phase 42-43)

### Added
- **Tournament Images**: 
    - Added `imageUrl` to `TournamentModel`.
    - Updated `EditTournamentScreen` to support cover image upload.
    - Updated `TournamentListCard` to display the tournament image in the feed.
- **Raffle Templates**: 
    - Managers can now create Raffle Templates to quickly start recurring raffles.
    - Added "Templates" tab to `ManageRafflesScreen`.
    - Added "Save as Template" option to `EditRaffleScreen`.

### Changed
- **Raffle Workflow**: 
    - Refactored `ManageRafflesScreen` to use the standardized "Active / Expired / Templates" tabbed layout.
    - Updated `WalletScreen` and `HallProfileScreen` to filter out template raffles from public view.

## [0.0.1+29] - 2026-02-17 - Wallet Data Sync & Raffles (Phase 33-38)

### Added
- **My Raffles Screen**: dedicated screen to view user's collected tickets, accessible from Wallet "See All" and Profile "Raffles".
- **Dynamic Wallet Seeding**: updated "Seed Wallet Data" to clear "ghost" data, allowing for clean manual testing.

### Changed
- **Wallet Live Data**: "My Raffles" and "Active Tournaments" cards now subscribe to live Hall streams for real-time name updates.
- **Terminology Overhaul**: replaced all commercial terms (Buy/Purchase/Sold) with free-to-play terms (Collect/Acquire/Claimed).
- **Compliance**: updated Raffle Tool compliance dialog to explicitly state "No payment was required".
## [0.0.1+28] - 2026-02-17 - Specials Workflow Refactor

### Changed
- **Specials Feed**: References to templates are now strictly excluded from the `getSpecialsFeed` query (`isTemplate: false`).
- **CMS Workflow**:
    - **Context-Aware FABs**: "Create Special" and "Create Template" buttons now appear contextually based on the active tab.
    - **Publish Workflow**: Replaced "Save" with a robust **"Publish"** menu offering "Post Live", "Save as Template", and "Post & Save Template" options.
    - **Copy Logic**: Removed "Copy of" prefix for templates; copies are now created cleanly.

## [Unreleased] - Phase 30: Advanced Recurrence
### Added
- **RecurrenceRule**: Added robust recurrence model (frequency, interval, daysOfWeek, endCondition).
- **Schedule UI**: Collapsible "Schedule & Recurrence" section in `EditSpecialScreen`.
- **Custom Recurrence**: Modal support for "Every 2 weeks", specific days, and end dates.
- **HallRepository**: Advanced projection logic for custom recurrences.

## [0.0.1+27] - 2026-02-12 - Patch: Timezone Logic

### Fixed
- **Recurring Specials**: Fixed a timezone issue where recurring events were projecting using UTC hours instead of local "wall clock" time. This ensures 7 PM EST correctly projects to 7 PM on future dates, rather than shifting due to UTC offsets.

## [0.0.1+26] - 2026-02-12 - Specials Management & UX (Phase 28)

### Added
- **Multi-Select Delete**: Long-press on special cards to enter selection mode, allowing batch deletion of multiple items at once.
- **Dynamic Quick Select**: "Quick Select" images in the Special Editor now dynamically populate from your *historically used* images (from past specials).
- **Template Improvements**:
    - **Tap to Use**: Tapping a template card now immediately creates a *new copy* for use (without "Copy of" prefix).
    - **Edit Mode**: Dedicated Pencil icon for modifying the template itself.
- **Asset Library**: Updated Asset Library modal to also show historic images.

### Changed
- **UI Polish**: Improved visual feedback for selection mode and delete actions.

## [0.0.1+25] - 2026-02-08 - Unit Number Support

### Added
- **Address Detail**: Added `Unit/Suite` field support for Bingo Halls located in plazas.
    - **Data Model**: Updated `BingoHallModel` with `unitNumber`.
    - **CMS**: Added "Unit/Suite" input field to Hall Profile Editor.
    - **Display**: Hall Profile "About" tab now displays full address including unit number.
    - **Control**: Added explicit "State" field to Hall Profile Editor for manual override.
- **Operating Hours**: Added comprehensive schedule management.
    - **CMS**: Manual entry for each day's Open/Close times.
    - **Logic**: Automatically formats blank close times as "to CLOSE".
    - **Display**: Shown prominently on the "About" tab.
- **CMS Optimization**: Refactored "Edit Hall Profile" screen to use collapsible sections for better organization and reduced scrolling.
- **Program Details**: Added ability to manage multiple bingo programs.
    - **Features**: Name, Multi-line Pricing/Details, and multi-day selection (Samsung-style).
    - **Timeframe**: Added Start/End Time for each program.
    - **Status**: Implemented "Smart Activation". Programs are active based on their schedule.
    - **Override**: Managers can force a program "Active" until a specific time using the checkbox.
    - **Display**: Added "PROGRAMS" tab to Hall Profile screen to showcase these details.
    - **UI Polish**: Improved text contrast on dark backgrounds for "About" and "Programs" tabs.
    - **Charities**: Added "Charities & Partnerships" section to Hall Profile Editor.
    - **Fix**: Resolved clipping issue in Hall Profile Editor.

## [0.0.1+24] - 2026-02-06 - Social Photo Gallery (Phase 26)

### Added
- **Social Gallery**: Complete ecosystem for uploading, viewing, and moderating photos.
    - **Upload Workflow**: Users can upload photos with captions and tags (Halls & Friends).
    - **Tagging**: "Personal" uploads appear instantly. "Hall" tags require approval. Tagging UI includes search delegates and smart chips.
    - **Display**: Instagram-style 3-column grid for Halls, "My Gallery" for users.
    - **Lightbox**: Full-screen photo viewer with pinch-to-zoom.
- **Moderation Tools**: 
    - **Approval Flow**: Hall Managers can Approve/Decline tagged photos.
    - **Safety**: "Report" button for users, auto-hiding content after 5 reports. Strict ToS warning on upload.
    - **Delete**: Owners can delete their own photos.
- **Smart UI**: 
    - **Personal Badge**: Untagged photos get a "PERSONAL" badge on the user profile.
    - **Context Awareness**: "Tag Hall" button hides when uploading directly from a Hall Profile.

### Changed
- **Profile Navigation**: Added "Gallery" pill button to Hall Profile header.
- **User Profile**: Added "My Photos" section with status indicators (Live/Pending/Declined).

## [0.0.1+23] - 2026-02-02 - Smart Recurrence & UI Polish (Phase 21)

### Added
- **Smart Rotation**: recurring specials (Daily, Weekly, Monthly) now technically "rotate" in the feed, projecting their start/end times to the next logical date automatically.
- **Calendar Integration**: "Add to Calendar" button is now fully functional on Android & iOS, with proper permission handling.
- **Smart Dates**: Special Cards now display friendly recurrence text (e.g., "Every Friday at 7 PM") instead of raw timestamps.

### Changed
- **Midnight Rule**: Specials created without an explicit End Time now default to ending at 11:59 PM of the start day, preventing open-ended events.
- **Navigation**: Removed the redundant "Map View" quick action button, consolidating map access to the "Find Hall" button.



### Added
- **Manager Mode**: Secure "Admin Mode" for venue operators, protected by a PIN Gateway (`4836`).
- **Dashboard Hub**: Centralized dashboard for accessing management modules (Profile, Specials, Tournaments, Raffles).
- **Profile CMS**: Operators can now edit their Hall's Name, Bio, Phone, Website, and Logo directly from the app.
- **Specials CMS**: Full CRUD (Create, Read, Update, Delete) interface for managing Special Events with Date/Time pickers.
- **Raffle Utility**: A compliance-focused tool for running manual drawings:
    - **Roll Call**: Generates a 4-digit code for users to join.
    - **Session Logic**: Lists participants, locks entry, distributes tickets, and draws a random winner.
- **Super-Admin Tools**: Added "View As" mode in Profile Settings to toggle between roles (`Super Admin`, `Owner`, `Worker`, `Player`) for testing permissions.

### Changed
- **Permissions**: Updated `ProfileScreen` to show "Switch to Manager Mode" button for `owner`, `manager` `admin`, and `super-admin`.
- **Data Models**: Updated `BingoHallModel` to include `phone`, `websiteUrl`, and `description` fields.
- **Seeding**: Updated `seedMaryEstherEnv` to set the user as `super-admin` for full access to all tools.

### Fixed
- **Null Safety**: Resolved potential crashes in `ManageSpecialsScreen` regarding nullable start times.

## [0.0.1+22] - 2026-01-30 - Recurring Specials & Robust UI (Phase 21)

### Added
- **Recurring Specials**: Added "Recurrence" dropdown to Edit Special screen (`Daily`, `Weekly`, `Monthly`), enabling automated schedule logic.
- **End Time Option**: Admins can now optionally set an End Time for specials via a checkbox toggle.
- **Push Notification Trigger**: "Send Push Notification" checkbox added to the edit/create flow, guarded by a "Notification Fatigue" warning dialog to prevent spam.
- **Image Integration**: Specials creation now supports uploading directly from Gallery/Camera or selecting from the Hall's Asset Library.

### Changed
- **Date Picker UI**: Replaced standard `TextFormField` date inputs with custom `InkWell` + `InputDecorator` buttons to ensure 100% touch responsiveness and prevent keyboard conflicts.
- **Draft Safety**: Confirmed that all Special edits remain in a local "Draft" state until the **Save** button is explicitly pressed.

### Fixed
- **Runtime Crash**: Resolved a "Dependency on Inherited Widget" crash caused by accessing `context` inside `initState` for date formatting.
- **Date Range**: Widened the Date Picker range (2020-2030) to facilitate backdating or editing past specials without assertion errors.

## [0.0.1+21] - 2026-01-29 - Navigation Improvements & Biometrics (Phase 23 & 24)

### Added
- **Biometric Security**: Integrated FaceID and Fingerprint authentication (`local_auth`) for accessing the Hall Manager Dashboard.
- **Biometric Fallback**: Standard PIN (`4836`) remains available as a fallback method.
- **Deep Linking**: Implemented `initialTabIndex` on `HallProfileScreen` to allow direct navigation to specific tabs (e.g., Raffles).

### Changed
- **Wallet Navigation**: Tapping a raffle ticket in the Wallet now navigates directly to the "Active Raffles" tab of the specific Hall Profile.
- **Configuration**: Updated `AndroidManifest.xml` and `Info.plist` to include native biometric permission declarations.

### Fixed
- **Build Errors**: Resolved `local_auth` API version mismatch by using standard parameter signatures.
- **Orientation**: Locked application to Portrait Mode for consistent experience across devices.

## [0.0.1+19] - 2026-01-28 - Wallet System & Bonus Logic (Phase 19)

### Added
- **Wallet System**: Comprehensive wallet UI displaying Hall Membership Cards, Raffle Ticket Stubs, and Active Tournaments.
- **Hall Memberships**: Logic to track balances per hall. Cards are automatically created when "Following" a hall.
- **Follow Bonus**: Halls can now offer a point bonus (e.g., +50 pts) instantly upon following. "Westside Winners" configured with 50pt bonus for testing.
- **QR Integration**: Scanning a worker's QR code now credits points specifically to that hall's membership card (verifying "Following" status first).
- **Mock Data Seeding**: "Seed Wallet Data" and updated "Seed Specials" to test wallet features and bonuses.

### Changed
- **Map Refinement**: Increased zoom limit to support full 100-mile radius. Removed blue radius circle overlay.
- **Image Stability**: Switched from dynamic LoremFlickr to static Unsplash images for consistent UI testing.
- **Search Logic**: Map zoom level and radius slider are now bidirectionally synchronized.
- **Dependencies**: Added `intl` for currency formatting.

### Fixed
- **GlassContainer**: Fixed sizing constraint issues.
- **Data Models**: Resolved `freezed` generation errors by enforcing `abstract class` definitions.

## [2026-01-28] - Map Refinement & Persistent Images (Phase 17.9 & 18.5)

### Map Search & Logic
- **Advanced Filtering**: Implemented "Visible Region" filtering. "Halls Nearby" list now updates dynamically to show strictly what is visible in the map viewport.
- **Bi-Directional Sync**: Radius Slider and Map Zoom are now synchronized. Zooming the map updates the slider, and sliding the radius smooth-zooms the map.
- **Constraints**: Enforced a `minZoom` preference (approx 100mi radius) to prevent massive, unperformant queries.
- **UI Clean Up**: Removed visual radius circle overlay for a cleaner, less obstructed map view.

### Infrastructure
- **Image Persistence**: Updated `HallRepository` to use static, high-quality Unsplash URLs for seeded Specials, resolving the issue of randomly changing images.
- **Storage**: Integrated Firebase Storage for profile and banner image uploads.
- **Settings**: Relocated "Logout" functionality to a new clean Settings modal in the Profile Screen.

---

## [2026-01-26] - Scalable Geohashing Map, Profile Logic & Auth Updates (Phase 17.5 & 18)

### Scalability & Infrastructure
- **Geohashing**: Migrated Hall Search to use `geoflutterfire_plus` for server-side geohashing, enabling infinite scalability (suppots 10k+ locations without client overload).
- **Optimization**: Implemented "Debounce" logic (100ms throttle) on map interactions to prevent excessive Firestore reads and reduce billing costs.
- **Data Integrity**: Updated Admin Seed tools (`seedSpecials`, `createMockHall`) to automatically generate valid `geoHash` fields for all mock data.

### Map Features
- **Smart Search**: Added a `HallSearchScreen` with Google Maps, Address Geocoding (City/Zip search), and a Radius Slider (1-100mi).
- **Streaming**: "Live Crosshair" logic streams only visible halls in the current viewport/radius using `RxDart`.

### User Profile (Phase 18)
- **Service**: Added `updateUserProfile` to `AuthService` (First/Last Name, Username, Bio).
- **UI Refresh**: Implemented a complete Profile Screen redesign featuring:
    - **Header**: Avatar using Initials + Edit Profile Dialog.
    - **Actions**: "My Tournaments" & "My Raffles" quick access buttons.
    - **Bio Section**: Dedicated "About Me" area with a clean divider.
    - **Menu**: Collapsible "Developer Options" for admin seeding tools.

### Authentication
- **Methods**: Integrated `sign_in_with_apple` and `flutter_facebook_auth` dependencies.
- **Security**: Hardened `AuthWrapper` to handle user profile creation/routing more robustly.

---

## [2026-01-24] - Visual Polish, Smart Cards & Upcoming Games (Phase 10-17)

### UI & UX Redesign
- **Smart Cards**: Introduced a unified `SpecialCard` widget with stateful expansion, embedded action buttons (Call, Navigate, Calendar), and tag display.
- **Interactivity**: Added `url_launcher` for phone calls/navigation and `add_2_calendar` for one-tap event saving.
- **Directory**: "Upcoming Games" screen redesigned with a "Spotify-style" category grid ("Session", "Pulltabs", "Progressives") for easier browsing.
- **Accessibility**: Improved color contrast ratios for category text and action buttons.

### Geo-Fencing
- **Feed Logic**: Home Screen "Specials Feed" now limits results to a **75-mile radius** from the user's location, sorted by "Happening Now".

---

## [2026-01-23] - Security, Scanner & Geolocation (Phase 7-9)

### Security & Roles
- **RBAC**: Implemented Role-Based Access Control (`worker`, `owner`, `admin`) secured by `firestore.rules`.
- **Public Workers**: Separated Verified Worker Identity into a public `public_workers` collection to protect PII during scans.
- **Scanner Audit**: Updated `TransactionService` to record `authorizedByWorkerId` on every point transaction for full auditability.
- **Strict Verification**: `ScanActionDialog` now strictly verifies worker QR tokens against the public registry before processing points.

### Geolocation
- **GPS**: Added `geolocator` dependency and `LocationService`.
- **Proximity**: Updated Home Screen to display real-time distance to halls (e.g., "3.2 mi") sorted by proximity.
- **Battery**: Optimized GPS tracking to use `LocationAccuracy.balanced` (100m filter) to preserve user battery life.

---

## [2026-01-22] - Foundation & Authentication (Phase 1-6)

### Core Infrastructure
- **Setup**: Initialized project structure, dependencies (`riverpod`, `freezed`, `json_serializable`), and Firebase configuration.
- **Database**: Defined core data models: `UserModel`, `BingoHallModel`, `TransactionModel`.
- **Theme**: Implemented `AppTheme` with custom color palette and typography.

### Features
- **Authentication**: Built `AuthService` with Google Sign-In and Email/Password flow.
- **Scan-to-Earn**: Created the core "Game Loop" where users scan a QR code at a kiosk to earn points instantly.
- **Wallet**: Developed `WalletScreen` with real-time point balance updates via Firestore streams.



## Future Roadmap - Beacon Integration Revisit
*Items to revisit once hardware Beacons are deployed:*
- **Raffle System**: Current logic relies on manual "Roll Call" codes. Beacon proximity can automate checking in for raffles without codes.
- **Auto-Checkin**: Move from scanning QR codes to passive point earning upon entry.
