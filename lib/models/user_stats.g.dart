// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_stats.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UserStatsAdapter extends TypeAdapter<UserStats> {
  @override
  final int typeId = 4;

  @override
  UserStats read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserStats(
      totalXP: fields[0] as int,
      currentLevel: fields[1] as int,
      currentStreak: fields[2] as int,
      longestStreak: fields[3] as int,
      lastStudyDate: fields[4] as DateTime?,
      totalStudyTime: fields[5] as int,
      totalSessions: fields[6] as int,
      pomodoroSessions: fields[7] as int,
      createdAt: fields[8] as DateTime,
      unlockedAchievements: (fields[9] as List).cast<String>(),
      userName: fields[10] as String,
      freezeTokens: fields[11] as int,
      lastFreezeTokenDate: fields[12] as DateTime?,
      studyDates: (fields[13] as List).cast<String>(),
    );
  }

  @override
  void write(BinaryWriter writer, UserStats obj) {
    writer
      ..writeByte(14)
      ..writeByte(0)
      ..write(obj.totalXP)
      ..writeByte(1)
      ..write(obj.currentLevel)
      ..writeByte(2)
      ..write(obj.currentStreak)
      ..writeByte(3)
      ..write(obj.longestStreak)
      ..writeByte(4)
      ..write(obj.lastStudyDate)
      ..writeByte(5)
      ..write(obj.totalStudyTime)
      ..writeByte(6)
      ..write(obj.totalSessions)
      ..writeByte(7)
      ..write(obj.pomodoroSessions)
      ..writeByte(8)
      ..write(obj.createdAt)
      ..writeByte(9)
      ..write(obj.unlockedAchievements)
      ..writeByte(10)
      ..write(obj.userName)
      ..writeByte(11)
      ..write(obj.freezeTokens)
      ..writeByte(12)
      ..write(obj.lastFreezeTokenDate)
      ..writeByte(13)
      ..write(obj.studyDates);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserStatsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
