// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'collection_model.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetCollectionModelCollection on Isar {
  IsarCollection<CollectionModel> get collectionModels => this.collection();
}

const CollectionModelSchema = CollectionSchema(
  name: r'CollectionModel',
  id: -6238448902296436685,
  properties: {
    r'backgroundJson': PropertySchema(
      id: 0,
      name: r'backgroundJson',
      type: IsarType.string,
    ),
    r'createdAt': PropertySchema(
      id: 1,
      name: r'createdAt',
      type: IsarType.dateTime,
    ),
    r'description': PropertySchema(
      id: 2,
      name: r'description',
      type: IsarType.string,
    ),
    r'iconJson': PropertySchema(
      id: 3,
      name: r'iconJson',
      type: IsarType.string,
    ),
    r'id': PropertySchema(
      id: 4,
      name: r'id',
      type: IsarType.string,
    ),
    r'isArchived': PropertySchema(
      id: 5,
      name: r'isArchived',
      type: IsarType.bool,
    ),
    r'isPinned': PropertySchema(
      id: 6,
      name: r'isPinned',
      type: IsarType.bool,
    ),
    r'lastAccessedAt': PropertySchema(
      id: 7,
      name: r'lastAccessedAt',
      type: IsarType.dateTime,
    ),
    r'layoutType': PropertySchema(
      id: 8,
      name: r'layoutType',
      type: IsarType.string,
    ),
    r'name': PropertySchema(
      id: 9,
      name: r'name',
      type: IsarType.string,
    ),
    r'parentCollectionId': PropertySchema(
      id: 10,
      name: r'parentCollectionId',
      type: IsarType.string,
    ),
    r'position': PropertySchema(
      id: 11,
      name: r'position',
      type: IsarType.long,
    ),
    r'settingsJson': PropertySchema(
      id: 12,
      name: r'settingsJson',
      type: IsarType.string,
    ),
    r'sortOrder': PropertySchema(
      id: 13,
      name: r'sortOrder',
      type: IsarType.string,
    ),
    r'statusJson': PropertySchema(
      id: 14,
      name: r'statusJson',
      type: IsarType.string,
    ),
    r'totalClicks': PropertySchema(
      id: 15,
      name: r'totalClicks',
      type: IsarType.long,
    ),
    r'updatedAt': PropertySchema(
      id: 16,
      name: r'updatedAt',
      type: IsarType.dateTime,
    ),
    r'urlCount': PropertySchema(
      id: 17,
      name: r'urlCount',
      type: IsarType.long,
    ),
    r'userId': PropertySchema(
      id: 18,
      name: r'userId',
      type: IsarType.string,
    ),
    r'visibility': PropertySchema(
      id: 19,
      name: r'visibility',
      type: IsarType.string,
    )
  },
  estimateSize: _collectionModelEstimateSize,
  serialize: _collectionModelSerialize,
  deserialize: _collectionModelDeserialize,
  deserializeProp: _collectionModelDeserializeProp,
  idName: r'isarId',
  indexes: {
    r'id': IndexSchema(
      id: -3268401673993471357,
      name: r'id',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'id',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    ),
    r'userId': IndexSchema(
      id: -2005826577402374815,
      name: r'userId',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'userId',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    ),
    r'isPinned': IndexSchema(
      id: 7607338673446676027,
      name: r'isPinned',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'isPinned',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    ),
    r'isArchived': IndexSchema(
      id: 655844772568347876,
      name: r'isArchived',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'isArchived',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    ),
    r'position': IndexSchema(
      id: 5117117876086213592,
      name: r'position',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'position',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    ),
    r'createdAt': IndexSchema(
      id: -3433535483987302584,
      name: r'createdAt',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'createdAt',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    ),
    r'updatedAt': IndexSchema(
      id: -6238191080293565125,
      name: r'updatedAt',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'updatedAt',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    ),
    r'lastAccessedAt': IndexSchema(
      id: 7637973981624628205,
      name: r'lastAccessedAt',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'lastAccessedAt',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _collectionModelGetId,
  getLinks: _collectionModelGetLinks,
  attach: _collectionModelAttach,
  version: '3.1.0+1',
);

int _collectionModelEstimateSize(
  CollectionModel object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.backgroundJson.length * 3;
  {
    final value = object.description;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.iconJson.length * 3;
  bytesCount += 3 + object.id.length * 3;
  bytesCount += 3 + object.layoutType.length * 3;
  bytesCount += 3 + object.name.length * 3;
  {
    final value = object.parentCollectionId;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.settingsJson.length * 3;
  bytesCount += 3 + object.sortOrder.length * 3;
  bytesCount += 3 + object.statusJson.length * 3;
  bytesCount += 3 + object.userId.length * 3;
  bytesCount += 3 + object.visibility.length * 3;
  return bytesCount;
}

void _collectionModelSerialize(
  CollectionModel object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.backgroundJson);
  writer.writeDateTime(offsets[1], object.createdAt);
  writer.writeString(offsets[2], object.description);
  writer.writeString(offsets[3], object.iconJson);
  writer.writeString(offsets[4], object.id);
  writer.writeBool(offsets[5], object.isArchived);
  writer.writeBool(offsets[6], object.isPinned);
  writer.writeDateTime(offsets[7], object.lastAccessedAt);
  writer.writeString(offsets[8], object.layoutType);
  writer.writeString(offsets[9], object.name);
  writer.writeString(offsets[10], object.parentCollectionId);
  writer.writeLong(offsets[11], object.position);
  writer.writeString(offsets[12], object.settingsJson);
  writer.writeString(offsets[13], object.sortOrder);
  writer.writeString(offsets[14], object.statusJson);
  writer.writeLong(offsets[15], object.totalClicks);
  writer.writeDateTime(offsets[16], object.updatedAt);
  writer.writeLong(offsets[17], object.urlCount);
  writer.writeString(offsets[18], object.userId);
  writer.writeString(offsets[19], object.visibility);
}

CollectionModel _collectionModelDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = CollectionModel(
    backgroundJson: reader.readString(offsets[0]),
    createdAt: reader.readDateTime(offsets[1]),
    description: reader.readStringOrNull(offsets[2]),
    iconJson: reader.readString(offsets[3]),
    id: reader.readString(offsets[4]),
    isArchived: reader.readBool(offsets[5]),
    isPinned: reader.readBool(offsets[6]),
    isarId: id,
    lastAccessedAt: reader.readDateTimeOrNull(offsets[7]),
    layoutType: reader.readString(offsets[8]),
    name: reader.readString(offsets[9]),
    parentCollectionId: reader.readStringOrNull(offsets[10]),
    position: reader.readLong(offsets[11]),
    settingsJson: reader.readString(offsets[12]),
    sortOrder: reader.readString(offsets[13]),
    statusJson: reader.readString(offsets[14]),
    totalClicks: reader.readLong(offsets[15]),
    updatedAt: reader.readDateTime(offsets[16]),
    urlCount: reader.readLong(offsets[17]),
    userId: reader.readString(offsets[18]),
    visibility: reader.readString(offsets[19]),
  );
  return object;
}

P _collectionModelDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readString(offset)) as P;
    case 1:
      return (reader.readDateTime(offset)) as P;
    case 2:
      return (reader.readStringOrNull(offset)) as P;
    case 3:
      return (reader.readString(offset)) as P;
    case 4:
      return (reader.readString(offset)) as P;
    case 5:
      return (reader.readBool(offset)) as P;
    case 6:
      return (reader.readBool(offset)) as P;
    case 7:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 8:
      return (reader.readString(offset)) as P;
    case 9:
      return (reader.readString(offset)) as P;
    case 10:
      return (reader.readStringOrNull(offset)) as P;
    case 11:
      return (reader.readLong(offset)) as P;
    case 12:
      return (reader.readString(offset)) as P;
    case 13:
      return (reader.readString(offset)) as P;
    case 14:
      return (reader.readString(offset)) as P;
    case 15:
      return (reader.readLong(offset)) as P;
    case 16:
      return (reader.readDateTime(offset)) as P;
    case 17:
      return (reader.readLong(offset)) as P;
    case 18:
      return (reader.readString(offset)) as P;
    case 19:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _collectionModelGetId(CollectionModel object) {
  return object.isarId;
}

List<IsarLinkBase<dynamic>> _collectionModelGetLinks(CollectionModel object) {
  return [];
}

void _collectionModelAttach(
    IsarCollection<dynamic> col, Id id, CollectionModel object) {}

extension CollectionModelQueryWhereSort
    on QueryBuilder<CollectionModel, CollectionModel, QWhere> {
  QueryBuilder<CollectionModel, CollectionModel, QAfterWhere> anyIsarId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<CollectionModel, CollectionModel, QAfterWhere> anyIsPinned() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'isPinned'),
      );
    });
  }

  QueryBuilder<CollectionModel, CollectionModel, QAfterWhere> anyIsArchived() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'isArchived'),
      );
    });
  }

  QueryBuilder<CollectionModel, CollectionModel, QAfterWhere> anyPosition() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'position'),
      );
    });
  }

  QueryBuilder<CollectionModel, CollectionModel, QAfterWhere> anyCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'createdAt'),
      );
    });
  }

  QueryBuilder<CollectionModel, CollectionModel, QAfterWhere> anyUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'updatedAt'),
      );
    });
  }

  QueryBuilder<CollectionModel, CollectionModel, QAfterWhere>
      anyLastAccessedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'lastAccessedAt'),
      );
    });
  }
}

extension CollectionModelQueryWhere
    on QueryBuilder<CollectionModel, CollectionModel, QWhereClause> {
  QueryBuilder<CollectionModel, CollectionModel, QAfterWhereClause>
      isarIdEqualTo(Id isarId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: isarId,
        upper: isarId,
      ));
    });
  }

  QueryBuilder<CollectionModel, CollectionModel, QAfterWhereClause>
      isarIdNotEqualTo(Id isarId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: isarId, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: isarId, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: isarId, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: isarId, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<CollectionModel, CollectionModel, QAfterWhereClause>
      isarIdGreaterThan(Id isarId, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: isarId, includeLower: include),
      );
    });
  }

  QueryBuilder<CollectionModel, CollectionModel, QAfterWhereClause>
      isarIdLessThan(Id isarId, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: isarId, includeUpper: include),
      );
    });
  }

  QueryBuilder<CollectionModel, CollectionModel, QAfterWhereClause>
      isarIdBetween(
    Id lowerIsarId,
    Id upperIsarId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerIsarId,
        includeLower: includeLower,
        upper: upperIsarId,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<CollectionModel, CollectionModel, QAfterWhereClause> idEqualTo(
      String id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'id',
        value: [id],
      ));
    });
  }

  QueryBuilder<CollectionModel, CollectionModel, QAfterWhereClause>
      idNotEqualTo(String id) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'id',
              lower: [],
              upper: [id],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'id',
              lower: [id],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'id',
              lower: [id],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'id',
              lower: [],
              upper: [id],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<CollectionModel, CollectionModel, QAfterWhereClause>
      userIdEqualTo(String userId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'userId',
        value: [userId],
      ));
    });
  }

  QueryBuilder<CollectionModel, CollectionModel, QAfterWhereClause>
      userIdNotEqualTo(String userId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'userId',
              lower: [],
              upper: [userId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'userId',
              lower: [userId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'userId',
              lower: [userId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'userId',
              lower: [],
              upper: [userId],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<CollectionModel, CollectionModel, QAfterWhereClause>
      isPinnedEqualTo(bool isPinned) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'isPinned',
        value: [isPinned],
      ));
    });
  }

  QueryBuilder<CollectionModel, CollectionModel, QAfterWhereClause>
      isPinnedNotEqualTo(bool isPinned) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'isPinned',
              lower: [],
              upper: [isPinned],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'isPinned',
              lower: [isPinned],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'isPinned',
              lower: [isPinned],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'isPinned',
              lower: [],
              upper: [isPinned],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<CollectionModel, CollectionModel, QAfterWhereClause>
      isArchivedEqualTo(bool isArchived) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'isArchived',
        value: [isArchived],
      ));
    });
  }

  QueryBuilder<CollectionModel, CollectionModel, QAfterWhereClause>
      isArchivedNotEqualTo(bool isArchived) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'isArchived',
              lower: [],
              upper: [isArchived],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'isArchived',
              lower: [isArchived],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'isArchived',
              lower: [isArchived],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'isArchived',
              lower: [],
              upper: [isArchived],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<CollectionModel, CollectionModel, QAfterWhereClause>
      positionEqualTo(int position) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'position',
        value: [position],
      ));
    });
  }

  QueryBuilder<CollectionModel, CollectionModel, QAfterWhereClause>
      positionNotEqualTo(int position) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'position',
              lower: [],
              upper: [position],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'position',
              lower: [position],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'position',
              lower: [position],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'position',
              lower: [],
              upper: [position],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<CollectionModel, CollectionModel, QAfterWhereClause>
      positionGreaterThan(
    int position, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'position',
        lower: [position],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<CollectionModel, CollectionModel, QAfterWhereClause>
      positionLessThan(
    int position, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'position',
        lower: [],
        upper: [position],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<CollectionModel, CollectionModel, QAfterWhereClause>
      positionBetween(
    int lowerPosition,
    int upperPosition, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'position',
        lower: [lowerPosition],
        includeLower: includeLower,
        upper: [upperPosition],
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<CollectionModel, CollectionModel, QAfterWhereClause>
      createdAtEqualTo(DateTime createdAt) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'createdAt',
        value: [createdAt],
      ));
    });
  }

  QueryBuilder<CollectionModel, CollectionModel, QAfterWhereClause>
      createdAtNotEqualTo(DateTime createdAt) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'createdAt',
              lower: [],
              upper: [createdAt],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'createdAt',
              lower: [createdAt],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'createdAt',
              lower: [createdAt],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'createdAt',
              lower: [],
              upper: [createdAt],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<CollectionModel, CollectionModel, QAfterWhereClause>
      createdAtGreaterThan(
    DateTime createdAt, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'createdAt',
        lower: [createdAt],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<CollectionModel, CollectionModel, QAfterWhereClause>
      createdAtLessThan(
    DateTime createdAt, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'createdAt',
        lower: [],
        upper: [createdAt],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<CollectionModel, CollectionModel, QAfterWhereClause>
      createdAtBetween(
    DateTime lowerCreatedAt,
    DateTime upperCreatedAt, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'createdAt',
        lower: [lowerCreatedAt],
        includeLower: includeLower,
        upper: [upperCreatedAt],
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<CollectionModel, CollectionModel, QAfterWhereClause>
      updatedAtEqualTo(DateTime updatedAt) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'updatedAt',
        value: [updatedAt],
      ));
    });
  }

  QueryBuilder<CollectionModel, CollectionModel, QAfterWhereClause>
      updatedAtNotEqualTo(DateTime updatedAt) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'updatedAt',
              lower: [],
              upper: [updatedAt],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'updatedAt',
              lower: [updatedAt],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'updatedAt',
              lower: [updatedAt],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'updatedAt',
              lower: [],
              upper: [updatedAt],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<CollectionModel, CollectionModel, QAfterWhereClause>
      updatedAtGreaterThan(
    DateTime updatedAt, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'updatedAt',
        lower: [updatedAt],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<CollectionModel, CollectionModel, QAfterWhereClause>
      updatedAtLessThan(
    DateTime updatedAt, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'updatedAt',
        lower: [],
        upper: [updatedAt],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<CollectionModel, CollectionModel, QAfterWhereClause>
      updatedAtBetween(
    DateTime lowerUpdatedAt,
    DateTime upperUpdatedAt, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'updatedAt',
        lower: [lowerUpdatedAt],
        includeLower: includeLower,
        upper: [upperUpdatedAt],
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<CollectionModel, CollectionModel, QAfterWhereClause>
      lastAccessedAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'lastAccessedAt',
        value: [null],
      ));
    });
  }

  QueryBuilder<CollectionModel, CollectionModel, QAfterWhereClause>
      lastAccessedAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'lastAccessedAt',
        lower: [null],
        includeLower: false,
        upper: [],
      ));
    });
  }

  QueryBuilder<CollectionModel, CollectionModel, QAfterWhereClause>
      lastAccessedAtEqualTo(DateTime? lastAccessedAt) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'lastAccessedAt',
        value: [lastAccessedAt],
      ));
    });
  }

  QueryBuilder<CollectionModel, CollectionModel, QAfterWhereClause>
      lastAccessedAtNotEqualTo(DateTime? lastAccessedAt) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'lastAccessedAt',
              lower: [],
              upper: [lastAccessedAt],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'lastAccessedAt',
              lower: [lastAccessedAt],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'lastAccessedAt',
              lower: [lastAccessedAt],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'lastAccessedAt',
              lower: [],
              upper: [lastAccessedAt],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<CollectionModel, CollectionModel, QAfterWhereClause>
      lastAccessedAtGreaterThan(
    DateTime? lastAccessedAt, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'lastAccessedAt',
        lower: [lastAccessedAt],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<CollectionModel, CollectionModel, QAfterWhereClause>
      lastAccessedAtLessThan(
    DateTime? lastAccessedAt, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'lastAccessedAt',
        lower: [],
        upper: [lastAccessedAt],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<CollectionModel, CollectionModel, QAfterWhereClause>
      lastAccessedAtBetween(
    DateTime? lowerLastAccessedAt,
    DateTime? upperLastAccessedAt, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'lastAccessedAt',
        lower: [lowerLastAccessedAt],
        includeLower: includeLower,
        upper: [upperLastAccessedAt],
        includeUpper: includeUpper,
      ));
    });
  }
}

extension CollectionModelQueryFilter
    on QueryBuilder<CollectionModel, CollectionModel, QFilterCondition> {
  QueryBuilder<CollectionModel, CollectionModel, QAfterFilterCondition>
      backgroundJsonEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'backgroundJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CollectionModel, CollectionModel, QAfterFilterCondition>
      backgroundJsonGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'backgroundJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CollectionModel, CollectionModel, QAfterFilterCondition>
      backgroundJsonLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'backgroundJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CollectionModel, CollectionModel, QAfterFilterCondition>
      backgroundJsonBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'backgroundJson',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CollectionModel, CollectionModel, QAfterFilterCondition>
      backgroundJsonStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'backgroundJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CollectionModel, CollectionModel, QAfterFilterCondition>
      backgroundJsonEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'backgroundJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CollectionModel, CollectionModel, QAfterFilterCondition>
      backgroundJsonContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'backgroundJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CollectionModel, CollectionModel, QAfterFilterCondition>
      backgroundJsonMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'backgroundJson',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CollectionModel, CollectionModel, QAfterFilterCondition>
      backgroundJsonIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'backgroundJson',
        value: '',
      ));
    });
  }

  QueryBuilder<CollectionModel, CollectionModel, QAfterFilterCondition>
      backgroundJsonIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'backgroundJson',
        value: '',
      ));
    });
  }

  QueryBuilder<CollectionModel, CollectionModel, QAfterFilterCondition>
      createdAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<CollectionModel, CollectionModel, QAfterFilterCondition>
      createdAtGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<CollectionModel, CollectionModel, QAfterFilterCondition>
      createdAtLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<CollectionModel, CollectionModel, QAfterFilterCondition>
      createdAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'createdAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<CollectionModel, CollectionModel, QAfterFilterCondition>
      descriptionIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'description',
      ));
    });
  }

  QueryBuilder<CollectionModel, CollectionModel, QAfterFilterCondition>
      descriptionIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'description',
      ));
    });
  }

  QueryBuilder<CollectionModel, CollectionModel, QAfterFilterCondition>
      descriptionEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'description',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CollectionModel, CollectionModel, QAfterFilterCondition>
      descriptionGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'description',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CollectionModel, CollectionModel, QAfterFilterCondition>
      descriptionLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'description',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CollectionModel, CollectionModel, QAfterFilterCondition>
      descriptionBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'description',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CollectionModel, CollectionModel, QAfterFilterCondition>
      descriptionStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'description',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CollectionModel, CollectionModel, QAfterFilterCondition>
      descriptionEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'description',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CollectionModel, CollectionModel, QAfterFilterCondition>
      descriptionContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'description',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CollectionModel, CollectionModel, QAfterFilterCondition>
      descriptionMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'description',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CollectionModel, CollectionModel, QAfterFilterCondition>
      descriptionIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'description',
        value: '',
      ));
    });
  }

  QueryBuilder<CollectionModel, CollectionModel, QAfterFilterCondition>
      descriptionIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'description',
        value: '',
      ));
    });
  }

  QueryBuilder<CollectionModel, CollectionModel, QAfterFilterCondition>
      iconJsonEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'iconJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CollectionModel, CollectionModel, QAfterFilterCondition>
      iconJsonGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'iconJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CollectionModel, CollectionModel, QAfterFilterCondition>
      iconJsonLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'iconJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CollectionModel, CollectionModel, QAfterFilterCondition>
      iconJsonBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'iconJson',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CollectionModel, CollectionModel, QAfterFilterCondition>
      iconJsonStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'iconJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CollectionModel, CollectionModel, QAfterFilterCondition>
      iconJsonEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'iconJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CollectionModel, CollectionModel, QAfterFilterCondition>
      iconJsonContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'iconJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CollectionModel, CollectionModel, QAfterFilterCondition>
      iconJsonMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'iconJson',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CollectionModel, CollectionModel, QAfterFilterCondition>
      iconJsonIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'iconJson',
        value: '',
      ));
    });
  }

  QueryBuilder<CollectionModel, CollectionModel, QAfterFilterCondition>
      iconJsonIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'iconJson',
        value: '',
      ));
    });
  }

  QueryBuilder<CollectionModel, CollectionModel, QAfterFilterCondition>
      idEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CollectionModel, CollectionModel, QAfterFilterCondition>
      idGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'id',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CollectionModel, CollectionModel, QAfterFilterCondition>
      idLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'id',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CollectionModel, CollectionModel, QAfterFilterCondition>
      idBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'id',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CollectionModel, CollectionModel, QAfterFilterCondition>
      idStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'id',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CollectionModel, CollectionModel, QAfterFilterCondition>
      idEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'id',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CollectionModel, CollectionModel, QAfterFilterCondition>
      idContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'id',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CollectionModel, CollectionModel, QAfterFilterCondition>
      idMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'id',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CollectionModel, CollectionModel, QAfterFilterCondition>
      idIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: '',
      ));
    });
  }

  QueryBuilder<CollectionModel, CollectionModel, QAfterFilterCondition>
      idIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'id',
        value: '',
      ));
    });
  }

  QueryBuilder<CollectionModel, CollectionModel, QAfterFilterCondition>
      isArchivedEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isArchived',
        value: value,
      ));
    });
  }

  QueryBuilder<CollectionModel, CollectionModel, QAfterFilterCondition>
      isPinnedEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isPinned',
        value: value,
      ));
    });
  }

  QueryBuilder<CollectionModel, CollectionModel, QAfterFilterCondition>
      isarIdEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isarId',
        value: value,
      ));
    });
  }

  QueryBuilder<CollectionModel, CollectionModel, QAfterFilterCondition>
      isarIdGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'isarId',
        value: value,
      ));
    });
  }

  QueryBuilder<CollectionModel, CollectionModel, QAfterFilterCondition>
      isarIdLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'isarId',
        value: value,
      ));
    });
  }

  QueryBuilder<CollectionModel, CollectionModel, QAfterFilterCondition>
      isarIdBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'isarId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<CollectionModel, CollectionModel, QAfterFilterCondition>
      lastAccessedAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'lastAccessedAt',
      ));
    });
  }

  QueryBuilder<CollectionModel, CollectionModel, QAfterFilterCondition>
      lastAccessedAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'lastAccessedAt',
      ));
    });
  }

  QueryBuilder<CollectionModel, CollectionModel, QAfterFilterCondition>
      lastAccessedAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastAccessedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<CollectionModel, CollectionModel, QAfterFilterCondition>
      lastAccessedAtGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lastAccessedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<CollectionModel, CollectionModel, QAfterFilterCondition>
      lastAccessedAtLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lastAccessedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<CollectionModel, CollectionModel, QAfterFilterCondition>
      lastAccessedAtBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lastAccessedAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<CollectionModel, CollectionModel, QAfterFilterCondition>
      layoutTypeEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'layoutType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CollectionModel, CollectionModel, QAfterFilterCondition>
      layoutTypeGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'layoutType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CollectionModel, CollectionModel, QAfterFilterCondition>
      layoutTypeLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'layoutType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CollectionModel, CollectionModel, QAfterFilterCondition>
      layoutTypeBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'layoutType',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CollectionModel, CollectionModel, QAfterFilterCondition>
      layoutTypeStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'layoutType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CollectionModel, CollectionModel, QAfterFilterCondition>
      layoutTypeEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'layoutType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CollectionModel, CollectionModel, QAfterFilterCondition>
      layoutTypeContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'layoutType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CollectionModel, CollectionModel, QAfterFilterCondition>
      layoutTypeMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'layoutType',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CollectionModel, CollectionModel, QAfterFilterCondition>
      layoutTypeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'layoutType',
        value: '',
      ));
    });
  }

  QueryBuilder<CollectionModel, CollectionModel, QAfterFilterCondition>
      layoutTypeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'layoutType',
        value: '',
      ));
    });
  }

  QueryBuilder<CollectionModel, CollectionModel, QAfterFilterCondition>
      nameEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CollectionModel, CollectionModel, QAfterFilterCondition>
      nameGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CollectionModel, CollectionModel, QAfterFilterCondition>
      nameLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CollectionModel, CollectionModel, QAfterFilterCondition>
      nameBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'name',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CollectionModel, CollectionModel, QAfterFilterCondition>
      nameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CollectionModel, CollectionModel, QAfterFilterCondition>
      nameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CollectionModel, CollectionModel, QAfterFilterCondition>
      nameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CollectionModel, CollectionModel, QAfterFilterCondition>
      nameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'name',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CollectionModel, CollectionModel, QAfterFilterCondition>
      nameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'name',
        value: '',
      ));
    });
  }

  QueryBuilder<CollectionModel, CollectionModel, QAfterFilterCondition>
      nameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'name',
        value: '',
      ));
    });
  }

  QueryBuilder<CollectionModel, CollectionModel, QAfterFilterCondition>
      parentCollectionIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'parentCollectionId',
      ));
    });
  }

  QueryBuilder<CollectionModel, CollectionModel, QAfterFilterCondition>
      parentCollectionIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'parentCollectionId',
      ));
    });
  }

  QueryBuilder<CollectionModel, CollectionModel, QAfterFilterCondition>
      parentCollectionIdEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'parentCollectionId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CollectionModel, CollectionModel, QAfterFilterCondition>
      parentCollectionIdGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'parentCollectionId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CollectionModel, CollectionModel, QAfterFilterCondition>
      parentCollectionIdLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'parentCollectionId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CollectionModel, CollectionModel, QAfterFilterCondition>
      parentCollectionIdBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'parentCollectionId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CollectionModel, CollectionModel, QAfterFilterCondition>
      parentCollectionIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'parentCollectionId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CollectionModel, CollectionModel, QAfterFilterCondition>
      parentCollectionIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'parentCollectionId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CollectionModel, CollectionModel, QAfterFilterCondition>
      parentCollectionIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'parentCollectionId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CollectionModel, CollectionModel, QAfterFilterCondition>
      parentCollectionIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'parentCollectionId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CollectionModel, CollectionModel, QAfterFilterCondition>
      parentCollectionIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'parentCollectionId',
        value: '',
      ));
    });
  }

  QueryBuilder<CollectionModel, CollectionModel, QAfterFilterCondition>
      parentCollectionIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'parentCollectionId',
        value: '',
      ));
    });
  }

  QueryBuilder<CollectionModel, CollectionModel, QAfterFilterCondition>
      positionEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'position',
        value: value,
      ));
    });
  }

  QueryBuilder<CollectionModel, CollectionModel, QAfterFilterCondition>
      positionGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'position',
        value: value,
      ));
    });
  }

  QueryBuilder<CollectionModel, CollectionModel, QAfterFilterCondition>
      positionLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'position',
        value: value,
      ));
    });
  }

  QueryBuilder<CollectionModel, CollectionModel, QAfterFilterCondition>
      positionBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'position',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<CollectionModel, CollectionModel, QAfterFilterCondition>
      settingsJsonEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'settingsJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CollectionModel, CollectionModel, QAfterFilterCondition>
      settingsJsonGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'settingsJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CollectionModel, CollectionModel, QAfterFilterCondition>
      settingsJsonLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'settingsJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CollectionModel, CollectionModel, QAfterFilterCondition>
      settingsJsonBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'settingsJson',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CollectionModel, CollectionModel, QAfterFilterCondition>
      settingsJsonStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'settingsJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CollectionModel, CollectionModel, QAfterFilterCondition>
      settingsJsonEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'settingsJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CollectionModel, CollectionModel, QAfterFilterCondition>
      settingsJsonContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'settingsJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CollectionModel, CollectionModel, QAfterFilterCondition>
      settingsJsonMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'settingsJson',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CollectionModel, CollectionModel, QAfterFilterCondition>
      settingsJsonIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'settingsJson',
        value: '',
      ));
    });
  }

  QueryBuilder<CollectionModel, CollectionModel, QAfterFilterCondition>
      settingsJsonIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'settingsJson',
        value: '',
      ));
    });
  }

  QueryBuilder<CollectionModel, CollectionModel, QAfterFilterCondition>
      sortOrderEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'sortOrder',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CollectionModel, CollectionModel, QAfterFilterCondition>
      sortOrderGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'sortOrder',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CollectionModel, CollectionModel, QAfterFilterCondition>
      sortOrderLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'sortOrder',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CollectionModel, CollectionModel, QAfterFilterCondition>
      sortOrderBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'sortOrder',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CollectionModel, CollectionModel, QAfterFilterCondition>
      sortOrderStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'sortOrder',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CollectionModel, CollectionModel, QAfterFilterCondition>
      sortOrderEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'sortOrder',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CollectionModel, CollectionModel, QAfterFilterCondition>
      sortOrderContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'sortOrder',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CollectionModel, CollectionModel, QAfterFilterCondition>
      sortOrderMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'sortOrder',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CollectionModel, CollectionModel, QAfterFilterCondition>
      sortOrderIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'sortOrder',
        value: '',
      ));
    });
  }

  QueryBuilder<CollectionModel, CollectionModel, QAfterFilterCondition>
      sortOrderIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'sortOrder',
        value: '',
      ));
    });
  }

  QueryBuilder<CollectionModel, CollectionModel, QAfterFilterCondition>
      statusJsonEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'statusJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CollectionModel, CollectionModel, QAfterFilterCondition>
      statusJsonGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'statusJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CollectionModel, CollectionModel, QAfterFilterCondition>
      statusJsonLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'statusJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CollectionModel, CollectionModel, QAfterFilterCondition>
      statusJsonBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'statusJson',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CollectionModel, CollectionModel, QAfterFilterCondition>
      statusJsonStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'statusJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CollectionModel, CollectionModel, QAfterFilterCondition>
      statusJsonEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'statusJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CollectionModel, CollectionModel, QAfterFilterCondition>
      statusJsonContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'statusJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CollectionModel, CollectionModel, QAfterFilterCondition>
      statusJsonMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'statusJson',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CollectionModel, CollectionModel, QAfterFilterCondition>
      statusJsonIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'statusJson',
        value: '',
      ));
    });
  }

  QueryBuilder<CollectionModel, CollectionModel, QAfterFilterCondition>
      statusJsonIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'statusJson',
        value: '',
      ));
    });
  }

  QueryBuilder<CollectionModel, CollectionModel, QAfterFilterCondition>
      totalClicksEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'totalClicks',
        value: value,
      ));
    });
  }

  QueryBuilder<CollectionModel, CollectionModel, QAfterFilterCondition>
      totalClicksGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'totalClicks',
        value: value,
      ));
    });
  }

  QueryBuilder<CollectionModel, CollectionModel, QAfterFilterCondition>
      totalClicksLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'totalClicks',
        value: value,
      ));
    });
  }

  QueryBuilder<CollectionModel, CollectionModel, QAfterFilterCondition>
      totalClicksBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'totalClicks',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<CollectionModel, CollectionModel, QAfterFilterCondition>
      updatedAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'updatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<CollectionModel, CollectionModel, QAfterFilterCondition>
      updatedAtGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'updatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<CollectionModel, CollectionModel, QAfterFilterCondition>
      updatedAtLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'updatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<CollectionModel, CollectionModel, QAfterFilterCondition>
      updatedAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'updatedAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<CollectionModel, CollectionModel, QAfterFilterCondition>
      urlCountEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'urlCount',
        value: value,
      ));
    });
  }

  QueryBuilder<CollectionModel, CollectionModel, QAfterFilterCondition>
      urlCountGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'urlCount',
        value: value,
      ));
    });
  }

  QueryBuilder<CollectionModel, CollectionModel, QAfterFilterCondition>
      urlCountLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'urlCount',
        value: value,
      ));
    });
  }

  QueryBuilder<CollectionModel, CollectionModel, QAfterFilterCondition>
      urlCountBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'urlCount',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<CollectionModel, CollectionModel, QAfterFilterCondition>
      userIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'userId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CollectionModel, CollectionModel, QAfterFilterCondition>
      userIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'userId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CollectionModel, CollectionModel, QAfterFilterCondition>
      userIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'userId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CollectionModel, CollectionModel, QAfterFilterCondition>
      userIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'userId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CollectionModel, CollectionModel, QAfterFilterCondition>
      userIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'userId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CollectionModel, CollectionModel, QAfterFilterCondition>
      userIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'userId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CollectionModel, CollectionModel, QAfterFilterCondition>
      userIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'userId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CollectionModel, CollectionModel, QAfterFilterCondition>
      userIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'userId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CollectionModel, CollectionModel, QAfterFilterCondition>
      userIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'userId',
        value: '',
      ));
    });
  }

  QueryBuilder<CollectionModel, CollectionModel, QAfterFilterCondition>
      userIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'userId',
        value: '',
      ));
    });
  }

  QueryBuilder<CollectionModel, CollectionModel, QAfterFilterCondition>
      visibilityEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'visibility',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CollectionModel, CollectionModel, QAfterFilterCondition>
      visibilityGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'visibility',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CollectionModel, CollectionModel, QAfterFilterCondition>
      visibilityLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'visibility',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CollectionModel, CollectionModel, QAfterFilterCondition>
      visibilityBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'visibility',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CollectionModel, CollectionModel, QAfterFilterCondition>
      visibilityStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'visibility',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CollectionModel, CollectionModel, QAfterFilterCondition>
      visibilityEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'visibility',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CollectionModel, CollectionModel, QAfterFilterCondition>
      visibilityContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'visibility',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CollectionModel, CollectionModel, QAfterFilterCondition>
      visibilityMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'visibility',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CollectionModel, CollectionModel, QAfterFilterCondition>
      visibilityIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'visibility',
        value: '',
      ));
    });
  }

  QueryBuilder<CollectionModel, CollectionModel, QAfterFilterCondition>
      visibilityIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'visibility',
        value: '',
      ));
    });
  }
}

extension CollectionModelQueryObject
    on QueryBuilder<CollectionModel, CollectionModel, QFilterCondition> {}

extension CollectionModelQueryLinks
    on QueryBuilder<CollectionModel, CollectionModel, QFilterCondition> {}

extension CollectionModelQuerySortBy
    on QueryBuilder<CollectionModel, CollectionModel, QSortBy> {
  QueryBuilder<CollectionModel, CollectionModel, QAfterSortBy>
      sortByBackgroundJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'backgroundJson', Sort.asc);
    });
  }

  QueryBuilder<CollectionModel, CollectionModel, QAfterSortBy>
      sortByBackgroundJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'backgroundJson', Sort.desc);
    });
  }

  QueryBuilder<CollectionModel, CollectionModel, QAfterSortBy>
      sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<CollectionModel, CollectionModel, QAfterSortBy>
      sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<CollectionModel, CollectionModel, QAfterSortBy>
      sortByDescription() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'description', Sort.asc);
    });
  }

  QueryBuilder<CollectionModel, CollectionModel, QAfterSortBy>
      sortByDescriptionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'description', Sort.desc);
    });
  }

  QueryBuilder<CollectionModel, CollectionModel, QAfterSortBy>
      sortByIconJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'iconJson', Sort.asc);
    });
  }

  QueryBuilder<CollectionModel, CollectionModel, QAfterSortBy>
      sortByIconJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'iconJson', Sort.desc);
    });
  }

  QueryBuilder<CollectionModel, CollectionModel, QAfterSortBy> sortById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<CollectionModel, CollectionModel, QAfterSortBy> sortByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<CollectionModel, CollectionModel, QAfterSortBy>
      sortByIsArchived() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isArchived', Sort.asc);
    });
  }

  QueryBuilder<CollectionModel, CollectionModel, QAfterSortBy>
      sortByIsArchivedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isArchived', Sort.desc);
    });
  }

  QueryBuilder<CollectionModel, CollectionModel, QAfterSortBy>
      sortByIsPinned() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isPinned', Sort.asc);
    });
  }

  QueryBuilder<CollectionModel, CollectionModel, QAfterSortBy>
      sortByIsPinnedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isPinned', Sort.desc);
    });
  }

  QueryBuilder<CollectionModel, CollectionModel, QAfterSortBy>
      sortByLastAccessedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastAccessedAt', Sort.asc);
    });
  }

  QueryBuilder<CollectionModel, CollectionModel, QAfterSortBy>
      sortByLastAccessedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastAccessedAt', Sort.desc);
    });
  }

  QueryBuilder<CollectionModel, CollectionModel, QAfterSortBy>
      sortByLayoutType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'layoutType', Sort.asc);
    });
  }

  QueryBuilder<CollectionModel, CollectionModel, QAfterSortBy>
      sortByLayoutTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'layoutType', Sort.desc);
    });
  }

  QueryBuilder<CollectionModel, CollectionModel, QAfterSortBy> sortByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.asc);
    });
  }

  QueryBuilder<CollectionModel, CollectionModel, QAfterSortBy>
      sortByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.desc);
    });
  }

  QueryBuilder<CollectionModel, CollectionModel, QAfterSortBy>
      sortByParentCollectionId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'parentCollectionId', Sort.asc);
    });
  }

  QueryBuilder<CollectionModel, CollectionModel, QAfterSortBy>
      sortByParentCollectionIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'parentCollectionId', Sort.desc);
    });
  }

  QueryBuilder<CollectionModel, CollectionModel, QAfterSortBy>
      sortByPosition() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'position', Sort.asc);
    });
  }

  QueryBuilder<CollectionModel, CollectionModel, QAfterSortBy>
      sortByPositionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'position', Sort.desc);
    });
  }

  QueryBuilder<CollectionModel, CollectionModel, QAfterSortBy>
      sortBySettingsJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'settingsJson', Sort.asc);
    });
  }

  QueryBuilder<CollectionModel, CollectionModel, QAfterSortBy>
      sortBySettingsJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'settingsJson', Sort.desc);
    });
  }

  QueryBuilder<CollectionModel, CollectionModel, QAfterSortBy>
      sortBySortOrder() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sortOrder', Sort.asc);
    });
  }

  QueryBuilder<CollectionModel, CollectionModel, QAfterSortBy>
      sortBySortOrderDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sortOrder', Sort.desc);
    });
  }

  QueryBuilder<CollectionModel, CollectionModel, QAfterSortBy>
      sortByStatusJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'statusJson', Sort.asc);
    });
  }

  QueryBuilder<CollectionModel, CollectionModel, QAfterSortBy>
      sortByStatusJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'statusJson', Sort.desc);
    });
  }

  QueryBuilder<CollectionModel, CollectionModel, QAfterSortBy>
      sortByTotalClicks() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalClicks', Sort.asc);
    });
  }

  QueryBuilder<CollectionModel, CollectionModel, QAfterSortBy>
      sortByTotalClicksDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalClicks', Sort.desc);
    });
  }

  QueryBuilder<CollectionModel, CollectionModel, QAfterSortBy>
      sortByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<CollectionModel, CollectionModel, QAfterSortBy>
      sortByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }

  QueryBuilder<CollectionModel, CollectionModel, QAfterSortBy>
      sortByUrlCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'urlCount', Sort.asc);
    });
  }

  QueryBuilder<CollectionModel, CollectionModel, QAfterSortBy>
      sortByUrlCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'urlCount', Sort.desc);
    });
  }

  QueryBuilder<CollectionModel, CollectionModel, QAfterSortBy> sortByUserId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userId', Sort.asc);
    });
  }

  QueryBuilder<CollectionModel, CollectionModel, QAfterSortBy>
      sortByUserIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userId', Sort.desc);
    });
  }

  QueryBuilder<CollectionModel, CollectionModel, QAfterSortBy>
      sortByVisibility() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'visibility', Sort.asc);
    });
  }

  QueryBuilder<CollectionModel, CollectionModel, QAfterSortBy>
      sortByVisibilityDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'visibility', Sort.desc);
    });
  }
}

extension CollectionModelQuerySortThenBy
    on QueryBuilder<CollectionModel, CollectionModel, QSortThenBy> {
  QueryBuilder<CollectionModel, CollectionModel, QAfterSortBy>
      thenByBackgroundJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'backgroundJson', Sort.asc);
    });
  }

  QueryBuilder<CollectionModel, CollectionModel, QAfterSortBy>
      thenByBackgroundJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'backgroundJson', Sort.desc);
    });
  }

  QueryBuilder<CollectionModel, CollectionModel, QAfterSortBy>
      thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<CollectionModel, CollectionModel, QAfterSortBy>
      thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<CollectionModel, CollectionModel, QAfterSortBy>
      thenByDescription() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'description', Sort.asc);
    });
  }

  QueryBuilder<CollectionModel, CollectionModel, QAfterSortBy>
      thenByDescriptionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'description', Sort.desc);
    });
  }

  QueryBuilder<CollectionModel, CollectionModel, QAfterSortBy>
      thenByIconJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'iconJson', Sort.asc);
    });
  }

  QueryBuilder<CollectionModel, CollectionModel, QAfterSortBy>
      thenByIconJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'iconJson', Sort.desc);
    });
  }

  QueryBuilder<CollectionModel, CollectionModel, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<CollectionModel, CollectionModel, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<CollectionModel, CollectionModel, QAfterSortBy>
      thenByIsArchived() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isArchived', Sort.asc);
    });
  }

  QueryBuilder<CollectionModel, CollectionModel, QAfterSortBy>
      thenByIsArchivedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isArchived', Sort.desc);
    });
  }

  QueryBuilder<CollectionModel, CollectionModel, QAfterSortBy>
      thenByIsPinned() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isPinned', Sort.asc);
    });
  }

  QueryBuilder<CollectionModel, CollectionModel, QAfterSortBy>
      thenByIsPinnedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isPinned', Sort.desc);
    });
  }

  QueryBuilder<CollectionModel, CollectionModel, QAfterSortBy> thenByIsarId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isarId', Sort.asc);
    });
  }

  QueryBuilder<CollectionModel, CollectionModel, QAfterSortBy>
      thenByIsarIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isarId', Sort.desc);
    });
  }

  QueryBuilder<CollectionModel, CollectionModel, QAfterSortBy>
      thenByLastAccessedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastAccessedAt', Sort.asc);
    });
  }

  QueryBuilder<CollectionModel, CollectionModel, QAfterSortBy>
      thenByLastAccessedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastAccessedAt', Sort.desc);
    });
  }

  QueryBuilder<CollectionModel, CollectionModel, QAfterSortBy>
      thenByLayoutType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'layoutType', Sort.asc);
    });
  }

  QueryBuilder<CollectionModel, CollectionModel, QAfterSortBy>
      thenByLayoutTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'layoutType', Sort.desc);
    });
  }

  QueryBuilder<CollectionModel, CollectionModel, QAfterSortBy> thenByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.asc);
    });
  }

  QueryBuilder<CollectionModel, CollectionModel, QAfterSortBy>
      thenByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.desc);
    });
  }

  QueryBuilder<CollectionModel, CollectionModel, QAfterSortBy>
      thenByParentCollectionId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'parentCollectionId', Sort.asc);
    });
  }

  QueryBuilder<CollectionModel, CollectionModel, QAfterSortBy>
      thenByParentCollectionIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'parentCollectionId', Sort.desc);
    });
  }

  QueryBuilder<CollectionModel, CollectionModel, QAfterSortBy>
      thenByPosition() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'position', Sort.asc);
    });
  }

  QueryBuilder<CollectionModel, CollectionModel, QAfterSortBy>
      thenByPositionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'position', Sort.desc);
    });
  }

  QueryBuilder<CollectionModel, CollectionModel, QAfterSortBy>
      thenBySettingsJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'settingsJson', Sort.asc);
    });
  }

  QueryBuilder<CollectionModel, CollectionModel, QAfterSortBy>
      thenBySettingsJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'settingsJson', Sort.desc);
    });
  }

  QueryBuilder<CollectionModel, CollectionModel, QAfterSortBy>
      thenBySortOrder() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sortOrder', Sort.asc);
    });
  }

  QueryBuilder<CollectionModel, CollectionModel, QAfterSortBy>
      thenBySortOrderDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sortOrder', Sort.desc);
    });
  }

  QueryBuilder<CollectionModel, CollectionModel, QAfterSortBy>
      thenByStatusJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'statusJson', Sort.asc);
    });
  }

  QueryBuilder<CollectionModel, CollectionModel, QAfterSortBy>
      thenByStatusJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'statusJson', Sort.desc);
    });
  }

  QueryBuilder<CollectionModel, CollectionModel, QAfterSortBy>
      thenByTotalClicks() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalClicks', Sort.asc);
    });
  }

  QueryBuilder<CollectionModel, CollectionModel, QAfterSortBy>
      thenByTotalClicksDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalClicks', Sort.desc);
    });
  }

  QueryBuilder<CollectionModel, CollectionModel, QAfterSortBy>
      thenByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<CollectionModel, CollectionModel, QAfterSortBy>
      thenByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }

  QueryBuilder<CollectionModel, CollectionModel, QAfterSortBy>
      thenByUrlCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'urlCount', Sort.asc);
    });
  }

  QueryBuilder<CollectionModel, CollectionModel, QAfterSortBy>
      thenByUrlCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'urlCount', Sort.desc);
    });
  }

  QueryBuilder<CollectionModel, CollectionModel, QAfterSortBy> thenByUserId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userId', Sort.asc);
    });
  }

  QueryBuilder<CollectionModel, CollectionModel, QAfterSortBy>
      thenByUserIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userId', Sort.desc);
    });
  }

  QueryBuilder<CollectionModel, CollectionModel, QAfterSortBy>
      thenByVisibility() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'visibility', Sort.asc);
    });
  }

  QueryBuilder<CollectionModel, CollectionModel, QAfterSortBy>
      thenByVisibilityDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'visibility', Sort.desc);
    });
  }
}

extension CollectionModelQueryWhereDistinct
    on QueryBuilder<CollectionModel, CollectionModel, QDistinct> {
  QueryBuilder<CollectionModel, CollectionModel, QDistinct>
      distinctByBackgroundJson({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'backgroundJson',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<CollectionModel, CollectionModel, QDistinct>
      distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdAt');
    });
  }

  QueryBuilder<CollectionModel, CollectionModel, QDistinct>
      distinctByDescription({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'description', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<CollectionModel, CollectionModel, QDistinct> distinctByIconJson(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'iconJson', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<CollectionModel, CollectionModel, QDistinct> distinctById(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'id', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<CollectionModel, CollectionModel, QDistinct>
      distinctByIsArchived() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isArchived');
    });
  }

  QueryBuilder<CollectionModel, CollectionModel, QDistinct>
      distinctByIsPinned() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isPinned');
    });
  }

  QueryBuilder<CollectionModel, CollectionModel, QDistinct>
      distinctByLastAccessedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastAccessedAt');
    });
  }

  QueryBuilder<CollectionModel, CollectionModel, QDistinct>
      distinctByLayoutType({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'layoutType', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<CollectionModel, CollectionModel, QDistinct> distinctByName(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'name', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<CollectionModel, CollectionModel, QDistinct>
      distinctByParentCollectionId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'parentCollectionId',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<CollectionModel, CollectionModel, QDistinct>
      distinctByPosition() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'position');
    });
  }

  QueryBuilder<CollectionModel, CollectionModel, QDistinct>
      distinctBySettingsJson({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'settingsJson', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<CollectionModel, CollectionModel, QDistinct> distinctBySortOrder(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'sortOrder', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<CollectionModel, CollectionModel, QDistinct>
      distinctByStatusJson({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'statusJson', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<CollectionModel, CollectionModel, QDistinct>
      distinctByTotalClicks() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'totalClicks');
    });
  }

  QueryBuilder<CollectionModel, CollectionModel, QDistinct>
      distinctByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'updatedAt');
    });
  }

  QueryBuilder<CollectionModel, CollectionModel, QDistinct>
      distinctByUrlCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'urlCount');
    });
  }

  QueryBuilder<CollectionModel, CollectionModel, QDistinct> distinctByUserId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'userId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<CollectionModel, CollectionModel, QDistinct>
      distinctByVisibility({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'visibility', caseSensitive: caseSensitive);
    });
  }
}

extension CollectionModelQueryProperty
    on QueryBuilder<CollectionModel, CollectionModel, QQueryProperty> {
  QueryBuilder<CollectionModel, int, QQueryOperations> isarIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isarId');
    });
  }

  QueryBuilder<CollectionModel, String, QQueryOperations>
      backgroundJsonProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'backgroundJson');
    });
  }

  QueryBuilder<CollectionModel, DateTime, QQueryOperations>
      createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdAt');
    });
  }

  QueryBuilder<CollectionModel, String?, QQueryOperations>
      descriptionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'description');
    });
  }

  QueryBuilder<CollectionModel, String, QQueryOperations> iconJsonProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'iconJson');
    });
  }

  QueryBuilder<CollectionModel, String, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<CollectionModel, bool, QQueryOperations> isArchivedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isArchived');
    });
  }

  QueryBuilder<CollectionModel, bool, QQueryOperations> isPinnedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isPinned');
    });
  }

  QueryBuilder<CollectionModel, DateTime?, QQueryOperations>
      lastAccessedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastAccessedAt');
    });
  }

  QueryBuilder<CollectionModel, String, QQueryOperations> layoutTypeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'layoutType');
    });
  }

  QueryBuilder<CollectionModel, String, QQueryOperations> nameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'name');
    });
  }

  QueryBuilder<CollectionModel, String?, QQueryOperations>
      parentCollectionIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'parentCollectionId');
    });
  }

  QueryBuilder<CollectionModel, int, QQueryOperations> positionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'position');
    });
  }

  QueryBuilder<CollectionModel, String, QQueryOperations>
      settingsJsonProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'settingsJson');
    });
  }

  QueryBuilder<CollectionModel, String, QQueryOperations> sortOrderProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'sortOrder');
    });
  }

  QueryBuilder<CollectionModel, String, QQueryOperations> statusJsonProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'statusJson');
    });
  }

  QueryBuilder<CollectionModel, int, QQueryOperations> totalClicksProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'totalClicks');
    });
  }

  QueryBuilder<CollectionModel, DateTime, QQueryOperations>
      updatedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'updatedAt');
    });
  }

  QueryBuilder<CollectionModel, int, QQueryOperations> urlCountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'urlCount');
    });
  }

  QueryBuilder<CollectionModel, String, QQueryOperations> userIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'userId');
    });
  }

  QueryBuilder<CollectionModel, String, QQueryOperations> visibilityProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'visibility');
    });
  }
}
