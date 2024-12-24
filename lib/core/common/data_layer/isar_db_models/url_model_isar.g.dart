// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'url_model_isar.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetUrlModelIsarCollection on Isar {
  IsarCollection<UrlModelIsar> get urlModelIsars => this.collection();
}

const UrlModelIsarSchema = CollectionSchema(
  name: r'UrlModelIsar',
  id: 186705669101918689,
  properties: {
    r'collectionId': PropertySchema(
      id: 0,
      name: r'collectionId',
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
    r'firestoreId': PropertySchema(
      id: 3,
      name: r'firestoreId',
      type: IsarType.string,
    ),
    r'htmlContent': PropertySchema(
      id: 4,
      name: r'htmlContent',
      type: IsarType.string,
    ),
    r'isFavourite': PropertySchema(
      id: 5,
      name: r'isFavourite',
      type: IsarType.bool,
    ),
    r'isOffline': PropertySchema(
      id: 6,
      name: r'isOffline',
      type: IsarType.bool,
    ),
    r'metaData': PropertySchema(
      id: 7,
      name: r'metaData',
      type: IsarType.string,
    ),
    r'parentUrlModelFirestoreId': PropertySchema(
      id: 8,
      name: r'parentUrlModelFirestoreId',
      type: IsarType.string,
    ),
    r'settings': PropertySchema(
      id: 9,
      name: r'settings',
      type: IsarType.string,
    ),
    r'tag': PropertySchema(
      id: 10,
      name: r'tag',
      type: IsarType.string,
    ),
    r'title': PropertySchema(
      id: 11,
      name: r'title',
      type: IsarType.string,
    ),
    r'updatedAt': PropertySchema(
      id: 12,
      name: r'updatedAt',
      type: IsarType.dateTime,
    ),
    r'url': PropertySchema(
      id: 13,
      name: r'url',
      type: IsarType.string,
    )
  },
  estimateSize: _urlModelIsarEstimateSize,
  serialize: _urlModelIsarSerialize,
  deserialize: _urlModelIsarDeserialize,
  deserializeProp: _urlModelIsarDeserializeProp,
  idName: r'id',
  indexes: {
    r'firestoreId': IndexSchema(
      id: 1863077355534729001,
      name: r'firestoreId',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'firestoreId',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    ),
    r'collectionId': IndexSchema(
      id: -7489395134515229581,
      name: r'collectionId',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'collectionId',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    ),
    r'url': IndexSchema(
      id: -5756857009679432345,
      name: r'url',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'url',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    ),
    r'title': IndexSchema(
      id: -7636685945352118059,
      name: r'title',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'title',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    ),
    r'tag': IndexSchema(
      id: -8827799455852696894,
      name: r'tag',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'tag',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    ),
    r'isOffline': IndexSchema(
      id: -7546462379723217932,
      name: r'isOffline',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'isOffline',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    ),
    r'isFavourite': IndexSchema(
      id: -3295437635301440716,
      name: r'isFavourite',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'isFavourite',
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
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _urlModelIsarGetId,
  getLinks: _urlModelIsarGetLinks,
  attach: _urlModelIsarAttach,
  version: '3.1.0+1',
);

int _urlModelIsarEstimateSize(
  UrlModelIsar object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.collectionId.length * 3;
  {
    final value = object.description;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.firestoreId.length * 3;
  {
    final value = object.htmlContent;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.metaData;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.parentUrlModelFirestoreId;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.settings;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.tag.length * 3;
  bytesCount += 3 + object.title.length * 3;
  bytesCount += 3 + object.url.length * 3;
  return bytesCount;
}

void _urlModelIsarSerialize(
  UrlModelIsar object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.collectionId);
  writer.writeDateTime(offsets[1], object.createdAt);
  writer.writeString(offsets[2], object.description);
  writer.writeString(offsets[3], object.firestoreId);
  writer.writeString(offsets[4], object.htmlContent);
  writer.writeBool(offsets[5], object.isFavourite);
  writer.writeBool(offsets[6], object.isOffline);
  writer.writeString(offsets[7], object.metaData);
  writer.writeString(offsets[8], object.parentUrlModelFirestoreId);
  writer.writeString(offsets[9], object.settings);
  writer.writeString(offsets[10], object.tag);
  writer.writeString(offsets[11], object.title);
  writer.writeDateTime(offsets[12], object.updatedAt);
  writer.writeString(offsets[13], object.url);
}

UrlModelIsar _urlModelIsarDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = UrlModelIsar(
    collectionId: reader.readString(offsets[0]),
    createdAt: reader.readDateTime(offsets[1]),
    description: reader.readStringOrNull(offsets[2]),
    firestoreId: reader.readString(offsets[3]),
    htmlContent: reader.readStringOrNull(offsets[4]),
    id: id,
    isFavourite: reader.readBool(offsets[5]),
    isOffline: reader.readBool(offsets[6]),
    metaData: reader.readStringOrNull(offsets[7]),
    parentUrlModelFirestoreId: reader.readStringOrNull(offsets[8]),
    settings: reader.readStringOrNull(offsets[9]),
    tag: reader.readString(offsets[10]),
    title: reader.readString(offsets[11]),
    updatedAt: reader.readDateTime(offsets[12]),
    url: reader.readString(offsets[13]),
  );
  return object;
}

P _urlModelIsarDeserializeProp<P>(
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
      return (reader.readStringOrNull(offset)) as P;
    case 5:
      return (reader.readBool(offset)) as P;
    case 6:
      return (reader.readBool(offset)) as P;
    case 7:
      return (reader.readStringOrNull(offset)) as P;
    case 8:
      return (reader.readStringOrNull(offset)) as P;
    case 9:
      return (reader.readStringOrNull(offset)) as P;
    case 10:
      return (reader.readString(offset)) as P;
    case 11:
      return (reader.readString(offset)) as P;
    case 12:
      return (reader.readDateTime(offset)) as P;
    case 13:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _urlModelIsarGetId(UrlModelIsar object) {
  return object.id ?? Isar.autoIncrement;
}

List<IsarLinkBase<dynamic>> _urlModelIsarGetLinks(UrlModelIsar object) {
  return [];
}

void _urlModelIsarAttach(
    IsarCollection<dynamic> col, Id id, UrlModelIsar object) {}

extension UrlModelIsarQueryWhereSort
    on QueryBuilder<UrlModelIsar, UrlModelIsar, QWhere> {
  QueryBuilder<UrlModelIsar, UrlModelIsar, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<UrlModelIsar, UrlModelIsar, QAfterWhere> anyIsOffline() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'isOffline'),
      );
    });
  }

  QueryBuilder<UrlModelIsar, UrlModelIsar, QAfterWhere> anyIsFavourite() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'isFavourite'),
      );
    });
  }

  QueryBuilder<UrlModelIsar, UrlModelIsar, QAfterWhere> anyCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'createdAt'),
      );
    });
  }

  QueryBuilder<UrlModelIsar, UrlModelIsar, QAfterWhere> anyUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'updatedAt'),
      );
    });
  }
}

extension UrlModelIsarQueryWhere
    on QueryBuilder<UrlModelIsar, UrlModelIsar, QWhereClause> {
  QueryBuilder<UrlModelIsar, UrlModelIsar, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<UrlModelIsar, UrlModelIsar, QAfterWhereClause> idNotEqualTo(
      Id id) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<UrlModelIsar, UrlModelIsar, QAfterWhereClause> idGreaterThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<UrlModelIsar, UrlModelIsar, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<UrlModelIsar, UrlModelIsar, QAfterWhereClause> idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerId,
        includeLower: includeLower,
        upper: upperId,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<UrlModelIsar, UrlModelIsar, QAfterWhereClause>
      firestoreIdEqualTo(String firestoreId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'firestoreId',
        value: [firestoreId],
      ));
    });
  }

  QueryBuilder<UrlModelIsar, UrlModelIsar, QAfterWhereClause>
      firestoreIdNotEqualTo(String firestoreId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'firestoreId',
              lower: [],
              upper: [firestoreId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'firestoreId',
              lower: [firestoreId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'firestoreId',
              lower: [firestoreId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'firestoreId',
              lower: [],
              upper: [firestoreId],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<UrlModelIsar, UrlModelIsar, QAfterWhereClause>
      collectionIdEqualTo(String collectionId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'collectionId',
        value: [collectionId],
      ));
    });
  }

  QueryBuilder<UrlModelIsar, UrlModelIsar, QAfterWhereClause>
      collectionIdNotEqualTo(String collectionId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'collectionId',
              lower: [],
              upper: [collectionId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'collectionId',
              lower: [collectionId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'collectionId',
              lower: [collectionId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'collectionId',
              lower: [],
              upper: [collectionId],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<UrlModelIsar, UrlModelIsar, QAfterWhereClause> urlEqualTo(
      String url) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'url',
        value: [url],
      ));
    });
  }

  QueryBuilder<UrlModelIsar, UrlModelIsar, QAfterWhereClause> urlNotEqualTo(
      String url) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'url',
              lower: [],
              upper: [url],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'url',
              lower: [url],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'url',
              lower: [url],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'url',
              lower: [],
              upper: [url],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<UrlModelIsar, UrlModelIsar, QAfterWhereClause> titleEqualTo(
      String title) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'title',
        value: [title],
      ));
    });
  }

  QueryBuilder<UrlModelIsar, UrlModelIsar, QAfterWhereClause> titleNotEqualTo(
      String title) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'title',
              lower: [],
              upper: [title],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'title',
              lower: [title],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'title',
              lower: [title],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'title',
              lower: [],
              upper: [title],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<UrlModelIsar, UrlModelIsar, QAfterWhereClause> tagEqualTo(
      String tag) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'tag',
        value: [tag],
      ));
    });
  }

  QueryBuilder<UrlModelIsar, UrlModelIsar, QAfterWhereClause> tagNotEqualTo(
      String tag) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'tag',
              lower: [],
              upper: [tag],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'tag',
              lower: [tag],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'tag',
              lower: [tag],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'tag',
              lower: [],
              upper: [tag],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<UrlModelIsar, UrlModelIsar, QAfterWhereClause> isOfflineEqualTo(
      bool isOffline) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'isOffline',
        value: [isOffline],
      ));
    });
  }

  QueryBuilder<UrlModelIsar, UrlModelIsar, QAfterWhereClause>
      isOfflineNotEqualTo(bool isOffline) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'isOffline',
              lower: [],
              upper: [isOffline],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'isOffline',
              lower: [isOffline],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'isOffline',
              lower: [isOffline],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'isOffline',
              lower: [],
              upper: [isOffline],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<UrlModelIsar, UrlModelIsar, QAfterWhereClause>
      isFavouriteEqualTo(bool isFavourite) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'isFavourite',
        value: [isFavourite],
      ));
    });
  }

  QueryBuilder<UrlModelIsar, UrlModelIsar, QAfterWhereClause>
      isFavouriteNotEqualTo(bool isFavourite) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'isFavourite',
              lower: [],
              upper: [isFavourite],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'isFavourite',
              lower: [isFavourite],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'isFavourite',
              lower: [isFavourite],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'isFavourite',
              lower: [],
              upper: [isFavourite],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<UrlModelIsar, UrlModelIsar, QAfterWhereClause> createdAtEqualTo(
      DateTime createdAt) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'createdAt',
        value: [createdAt],
      ));
    });
  }

  QueryBuilder<UrlModelIsar, UrlModelIsar, QAfterWhereClause>
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

  QueryBuilder<UrlModelIsar, UrlModelIsar, QAfterWhereClause>
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

  QueryBuilder<UrlModelIsar, UrlModelIsar, QAfterWhereClause> createdAtLessThan(
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

  QueryBuilder<UrlModelIsar, UrlModelIsar, QAfterWhereClause> createdAtBetween(
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

  QueryBuilder<UrlModelIsar, UrlModelIsar, QAfterWhereClause> updatedAtEqualTo(
      DateTime updatedAt) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'updatedAt',
        value: [updatedAt],
      ));
    });
  }

  QueryBuilder<UrlModelIsar, UrlModelIsar, QAfterWhereClause>
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

  QueryBuilder<UrlModelIsar, UrlModelIsar, QAfterWhereClause>
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

  QueryBuilder<UrlModelIsar, UrlModelIsar, QAfterWhereClause> updatedAtLessThan(
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

  QueryBuilder<UrlModelIsar, UrlModelIsar, QAfterWhereClause> updatedAtBetween(
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
}

extension UrlModelIsarQueryFilter
    on QueryBuilder<UrlModelIsar, UrlModelIsar, QFilterCondition> {
  QueryBuilder<UrlModelIsar, UrlModelIsar, QAfterFilterCondition>
      collectionIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'collectionId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UrlModelIsar, UrlModelIsar, QAfterFilterCondition>
      collectionIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'collectionId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UrlModelIsar, UrlModelIsar, QAfterFilterCondition>
      collectionIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'collectionId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UrlModelIsar, UrlModelIsar, QAfterFilterCondition>
      collectionIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'collectionId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UrlModelIsar, UrlModelIsar, QAfterFilterCondition>
      collectionIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'collectionId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UrlModelIsar, UrlModelIsar, QAfterFilterCondition>
      collectionIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'collectionId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UrlModelIsar, UrlModelIsar, QAfterFilterCondition>
      collectionIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'collectionId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UrlModelIsar, UrlModelIsar, QAfterFilterCondition>
      collectionIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'collectionId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UrlModelIsar, UrlModelIsar, QAfterFilterCondition>
      collectionIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'collectionId',
        value: '',
      ));
    });
  }

  QueryBuilder<UrlModelIsar, UrlModelIsar, QAfterFilterCondition>
      collectionIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'collectionId',
        value: '',
      ));
    });
  }

  QueryBuilder<UrlModelIsar, UrlModelIsar, QAfterFilterCondition>
      createdAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<UrlModelIsar, UrlModelIsar, QAfterFilterCondition>
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

  QueryBuilder<UrlModelIsar, UrlModelIsar, QAfterFilterCondition>
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

  QueryBuilder<UrlModelIsar, UrlModelIsar, QAfterFilterCondition>
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

  QueryBuilder<UrlModelIsar, UrlModelIsar, QAfterFilterCondition>
      descriptionIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'description',
      ));
    });
  }

  QueryBuilder<UrlModelIsar, UrlModelIsar, QAfterFilterCondition>
      descriptionIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'description',
      ));
    });
  }

  QueryBuilder<UrlModelIsar, UrlModelIsar, QAfterFilterCondition>
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

  QueryBuilder<UrlModelIsar, UrlModelIsar, QAfterFilterCondition>
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

  QueryBuilder<UrlModelIsar, UrlModelIsar, QAfterFilterCondition>
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

  QueryBuilder<UrlModelIsar, UrlModelIsar, QAfterFilterCondition>
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

  QueryBuilder<UrlModelIsar, UrlModelIsar, QAfterFilterCondition>
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

  QueryBuilder<UrlModelIsar, UrlModelIsar, QAfterFilterCondition>
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

  QueryBuilder<UrlModelIsar, UrlModelIsar, QAfterFilterCondition>
      descriptionContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'description',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UrlModelIsar, UrlModelIsar, QAfterFilterCondition>
      descriptionMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'description',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UrlModelIsar, UrlModelIsar, QAfterFilterCondition>
      descriptionIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'description',
        value: '',
      ));
    });
  }

  QueryBuilder<UrlModelIsar, UrlModelIsar, QAfterFilterCondition>
      descriptionIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'description',
        value: '',
      ));
    });
  }

  QueryBuilder<UrlModelIsar, UrlModelIsar, QAfterFilterCondition>
      firestoreIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'firestoreId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UrlModelIsar, UrlModelIsar, QAfterFilterCondition>
      firestoreIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'firestoreId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UrlModelIsar, UrlModelIsar, QAfterFilterCondition>
      firestoreIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'firestoreId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UrlModelIsar, UrlModelIsar, QAfterFilterCondition>
      firestoreIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'firestoreId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UrlModelIsar, UrlModelIsar, QAfterFilterCondition>
      firestoreIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'firestoreId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UrlModelIsar, UrlModelIsar, QAfterFilterCondition>
      firestoreIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'firestoreId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UrlModelIsar, UrlModelIsar, QAfterFilterCondition>
      firestoreIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'firestoreId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UrlModelIsar, UrlModelIsar, QAfterFilterCondition>
      firestoreIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'firestoreId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UrlModelIsar, UrlModelIsar, QAfterFilterCondition>
      firestoreIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'firestoreId',
        value: '',
      ));
    });
  }

  QueryBuilder<UrlModelIsar, UrlModelIsar, QAfterFilterCondition>
      firestoreIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'firestoreId',
        value: '',
      ));
    });
  }

  QueryBuilder<UrlModelIsar, UrlModelIsar, QAfterFilterCondition>
      htmlContentIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'htmlContent',
      ));
    });
  }

  QueryBuilder<UrlModelIsar, UrlModelIsar, QAfterFilterCondition>
      htmlContentIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'htmlContent',
      ));
    });
  }

  QueryBuilder<UrlModelIsar, UrlModelIsar, QAfterFilterCondition>
      htmlContentEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'htmlContent',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UrlModelIsar, UrlModelIsar, QAfterFilterCondition>
      htmlContentGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'htmlContent',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UrlModelIsar, UrlModelIsar, QAfterFilterCondition>
      htmlContentLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'htmlContent',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UrlModelIsar, UrlModelIsar, QAfterFilterCondition>
      htmlContentBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'htmlContent',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UrlModelIsar, UrlModelIsar, QAfterFilterCondition>
      htmlContentStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'htmlContent',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UrlModelIsar, UrlModelIsar, QAfterFilterCondition>
      htmlContentEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'htmlContent',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UrlModelIsar, UrlModelIsar, QAfterFilterCondition>
      htmlContentContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'htmlContent',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UrlModelIsar, UrlModelIsar, QAfterFilterCondition>
      htmlContentMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'htmlContent',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UrlModelIsar, UrlModelIsar, QAfterFilterCondition>
      htmlContentIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'htmlContent',
        value: '',
      ));
    });
  }

  QueryBuilder<UrlModelIsar, UrlModelIsar, QAfterFilterCondition>
      htmlContentIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'htmlContent',
        value: '',
      ));
    });
  }

  QueryBuilder<UrlModelIsar, UrlModelIsar, QAfterFilterCondition> idIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'id',
      ));
    });
  }

  QueryBuilder<UrlModelIsar, UrlModelIsar, QAfterFilterCondition>
      idIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'id',
      ));
    });
  }

  QueryBuilder<UrlModelIsar, UrlModelIsar, QAfterFilterCondition> idEqualTo(
      Id? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<UrlModelIsar, UrlModelIsar, QAfterFilterCondition> idGreaterThan(
    Id? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<UrlModelIsar, UrlModelIsar, QAfterFilterCondition> idLessThan(
    Id? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<UrlModelIsar, UrlModelIsar, QAfterFilterCondition> idBetween(
    Id? lower,
    Id? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'id',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<UrlModelIsar, UrlModelIsar, QAfterFilterCondition>
      isFavouriteEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isFavourite',
        value: value,
      ));
    });
  }

  QueryBuilder<UrlModelIsar, UrlModelIsar, QAfterFilterCondition>
      isOfflineEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isOffline',
        value: value,
      ));
    });
  }

  QueryBuilder<UrlModelIsar, UrlModelIsar, QAfterFilterCondition>
      metaDataIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'metaData',
      ));
    });
  }

  QueryBuilder<UrlModelIsar, UrlModelIsar, QAfterFilterCondition>
      metaDataIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'metaData',
      ));
    });
  }

  QueryBuilder<UrlModelIsar, UrlModelIsar, QAfterFilterCondition>
      metaDataEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'metaData',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UrlModelIsar, UrlModelIsar, QAfterFilterCondition>
      metaDataGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'metaData',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UrlModelIsar, UrlModelIsar, QAfterFilterCondition>
      metaDataLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'metaData',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UrlModelIsar, UrlModelIsar, QAfterFilterCondition>
      metaDataBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'metaData',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UrlModelIsar, UrlModelIsar, QAfterFilterCondition>
      metaDataStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'metaData',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UrlModelIsar, UrlModelIsar, QAfterFilterCondition>
      metaDataEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'metaData',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UrlModelIsar, UrlModelIsar, QAfterFilterCondition>
      metaDataContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'metaData',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UrlModelIsar, UrlModelIsar, QAfterFilterCondition>
      metaDataMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'metaData',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UrlModelIsar, UrlModelIsar, QAfterFilterCondition>
      metaDataIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'metaData',
        value: '',
      ));
    });
  }

  QueryBuilder<UrlModelIsar, UrlModelIsar, QAfterFilterCondition>
      metaDataIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'metaData',
        value: '',
      ));
    });
  }

  QueryBuilder<UrlModelIsar, UrlModelIsar, QAfterFilterCondition>
      parentUrlModelFirestoreIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'parentUrlModelFirestoreId',
      ));
    });
  }

  QueryBuilder<UrlModelIsar, UrlModelIsar, QAfterFilterCondition>
      parentUrlModelFirestoreIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'parentUrlModelFirestoreId',
      ));
    });
  }

  QueryBuilder<UrlModelIsar, UrlModelIsar, QAfterFilterCondition>
      parentUrlModelFirestoreIdEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'parentUrlModelFirestoreId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UrlModelIsar, UrlModelIsar, QAfterFilterCondition>
      parentUrlModelFirestoreIdGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'parentUrlModelFirestoreId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UrlModelIsar, UrlModelIsar, QAfterFilterCondition>
      parentUrlModelFirestoreIdLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'parentUrlModelFirestoreId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UrlModelIsar, UrlModelIsar, QAfterFilterCondition>
      parentUrlModelFirestoreIdBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'parentUrlModelFirestoreId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UrlModelIsar, UrlModelIsar, QAfterFilterCondition>
      parentUrlModelFirestoreIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'parentUrlModelFirestoreId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UrlModelIsar, UrlModelIsar, QAfterFilterCondition>
      parentUrlModelFirestoreIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'parentUrlModelFirestoreId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UrlModelIsar, UrlModelIsar, QAfterFilterCondition>
      parentUrlModelFirestoreIdContains(String value,
          {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'parentUrlModelFirestoreId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UrlModelIsar, UrlModelIsar, QAfterFilterCondition>
      parentUrlModelFirestoreIdMatches(String pattern,
          {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'parentUrlModelFirestoreId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UrlModelIsar, UrlModelIsar, QAfterFilterCondition>
      parentUrlModelFirestoreIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'parentUrlModelFirestoreId',
        value: '',
      ));
    });
  }

  QueryBuilder<UrlModelIsar, UrlModelIsar, QAfterFilterCondition>
      parentUrlModelFirestoreIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'parentUrlModelFirestoreId',
        value: '',
      ));
    });
  }

  QueryBuilder<UrlModelIsar, UrlModelIsar, QAfterFilterCondition>
      settingsIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'settings',
      ));
    });
  }

  QueryBuilder<UrlModelIsar, UrlModelIsar, QAfterFilterCondition>
      settingsIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'settings',
      ));
    });
  }

  QueryBuilder<UrlModelIsar, UrlModelIsar, QAfterFilterCondition>
      settingsEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'settings',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UrlModelIsar, UrlModelIsar, QAfterFilterCondition>
      settingsGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'settings',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UrlModelIsar, UrlModelIsar, QAfterFilterCondition>
      settingsLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'settings',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UrlModelIsar, UrlModelIsar, QAfterFilterCondition>
      settingsBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'settings',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UrlModelIsar, UrlModelIsar, QAfterFilterCondition>
      settingsStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'settings',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UrlModelIsar, UrlModelIsar, QAfterFilterCondition>
      settingsEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'settings',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UrlModelIsar, UrlModelIsar, QAfterFilterCondition>
      settingsContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'settings',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UrlModelIsar, UrlModelIsar, QAfterFilterCondition>
      settingsMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'settings',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UrlModelIsar, UrlModelIsar, QAfterFilterCondition>
      settingsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'settings',
        value: '',
      ));
    });
  }

  QueryBuilder<UrlModelIsar, UrlModelIsar, QAfterFilterCondition>
      settingsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'settings',
        value: '',
      ));
    });
  }

  QueryBuilder<UrlModelIsar, UrlModelIsar, QAfterFilterCondition> tagEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'tag',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UrlModelIsar, UrlModelIsar, QAfterFilterCondition>
      tagGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'tag',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UrlModelIsar, UrlModelIsar, QAfterFilterCondition> tagLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'tag',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UrlModelIsar, UrlModelIsar, QAfterFilterCondition> tagBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'tag',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UrlModelIsar, UrlModelIsar, QAfterFilterCondition> tagStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'tag',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UrlModelIsar, UrlModelIsar, QAfterFilterCondition> tagEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'tag',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UrlModelIsar, UrlModelIsar, QAfterFilterCondition> tagContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'tag',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UrlModelIsar, UrlModelIsar, QAfterFilterCondition> tagMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'tag',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UrlModelIsar, UrlModelIsar, QAfterFilterCondition> tagIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'tag',
        value: '',
      ));
    });
  }

  QueryBuilder<UrlModelIsar, UrlModelIsar, QAfterFilterCondition>
      tagIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'tag',
        value: '',
      ));
    });
  }

  QueryBuilder<UrlModelIsar, UrlModelIsar, QAfterFilterCondition> titleEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UrlModelIsar, UrlModelIsar, QAfterFilterCondition>
      titleGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UrlModelIsar, UrlModelIsar, QAfterFilterCondition> titleLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UrlModelIsar, UrlModelIsar, QAfterFilterCondition> titleBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'title',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UrlModelIsar, UrlModelIsar, QAfterFilterCondition>
      titleStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UrlModelIsar, UrlModelIsar, QAfterFilterCondition> titleEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UrlModelIsar, UrlModelIsar, QAfterFilterCondition> titleContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UrlModelIsar, UrlModelIsar, QAfterFilterCondition> titleMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'title',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UrlModelIsar, UrlModelIsar, QAfterFilterCondition>
      titleIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'title',
        value: '',
      ));
    });
  }

  QueryBuilder<UrlModelIsar, UrlModelIsar, QAfterFilterCondition>
      titleIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'title',
        value: '',
      ));
    });
  }

  QueryBuilder<UrlModelIsar, UrlModelIsar, QAfterFilterCondition>
      updatedAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'updatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<UrlModelIsar, UrlModelIsar, QAfterFilterCondition>
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

  QueryBuilder<UrlModelIsar, UrlModelIsar, QAfterFilterCondition>
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

  QueryBuilder<UrlModelIsar, UrlModelIsar, QAfterFilterCondition>
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

  QueryBuilder<UrlModelIsar, UrlModelIsar, QAfterFilterCondition> urlEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'url',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UrlModelIsar, UrlModelIsar, QAfterFilterCondition>
      urlGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'url',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UrlModelIsar, UrlModelIsar, QAfterFilterCondition> urlLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'url',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UrlModelIsar, UrlModelIsar, QAfterFilterCondition> urlBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'url',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UrlModelIsar, UrlModelIsar, QAfterFilterCondition> urlStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'url',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UrlModelIsar, UrlModelIsar, QAfterFilterCondition> urlEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'url',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UrlModelIsar, UrlModelIsar, QAfterFilterCondition> urlContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'url',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UrlModelIsar, UrlModelIsar, QAfterFilterCondition> urlMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'url',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UrlModelIsar, UrlModelIsar, QAfterFilterCondition> urlIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'url',
        value: '',
      ));
    });
  }

  QueryBuilder<UrlModelIsar, UrlModelIsar, QAfterFilterCondition>
      urlIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'url',
        value: '',
      ));
    });
  }
}

extension UrlModelIsarQueryObject
    on QueryBuilder<UrlModelIsar, UrlModelIsar, QFilterCondition> {}

extension UrlModelIsarQueryLinks
    on QueryBuilder<UrlModelIsar, UrlModelIsar, QFilterCondition> {}

extension UrlModelIsarQuerySortBy
    on QueryBuilder<UrlModelIsar, UrlModelIsar, QSortBy> {
  QueryBuilder<UrlModelIsar, UrlModelIsar, QAfterSortBy> sortByCollectionId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'collectionId', Sort.asc);
    });
  }

  QueryBuilder<UrlModelIsar, UrlModelIsar, QAfterSortBy>
      sortByCollectionIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'collectionId', Sort.desc);
    });
  }

  QueryBuilder<UrlModelIsar, UrlModelIsar, QAfterSortBy> sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<UrlModelIsar, UrlModelIsar, QAfterSortBy> sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<UrlModelIsar, UrlModelIsar, QAfterSortBy> sortByDescription() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'description', Sort.asc);
    });
  }

  QueryBuilder<UrlModelIsar, UrlModelIsar, QAfterSortBy>
      sortByDescriptionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'description', Sort.desc);
    });
  }

  QueryBuilder<UrlModelIsar, UrlModelIsar, QAfterSortBy> sortByFirestoreId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'firestoreId', Sort.asc);
    });
  }

  QueryBuilder<UrlModelIsar, UrlModelIsar, QAfterSortBy>
      sortByFirestoreIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'firestoreId', Sort.desc);
    });
  }

  QueryBuilder<UrlModelIsar, UrlModelIsar, QAfterSortBy> sortByHtmlContent() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'htmlContent', Sort.asc);
    });
  }

  QueryBuilder<UrlModelIsar, UrlModelIsar, QAfterSortBy>
      sortByHtmlContentDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'htmlContent', Sort.desc);
    });
  }

  QueryBuilder<UrlModelIsar, UrlModelIsar, QAfterSortBy> sortByIsFavourite() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isFavourite', Sort.asc);
    });
  }

  QueryBuilder<UrlModelIsar, UrlModelIsar, QAfterSortBy>
      sortByIsFavouriteDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isFavourite', Sort.desc);
    });
  }

  QueryBuilder<UrlModelIsar, UrlModelIsar, QAfterSortBy> sortByIsOffline() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isOffline', Sort.asc);
    });
  }

  QueryBuilder<UrlModelIsar, UrlModelIsar, QAfterSortBy> sortByIsOfflineDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isOffline', Sort.desc);
    });
  }

  QueryBuilder<UrlModelIsar, UrlModelIsar, QAfterSortBy> sortByMetaData() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'metaData', Sort.asc);
    });
  }

  QueryBuilder<UrlModelIsar, UrlModelIsar, QAfterSortBy> sortByMetaDataDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'metaData', Sort.desc);
    });
  }

  QueryBuilder<UrlModelIsar, UrlModelIsar, QAfterSortBy>
      sortByParentUrlModelFirestoreId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'parentUrlModelFirestoreId', Sort.asc);
    });
  }

  QueryBuilder<UrlModelIsar, UrlModelIsar, QAfterSortBy>
      sortByParentUrlModelFirestoreIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'parentUrlModelFirestoreId', Sort.desc);
    });
  }

  QueryBuilder<UrlModelIsar, UrlModelIsar, QAfterSortBy> sortBySettings() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'settings', Sort.asc);
    });
  }

  QueryBuilder<UrlModelIsar, UrlModelIsar, QAfterSortBy> sortBySettingsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'settings', Sort.desc);
    });
  }

  QueryBuilder<UrlModelIsar, UrlModelIsar, QAfterSortBy> sortByTag() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tag', Sort.asc);
    });
  }

  QueryBuilder<UrlModelIsar, UrlModelIsar, QAfterSortBy> sortByTagDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tag', Sort.desc);
    });
  }

  QueryBuilder<UrlModelIsar, UrlModelIsar, QAfterSortBy> sortByTitle() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.asc);
    });
  }

  QueryBuilder<UrlModelIsar, UrlModelIsar, QAfterSortBy> sortByTitleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.desc);
    });
  }

  QueryBuilder<UrlModelIsar, UrlModelIsar, QAfterSortBy> sortByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<UrlModelIsar, UrlModelIsar, QAfterSortBy> sortByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }

  QueryBuilder<UrlModelIsar, UrlModelIsar, QAfterSortBy> sortByUrl() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'url', Sort.asc);
    });
  }

  QueryBuilder<UrlModelIsar, UrlModelIsar, QAfterSortBy> sortByUrlDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'url', Sort.desc);
    });
  }
}

extension UrlModelIsarQuerySortThenBy
    on QueryBuilder<UrlModelIsar, UrlModelIsar, QSortThenBy> {
  QueryBuilder<UrlModelIsar, UrlModelIsar, QAfterSortBy> thenByCollectionId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'collectionId', Sort.asc);
    });
  }

  QueryBuilder<UrlModelIsar, UrlModelIsar, QAfterSortBy>
      thenByCollectionIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'collectionId', Sort.desc);
    });
  }

  QueryBuilder<UrlModelIsar, UrlModelIsar, QAfterSortBy> thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<UrlModelIsar, UrlModelIsar, QAfterSortBy> thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<UrlModelIsar, UrlModelIsar, QAfterSortBy> thenByDescription() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'description', Sort.asc);
    });
  }

  QueryBuilder<UrlModelIsar, UrlModelIsar, QAfterSortBy>
      thenByDescriptionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'description', Sort.desc);
    });
  }

  QueryBuilder<UrlModelIsar, UrlModelIsar, QAfterSortBy> thenByFirestoreId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'firestoreId', Sort.asc);
    });
  }

  QueryBuilder<UrlModelIsar, UrlModelIsar, QAfterSortBy>
      thenByFirestoreIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'firestoreId', Sort.desc);
    });
  }

  QueryBuilder<UrlModelIsar, UrlModelIsar, QAfterSortBy> thenByHtmlContent() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'htmlContent', Sort.asc);
    });
  }

  QueryBuilder<UrlModelIsar, UrlModelIsar, QAfterSortBy>
      thenByHtmlContentDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'htmlContent', Sort.desc);
    });
  }

  QueryBuilder<UrlModelIsar, UrlModelIsar, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<UrlModelIsar, UrlModelIsar, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<UrlModelIsar, UrlModelIsar, QAfterSortBy> thenByIsFavourite() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isFavourite', Sort.asc);
    });
  }

  QueryBuilder<UrlModelIsar, UrlModelIsar, QAfterSortBy>
      thenByIsFavouriteDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isFavourite', Sort.desc);
    });
  }

  QueryBuilder<UrlModelIsar, UrlModelIsar, QAfterSortBy> thenByIsOffline() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isOffline', Sort.asc);
    });
  }

  QueryBuilder<UrlModelIsar, UrlModelIsar, QAfterSortBy> thenByIsOfflineDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isOffline', Sort.desc);
    });
  }

  QueryBuilder<UrlModelIsar, UrlModelIsar, QAfterSortBy> thenByMetaData() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'metaData', Sort.asc);
    });
  }

  QueryBuilder<UrlModelIsar, UrlModelIsar, QAfterSortBy> thenByMetaDataDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'metaData', Sort.desc);
    });
  }

  QueryBuilder<UrlModelIsar, UrlModelIsar, QAfterSortBy>
      thenByParentUrlModelFirestoreId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'parentUrlModelFirestoreId', Sort.asc);
    });
  }

  QueryBuilder<UrlModelIsar, UrlModelIsar, QAfterSortBy>
      thenByParentUrlModelFirestoreIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'parentUrlModelFirestoreId', Sort.desc);
    });
  }

  QueryBuilder<UrlModelIsar, UrlModelIsar, QAfterSortBy> thenBySettings() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'settings', Sort.asc);
    });
  }

  QueryBuilder<UrlModelIsar, UrlModelIsar, QAfterSortBy> thenBySettingsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'settings', Sort.desc);
    });
  }

  QueryBuilder<UrlModelIsar, UrlModelIsar, QAfterSortBy> thenByTag() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tag', Sort.asc);
    });
  }

  QueryBuilder<UrlModelIsar, UrlModelIsar, QAfterSortBy> thenByTagDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tag', Sort.desc);
    });
  }

  QueryBuilder<UrlModelIsar, UrlModelIsar, QAfterSortBy> thenByTitle() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.asc);
    });
  }

  QueryBuilder<UrlModelIsar, UrlModelIsar, QAfterSortBy> thenByTitleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.desc);
    });
  }

  QueryBuilder<UrlModelIsar, UrlModelIsar, QAfterSortBy> thenByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<UrlModelIsar, UrlModelIsar, QAfterSortBy> thenByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }

  QueryBuilder<UrlModelIsar, UrlModelIsar, QAfterSortBy> thenByUrl() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'url', Sort.asc);
    });
  }

  QueryBuilder<UrlModelIsar, UrlModelIsar, QAfterSortBy> thenByUrlDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'url', Sort.desc);
    });
  }
}

extension UrlModelIsarQueryWhereDistinct
    on QueryBuilder<UrlModelIsar, UrlModelIsar, QDistinct> {
  QueryBuilder<UrlModelIsar, UrlModelIsar, QDistinct> distinctByCollectionId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'collectionId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<UrlModelIsar, UrlModelIsar, QDistinct> distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdAt');
    });
  }

  QueryBuilder<UrlModelIsar, UrlModelIsar, QDistinct> distinctByDescription(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'description', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<UrlModelIsar, UrlModelIsar, QDistinct> distinctByFirestoreId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'firestoreId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<UrlModelIsar, UrlModelIsar, QDistinct> distinctByHtmlContent(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'htmlContent', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<UrlModelIsar, UrlModelIsar, QDistinct> distinctByIsFavourite() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isFavourite');
    });
  }

  QueryBuilder<UrlModelIsar, UrlModelIsar, QDistinct> distinctByIsOffline() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isOffline');
    });
  }

  QueryBuilder<UrlModelIsar, UrlModelIsar, QDistinct> distinctByMetaData(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'metaData', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<UrlModelIsar, UrlModelIsar, QDistinct>
      distinctByParentUrlModelFirestoreId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'parentUrlModelFirestoreId',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<UrlModelIsar, UrlModelIsar, QDistinct> distinctBySettings(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'settings', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<UrlModelIsar, UrlModelIsar, QDistinct> distinctByTag(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'tag', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<UrlModelIsar, UrlModelIsar, QDistinct> distinctByTitle(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'title', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<UrlModelIsar, UrlModelIsar, QDistinct> distinctByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'updatedAt');
    });
  }

  QueryBuilder<UrlModelIsar, UrlModelIsar, QDistinct> distinctByUrl(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'url', caseSensitive: caseSensitive);
    });
  }
}

extension UrlModelIsarQueryProperty
    on QueryBuilder<UrlModelIsar, UrlModelIsar, QQueryProperty> {
  QueryBuilder<UrlModelIsar, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<UrlModelIsar, String, QQueryOperations> collectionIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'collectionId');
    });
  }

  QueryBuilder<UrlModelIsar, DateTime, QQueryOperations> createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdAt');
    });
  }

  QueryBuilder<UrlModelIsar, String?, QQueryOperations> descriptionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'description');
    });
  }

  QueryBuilder<UrlModelIsar, String, QQueryOperations> firestoreIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'firestoreId');
    });
  }

  QueryBuilder<UrlModelIsar, String?, QQueryOperations> htmlContentProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'htmlContent');
    });
  }

  QueryBuilder<UrlModelIsar, bool, QQueryOperations> isFavouriteProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isFavourite');
    });
  }

  QueryBuilder<UrlModelIsar, bool, QQueryOperations> isOfflineProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isOffline');
    });
  }

  QueryBuilder<UrlModelIsar, String?, QQueryOperations> metaDataProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'metaData');
    });
  }

  QueryBuilder<UrlModelIsar, String?, QQueryOperations>
      parentUrlModelFirestoreIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'parentUrlModelFirestoreId');
    });
  }

  QueryBuilder<UrlModelIsar, String?, QQueryOperations> settingsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'settings');
    });
  }

  QueryBuilder<UrlModelIsar, String, QQueryOperations> tagProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'tag');
    });
  }

  QueryBuilder<UrlModelIsar, String, QQueryOperations> titleProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'title');
    });
  }

  QueryBuilder<UrlModelIsar, DateTime, QQueryOperations> updatedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'updatedAt');
    });
  }

  QueryBuilder<UrlModelIsar, String, QQueryOperations> urlProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'url');
    });
  }
}
