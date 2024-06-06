// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'link_tree_folder_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class LinkTreeFolderAdapter extends TypeAdapter<LinkTreeFolder> {
  @override
  final int typeId = 1;

  @override
  LinkTreeFolder read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return LinkTreeFolder(
      id: fields[0] as String,
      parentFolderId: fields[1] as String,
      subFolders: (fields[3] as List).cast<String>(),
      urls: (fields[4] as List)
          .map((dynamic e) => (e as Map).cast<String, dynamic>())
          .toList(),
      folderName: fields[2] as String,
      isFavourite: fields[5] as bool,
      category: fields[6] as String?,
      description: fields[7] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, LinkTreeFolder obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.parentFolderId)
      ..writeByte(2)
      ..write(obj.folderName)
      ..writeByte(3)
      ..write(obj.subFolders)
      ..writeByte(4)
      ..write(obj.urls)
      ..writeByte(5)
      ..write(obj.isFavourite)
      ..writeByte(6)
      ..write(obj.category)
      ..writeByte(7)
      ..write(obj.description);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LinkTreeFolderAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
