import 'package:hive/hive.dart';
import 'package:flutter/material.dart';

part 'subject.g.dart';

@HiveType(typeId: 1)
class Subject extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String description;

  @HiveField(3)
  int colorValue; // Store color as int

  @HiveField(4)
  DateTime createdAt;

  @HiveField(5)
  int totalStudyTime; // in minutes

  @HiveField(6)
  int totalSessions;

  @HiveField(7)
  bool isActive;

  Subject({
    required this.id,
    required this.name,
    required this.description,
    required this.colorValue,
    required this.createdAt,
    this.totalStudyTime = 0,
    this.totalSessions = 0,
    this.isActive = true,
  });

  Color get color => Color(colorValue);

  set color(Color newColor) {
    colorValue = newColor.value;
  }

  factory Subject.create({
    required String name,
    required String description,
    required Color color,
  }) {
    return Subject(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      description: description,
      colorValue: color.value,
      createdAt: DateTime.now(),
    );
  }

  void updateStats(int sessionDuration) {
    totalStudyTime += sessionDuration;
    totalSessions++;
    save();
  }
}
