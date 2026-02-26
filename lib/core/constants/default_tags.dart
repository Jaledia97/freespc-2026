import 'package:flutter/material.dart';

class DefaultTags {
  static const List<String> categories = [
    'Session',
    'Regular Program',
    'Specials', 
    'Pulltabs', 
    'Progressives', 
    'Raffles',
    'Tournaments',
    'New Player'
  ];

  static const List<Color> categoryColors = [
    Colors.purple,
    Colors.blue,
    Colors.deepOrange,
    Colors.teal,
    Colors.redAccent,
    Colors.green,
    Colors.indigo,
    Colors.pink,
  ];

  static Color getColorForTag(String tag) {
    int index = categories.indexOf(tag);
    if (index != -1) {
      return categoryColors[index % categoryColors.length];
    }
    // Return a default hashing color for custom tags
    final hash = tag.hashCode;
    return categoryColors[hash.abs() % categoryColors.length];
  }
}
