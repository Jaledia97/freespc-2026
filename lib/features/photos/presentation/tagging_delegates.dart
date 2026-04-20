import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../home/repositories/venue_repository.dart';
import '../../../models/venue_model.dart';
import '../../../models/public_profile.dart';
import '../../../services/auth_service.dart';

class HallSearchDelegate extends SearchDelegate<VenueModel?> {
  final WidgetRef ref;

  HallSearchDelegate(this.ref);

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(icon: const Icon(Icons.clear), onPressed: () => query = ''),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => close(context, null),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        return FutureBuilder<List<VenueModel>>(
          future: ref.read(venueRepositoryProvider).searchHalls(query),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting)
              return const Center(child: CircularProgressIndicator());
            if (!snapshot.hasData || snapshot.data!.isEmpty)
              return const Center(child: Text("No venues found"));

            final venues = snapshot.data!;
            return ListView.builder(
              itemCount: venues.length,
              itemBuilder: (context, index) {
                final venue = venues[index];
                return ListTile(
                  title: Text(venue.name),
                  subtitle: Text("${venue.city}, ${venue.state}"),
                  onTap: () => close(context, venue),
                );
              },
            );
          },
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    if (query.length < 2)
      return const Center(child: Text("Search for venues..."));
    return buildResults(context);
  }
}

class UserSearchDelegate extends SearchDelegate<PublicProfile?> {
  final WidgetRef ref;

  UserSearchDelegate(this.ref);

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(icon: const Icon(Icons.clear), onPressed: () => query = ''),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => close(context, null),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        return FutureBuilder<List<PublicProfile>>(
          future: ref.read(authServiceProvider).searchUsers(query),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting)
              return const Center(child: CircularProgressIndicator());
            if (!snapshot.hasData || snapshot.data!.isEmpty)
              return const Center(child: Text("No users found"));

            final users = snapshot.data!;
            return ListView.builder(
              itemCount: users.length,
              itemBuilder: (context, index) {
                final user = users[index];
                return ListTile(
                  leading: const CircleAvatar(child: Icon(Icons.person)),
                  title: Text("${user.firstName} ${user.lastName}"),
                  subtitle: Text("@${user.username}"),
                  onTap: () => close(context, user),
                );
              },
            );
          },
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    if (query.length < 2) {
      return Consumer(
        builder: (context, ref, _) {
          return FutureBuilder<List<PublicProfile>>(
            future: ref.read(authServiceProvider).getSuggestedUsers(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting)
                return const Center(child: CircularProgressIndicator());
              if (!snapshot.hasData || snapshot.data!.isEmpty)
                return const Center(child: Text("Search for friends..."));

              final users = snapshot.data!;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text(
                      "Suggested Friends",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: users.length,
                      itemBuilder: (context, index) {
                        final user = users[index];
                        return ListTile(
                          leading: const CircleAvatar(
                            child: Icon(Icons.person),
                          ),
                          title: Text("${user.firstName} ${user.lastName}"),
                          subtitle: Text("@${user.username}"),
                          onTap: () => close(context, user),
                        );
                      },
                    ),
                  ),
                ],
              );
            },
          );
        },
      );
    }
    return buildResults(context);
  }
}
