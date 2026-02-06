import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../home/repositories/hall_repository.dart';
import '../../../models/bingo_hall_model.dart';
import '../../../models/user_model.dart';
import '../../../services/auth_service.dart';

class HallSearchDelegate extends SearchDelegate<BingoHallModel?> {
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
       return FutureBuilder<List<BingoHallModel>>(
        future: ref.read(hallRepositoryProvider).searchHalls(query),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          if (!snapshot.hasData || snapshot.data!.isEmpty) return const Center(child: Text("No halls found"));
          
          final halls = snapshot.data!;
          return ListView.builder(
            itemCount: halls.length,
            itemBuilder: (context, index) {
              final hall = halls[index];
              return ListTile(
                title: Text(hall.name),
                subtitle: Text("${hall.city}, ${hall.state}"),
                onTap: () => close(context, hall),
              );
            },
          );
        },
      );
      }
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    if (query.length < 2) return const Center(child: Text("Search for halls..."));
    return buildResults(context);
  }
}

class UserSearchDelegate extends SearchDelegate<UserModel?> {
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
       return FutureBuilder<List<UserModel>>(
        future: ref.read(authServiceProvider).searchUsers(query),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          if (!snapshot.hasData || snapshot.data!.isEmpty) return const Center(child: Text("No users found"));
          
          final users = snapshot.data!;
          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];
              return ListTile(
                leading: const CircleAvatar(child: Icon(Icons.person)),
                title: Text("${user.firstName} ${user.lastName}"),
                subtitle: Text("@${user.username ?? 'user'}"),
                onTap: () => close(context, user),
              );
            },
          );
        },
      );
      }
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    if (query.length < 2) return const Center(child: Text("Search for friends..."));
    return buildResults(context);
  }
}
