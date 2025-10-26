// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'syllabus_group.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SyllabusGroupAdapter extends TypeAdapter<SyllabusGroup> {
  @override
  final int typeId = 7;

  @override
  SyllabusGroup read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SyllabusGroup(
      id: fields[0] as String,
      name: fields[1] as String,
      description: fields[2] as String,
      subjects: (fields[3] as List).cast<SyllabusSubject>(),
      createdAt: fields[4] as DateTime,
      targetDate: fields[5] as DateTime?,
      priority: fields[6] as int,
      color: fields[7] as String,
      icon: fields[8] as String,
      totalTimeSpent: fields[9] as int,
    );
  }

  @override
  void write(BinaryWriter writer, SyllabusGroup obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.subjects)
      ..writeByte(4)
      ..write(obj.createdAt)
      ..writeByte(5)
      ..write(obj.targetDate)
      ..writeByte(6)
      ..write(obj.priority)
      ..writeByte(7)
      ..write(obj.color)
      ..writeByte(8)
      ..write(obj.icon)
      ..writeByte(9)
      ..write(obj.totalTimeSpent);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SyllabusGroupAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class SyllabusSubjectAdapter extends TypeAdapter<SyllabusSubject> {
  @override
  final int typeId = 8;

  @override
  SyllabusSubject read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SyllabusSubject(
      id: fields[0] as String,
      name: fields[1] as String,
      description: fields[2] as String,
      chapters: (fields[3] as List).cast<SyllabusChapter>(),
      createdAt: fields[6] as DateTime,
      completedChapters: (fields[4] as List?)?.cast<String>(),
      totalTimeSpent: fields[5] as int,
    );
  }

  @override
  void write(BinaryWriter writer, SyllabusSubject obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.chapters)
      ..writeByte(4)
      ..write(obj.completedChapters)
      ..writeByte(5)
      ..write(obj.totalTimeSpent)
      ..writeByte(6)
      ..write(obj.createdAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SyllabusSubjectAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class SyllabusChapterAdapter extends TypeAdapter<SyllabusChapter> {
  @override
  final int typeId = 9;

  @override
  SyllabusChapter read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SyllabusChapter(
      id: fields[0] as String,
      name: fields[1] as String,
      description: fields[2] as String,
      topics: (fields[3] as List).cast<String>(),
      createdAt: fields[6] as DateTime,
      completedTopics: (fields[4] as List?)?.cast<String>(),
      timeSpent: fields[5] as int,
      isCompleted: fields[7] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, SyllabusChapter obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.topics)
      ..writeByte(4)
      ..write(obj.completedTopics)
      ..writeByte(5)
      ..write(obj.timeSpent)
      ..writeByte(6)
      ..write(obj.createdAt)
      ..writeByte(7)
      ..write(obj.isCompleted);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SyllabusChapterAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
