// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'diary_entry_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DiaryEntryModelAdapter extends TypeAdapter<DiaryEntryModel> {
  @override
  final int typeId = 0;

  @override
  DiaryEntryModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DiaryEntryModel(
      id: fields[0] as String,
      title: fields[1] as String,
      content: fields[2] as String,
      createdAt: fields[3] as DateTime,
      updatedAt: fields[4] as DateTime,
      mood: fields[5] as String,
      category: fields[6] as String,
      tags: (fields[7] as List).cast<String>(),
      richContent: fields[8] as String?,
      wordCount: fields[9] as int,
      isFavorite: fields[10] as bool,
      isPrivate: fields[11] as bool,
      attachments: (fields[12] as List).cast<String>(),
      latitude: fields[13] as double?,
      longitude: fields[14] as double?,
      weather: fields[15] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, DiaryEntryModel obj) {
    writer
      ..writeByte(16)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.content)
      ..writeByte(3)
      ..write(obj.createdAt)
      ..writeByte(4)
      ..write(obj.updatedAt)
      ..writeByte(5)
      ..write(obj.mood)
      ..writeByte(6)
      ..write(obj.category)
      ..writeByte(7)
      ..write(obj.tags)
      ..writeByte(8)
      ..write(obj.richContent)
      ..writeByte(9)
      ..write(obj.wordCount)
      ..writeByte(10)
      ..write(obj.isFavorite)
      ..writeByte(11)
      ..write(obj.isPrivate)
      ..writeByte(12)
      ..write(obj.attachments)
      ..writeByte(13)
      ..write(obj.latitude)
      ..writeByte(14)
      ..write(obj.longitude)
      ..writeByte(15)
      ..write(obj.weather);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DiaryEntryModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
