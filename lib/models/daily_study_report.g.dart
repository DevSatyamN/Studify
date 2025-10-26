// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'daily_study_report.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DailyStudyReportAdapter extends TypeAdapter<DailyStudyReport> {
  @override
  final int typeId = 11;

  @override
  DailyStudyReport read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DailyStudyReport(
      id: fields[0] as String,
      date: fields[1] as DateTime,
      subjectData: (fields[2] as Map).cast<String, SubjectStudyData>(),
      totalStudyTime: fields[3] as int,
      totalSessions: fields[4] as int,
      createdAt: fields[5] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, DailyStudyReport obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.date)
      ..writeByte(2)
      ..write(obj.subjectData)
      ..writeByte(3)
      ..write(obj.totalStudyTime)
      ..writeByte(4)
      ..write(obj.totalSessions)
      ..writeByte(5)
      ..write(obj.createdAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DailyStudyReportAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class SubjectStudyDataAdapter extends TypeAdapter<SubjectStudyData> {
  @override
  final int typeId = 12;

  @override
  SubjectStudyData read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SubjectStudyData(
      subjectId: fields[0] as String,
      subjectName: fields[1] as String,
      totalTime: fields[2] as int,
      sessions: (fields[3] as List).cast<StudySessionData>(),
      chaptersStudied: (fields[4] as Map).cast<String, int>(),
    );
  }

  @override
  void write(BinaryWriter writer, SubjectStudyData obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.subjectId)
      ..writeByte(1)
      ..write(obj.subjectName)
      ..writeByte(2)
      ..write(obj.totalTime)
      ..writeByte(3)
      ..write(obj.sessions)
      ..writeByte(4)
      ..write(obj.chaptersStudied);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SubjectStudyDataAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class StudySessionDataAdapter extends TypeAdapter<StudySessionData> {
  @override
  final int typeId = 13;

  @override
  StudySessionData read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return StudySessionData(
      startTime: fields[0] as DateTime,
      duration: fields[1] as int,
      chapterName: fields[2] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, StudySessionData obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.startTime)
      ..writeByte(1)
      ..write(obj.duration)
      ..writeByte(2)
      ..write(obj.chapterName);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StudySessionDataAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
