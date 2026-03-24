import 'package:flutter/material.dart';

class ExpandablePostText extends StatefulWidget {
  final String text;
  final int maxLines;

  const ExpandablePostText({super.key, required this.text, this.maxLines = 3});

  @override
  State<ExpandablePostText> createState() => _ExpandablePostTextState();
}

class _ExpandablePostTextState extends State<ExpandablePostText> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    if (widget.text.isEmpty) return const SizedBox.shrink();

    return LayoutBuilder(
      builder: (context, size) {
        final span = TextSpan(
          text: widget.text,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: Colors.white70),
        );
        final tp = TextPainter(
          maxLines: widget.maxLines,
          textAlign: TextAlign.left,
          textDirection: TextDirection.ltr,
          text: span,
        );
        tp.layout(maxWidth: size.maxWidth);

        if (tp.didExceedMaxLines) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AnimatedSize(
                duration: const Duration(milliseconds: 200),
                alignment: Alignment.topCenter,
                child: Text(
                  widget.text,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: Colors.white70),
                  maxLines: _isExpanded ? null : widget.maxLines,
                  overflow: _isExpanded
                      ? TextOverflow.visible
                      : TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: 4),
              GestureDetector(
                onTap: () => setState(() => _isExpanded = !_isExpanded),
                child: Text(
                  _isExpanded ? "See less" : "...See more",
                  style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          );
        } else {
          return Text(
            widget.text,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.white70),
          );
        }
      },
    );
  }
}
