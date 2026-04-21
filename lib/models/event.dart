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
    required this.latitude,
    required this.longitude,
    required this.distanceMiles,
    required this.attendeeCount,
    required this.hostName,
    this.createdByUser = false,
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
  final double latitude;
  final double longitude;
  final double distanceMiles;
  final int attendeeCount;
  final String hostName;
  final bool createdByUser;

  Event copyWith({
    String? id,
    String? title,
    String? category,
    String? description,
    String? locationName,
    DateTime? dateTime,
    Color? color,
    double? mapX,
    double? mapY,
    double? latitude,
    double? longitude,
    double? distanceMiles,
    int? attendeeCount,
    String? hostName,
    bool? createdByUser,
  }) {
    return Event(
      id: id ?? this.id,
      title: title ?? this.title,
      category: category ?? this.category,
      description: description ?? this.description,
      locationName: locationName ?? this.locationName,
      dateTime: dateTime ?? this.dateTime,
      color: color ?? this.color,
      mapX: mapX ?? this.mapX,
      mapY: mapY ?? this.mapY,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      distanceMiles: distanceMiles ?? this.distanceMiles,
      attendeeCount: attendeeCount ?? this.attendeeCount,
      hostName: hostName ?? this.hostName,
      createdByUser: createdByUser ?? this.createdByUser,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'category': category,
      'description': description,
      'locationName': locationName,
      'dateTime': dateTime.toIso8601String(),
      'color': color.toARGB32(),
      'mapX': mapX,
      'mapY': mapY,
      'latitude': latitude,
      'longitude': longitude,
      'distanceMiles': distanceMiles,
      'attendeeCount': attendeeCount,
      'hostName': hostName,
      'createdByUser': createdByUser,
    };
  }

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: json['id'] as String,
      title: json['title'] as String,
      category: json['category'] as String,
      description: json['description'] as String,
      locationName: json['locationName'] as String,
      dateTime: DateTime.parse(json['dateTime'] as String),
      color: Color((json['color'] as num).toInt()),
      mapX: (json['mapX'] as num).toDouble(),
      mapY: (json['mapY'] as num).toDouble(),
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      distanceMiles: (json['distanceMiles'] as num).toDouble(),
      attendeeCount: (json['attendeeCount'] as num).toInt(),
      hostName: json['hostName'] as String,
      createdByUser: (json['createdByUser'] as bool?) ?? false,
    );
  }
}
