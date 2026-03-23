import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/profile/presentation/public_profile_screen.dart';
import '../../services/auth_service.dart';

class UsernameRouter extends ConsumerWidget {
  final String text;
  final TextStyle? style;
  final TextStyle? linkStyle;

  const UsernameRouter({
    super.key,
    required this.text,
    this.style,
    this.linkStyle,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final defaultStyle = style ?? const TextStyle(color: Colors.white, fontSize: 14);
    final highlightStyle = linkStyle ?? const TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold);

    // Regex to match @username (letters, numbers, underscores)
    final RegExp exp = RegExp(r'(@[a-zA-Z0-9_]+)');
    final Iterable<RegExpMatch> matches = exp.allMatches(text);

    if (matches.isEmpty) {
      return Text(text, style: defaultStyle);
    }

    final List<TextSpan> spans = [];
    int start = 0;

    for (var match in matches) {
      if (match.start > start) {
        spans.add(TextSpan(text: text.substring(start, match.start), style: defaultStyle));
      }

      final String usernameWithAt = match.group(0)!;
      final String username = usernameWithAt.substring(1); // remove @

      spans.add(
        TextSpan(
          text: usernameWithAt,
          style: highlightStyle,
          recognizer: TapGestureRecognizer()
            ..onTap = () async {
              // Fetch the profile dynamically
              final authService = ref.read(authServiceProvider);
              final profiles = await authService.searchUsers(username);
              
              if (profiles.isNotEmpty && context.mounted) {
                final targetProfile = profiles.firstWhere(
                  (p) => p.username.toLowerCase() == username.toLowerCase(), 
                  orElse: () => profiles.first
                );
                
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => PublicProfileScreen(profile: targetProfile),
                  ),
                );
              } else if (context.mounted) {
                 ScaffoldMessenger.of(context).showSnackBar(
                   const SnackBar(content: Text("User not found."))
                 );
              }
            },
        ),
      );
      start = match.end;
    }

    if (start < text.length) {
      spans.add(TextSpan(text: text.substring(start), style: defaultStyle));
    }

    return RichText(text: TextSpan(children: spans));
  }
}
