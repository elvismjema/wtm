import 'package:flutter/material.dart';

class Event {
  const Event({
    required this.id,
    required this.title,
    required this.category,
    required this.description,
    required this.locationName,
    required this.dateTime,
    required this.color,
    required this.mapX,
    required this.mapY,
  });

  final String id;
  final String title;
  final String category;
  final String description;
  final String locationName;
  final DateTime dateTime;
  final Color color;
  final double mapX;
  final double mapY;
}
