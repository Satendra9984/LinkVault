// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'collection_share_model.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetCollectionShareModelCollection on Isar {
  IsarCollection<CollectionShareModel> get collectionShareModels =>
      this.collection();
}

const CollectionShareModelSchema = CollectionSchema(
  name: r'CollectionShareModel',
  id: -4545843080230526016,
  properties: {
    r'acceptedAt': PropertySchema(
      id: 0,
      name: r'acceptedAt',
      type: IsarType.dateTime,
    ),
    r'canReshare': PropertySchema(
      id: 1,
      name: r'canReshare',
      type: IsarType.bool,
    ),
    r'collectionId': PropertySchema(
      id: 2,
      name: r'collectionId',
      type: IsarType.string,
    ),
    r'createdAt': PropertySchema(
      id: 3,
      name: r'createdAt',
      type: IsarType.dateTime,
    ),
    r'expiresAt': PropertySchema(
      id: 4,
      name: r'expiresAt',
      type: IsarType.dateTime,
    ),
    r'id': PropertySchema(
      id: 5,
      name: r'id',
      type: IsarType.string,
    ),
    r'invitationToken': PropertySchema(
      id: 6,
      name: r'invitationToken',
      type: IsarType.string,
    ),
    r'permissionLevel': PropertySchema(
      id: 7,
      name: r'permissionLevel',
      type: IsarType.string,
    ),
    r'sharedByUserId': PropertySchema(
      id: 8,
      name: r'sharedByUserId',
      type: IsarType.string,
    ),
    r'sharedWithEmail': PropertySchema(
      id: 9,
      name: r'sharedWithEmail',
      type: IsarType.string,
    ),
    r'sharedWithUserId': PropertySchema(
      id: 10,
      name: r'sharedWithUserId',
      type: IsarType.string,
    ),
    r'status': PropertySchema(
      id: 11,
      name: r'status',
      type: IsarType.string,
    )
  },
  estimateSize: _collectionShareModelEstimateSize,
  serialize: _collectionShareModelSerialize,
  deserialize: _collectionShareModelDeserialize,
  deserializeProp: _collectionShareModelDeserializeProp,
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
    r'sharedByUserId': IndexSchema(
      id: 2057187170528208220,
      name: r'sharedByUserId',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'sharedByUserId',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    ),
    r'status': IndexSchema(
      id: -107785170620420283,
      name: r'status',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'status',
          type: IndexType.hash,
          caseSensitive: true,
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
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _collectionShareModelGetId,
  getLinks: _collectionShareModelGetLinks,
  attach: _collectionShareModelAttach,
  version: '3.1.0+1',
);

int _collectionShareModelEstimateSize(
  CollectionShareModel object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.collectionId.length * 3;
  bytesCount += 3 + object.id.length * 3;
  bytesCount += 3 + object.invitationToken.length * 3;
  bytesCount += 3 + object.permissionLevel.length * 3;
  bytesCount += 3 + object.sharedByUserId.length * 3;
  {
    final value = object.sharedWithEmail;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.sharedWithUserId;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.status.length * 3;
  return bytesCount;
}

void _collectionShareModelSerialize(
  CollectionShareModel object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDateTime(offsets[0], object.acceptedAt);
  writer.writeBool(offsets[1], object.canReshare);
  writer.writeString(offsets[2], object.collectionId);
  writer.writeDateTime(offsets[3], object.createdAt);
  writer.writeDateTime(offsets[4], object.expiresAt);
  writer.writeString(offsets[5], object.id);
  writer.writeString(offsets[6], object.invitationToken);
  writer.writeString(offsets[7], object.permissionLevel);
  writer.writeString(offsets[8], object.sharedByUserId);
  writer.writeString(offsets[9], object.sharedWithEmail);
  writer.writeString(offsets[10], object.sharedWithUserId);
  writer.writeString(offsets[11], object.status);
}

CollectionShareModel _collectionShareModelDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = CollectionShareModel(
    acceptedAt: reader.readDateTimeOrNull(offsets[0]),
    canReshare: reader.readBool(offsets[1]),
    collectionId: reader.readString(offsets[2]),
    createdAt: reader.readDateTime(offsets[3]),
    expiresAt: reader.readDateTimeOrNull(offsets[4]),
    id: reader.readString(offsets[5]),
    invitationToken: reader.readString(offsets[6]),
    isarId: id,
    permissionLevel: reader.readString(offsets[7]),
    sharedByUserId: reader.readString(offsets[8]),
    sharedWithEmail: reader.readStringOrNull(offsets[9]),
    sharedWithUserId: reader.readStringOrNull(offsets[10]),
    status: reader.readString(offsets[11]),
  );
  return object;
}

P _collectionShareModelDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 1:
      return (reader.readBool(offset)) as P;
    case 2:
      return (reader.readString(offset)) as P;
    case 3:
      return (reader.readDateTime(offset)) as P;
    case 4:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 5:
      return (reader.readString(offset)) as P;
    case 6:
      return (reader.readString(offset)) as P;
    case 7:
      return (reader.readString(offset)) as P;
    case 8:
      return (reader.readString(offset)) as P;
    case 9:
      return (reader.readStringOrNull(offset)) as P;
    case 10:
      return (reader.readStringOrNull(offset)) as P;
    case 11:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _collectionShareModelGetId(CollectionShareModel object) {
  return object.isarId;
}

List<IsarLinkBase<dynamic>> _collectionShareModelGetLinks(
    CollectionShareModel object) {
  return [];
}

void _collectionShareModelAttach(
    IsarCollection<dynamic> col, Id id, CollectionShareModel object) {}

extension CollectionShareModelQueryWhereSort
    on QueryBuilder<CollectionShareModel, CollectionShareModel, QWhere> {
  QueryBuilder<CollectionShareModel, CollectionShareModel, QAfterWhere>
      anyIsarId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<CollectionShareModel, CollectionShareModel, QAfterWhere>
      anyCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'createdAt'),
      );
    });
  }
}

extension CollectionShareModelQueryWhere
    on QueryBuilder<CollectionShareModel, CollectionShareModel, QWhereClause> {
  QueryBuilder<CollectionShareModel, CollectionShareModel, QAfterWhereClause>
      isarIdEqualTo(Id isarId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: isarId,
        upper: isarId,
      ));
    });
  }

  QueryBuilder<CollectionShareModel, CollectionShareModel, QAfterWhereClause>
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

  QueryBuilder<CollectionShareModel, CollectionShareModel, QAfterWhereClause>
      isarIdGreaterThan(Id isarId, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: isarId, includeLower: include),
      );
    });
  }

  QueryBuilder<CollectionShareModel, CollectionShareModel, QAfterWhereClause>
      isarIdLessThan(Id isarId, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: isarId, includeUpper: include),
      );
    });
  }

  QueryBuilder<CollectionShareModel, CollectionShareModel, QAfterWhereClause>
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

  QueryBuilder<CollectionShareModel, CollectionShareModel, QAfterWhereClause>
      idEqualTo(String id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'id',
        value: [id],
      ));
    });
  }

  QueryBuilder<CollectionShareModel, CollectionShareModel, QAfterWhereClause>
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

  QueryBuilder<CollectionShareModel, CollectionShareModel, QAfterWhereClause>
      collectionIdEqualTo(String collectionId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'collectionId',
        value: [collectionId],
      ));
    });
  }

  QueryBuilder<CollectionShareModel, CollectionShareModel, QAfterWhereClause>
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

  QueryBuilder<CollectionShareModel, CollectionShareModel, QAfterWhereClause>
      sharedByUserIdEqualTo(String sharedByUserId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'sharedByUserId',
        value: [sharedByUserId],
      ));
    });
  }

  QueryBuilder<CollectionShareModel, CollectionShareModel, QAfterWhereClause>
      sharedByUserIdNotEqualTo(String sharedByUserId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'sharedByUserId',
              lower: [],
              upper: [sharedByUserId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'sharedByUserId',
              lower: [sharedByUserId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'sharedByUserId',
              lower: [sharedByUserId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'sharedByUserId',
              lower: [],
              upper: [sharedByUserId],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<CollectionShareModel, CollectionShareModel, QAfterWhereClause>
      statusEqualTo(String status) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'status',
        value: [status],
      ));
    });
  }

  QueryBuilder<CollectionShareModel, CollectionShareModel, QAfterWhereClause>
      statusNotEqualTo(String status) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'status',
              lower: [],
              upper: [status],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'status',
              lower: [status],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'status',
              lower: [status],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'status',
              lower: [],
              upper: [status],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<CollectionShareModel, CollectionShareModel, QAfterWhereClause>
      createdAtEqualTo(DateTime createdAt) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'createdAt',
        value: [createdAt],
      ));
    });
  }

  QueryBuilder<CollectionShareModel, CollectionShareModel, QAfterWhereClause>
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

  QueryBuilder<CollectionShareModel, CollectionShareModel, QAfterWhereClause>
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

  QueryBuilder<CollectionShareModel, CollectionShareModel, QAfterWhereClause>
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

  QueryBuilder<CollectionShareModel, CollectionShareModel, QAfterWhereClause>
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
}

extension CollectionShareModelQueryFilter on QueryBuilder<CollectionShareModel,
    CollectionShareModel, QFilterCondition> {
  QueryBuilder<CollectionShareModel, CollectionShareModel,
      QAfterFilterCondition> acceptedAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'acceptedAt',
      ));
    });
  }

  QueryBuilder<CollectionShareModel, CollectionShareModel,
      QAfterFilterCondition> acceptedAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'acceptedAt',
      ));
    });
  }

  QueryBuilder<CollectionShareModel, CollectionShareModel,
      QAfterFilterCondition> acceptedAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'acceptedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<CollectionShareModel, CollectionShareModel,
      QAfterFilterCondition> acceptedAtGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'acceptedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<CollectionShareModel, CollectionShareModel,
      QAfterFilterCondition> acceptedAtLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'acceptedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<CollectionShareModel, CollectionShareModel,
      QAfterFilterCondition> acceptedAtBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'acceptedAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<CollectionShareModel, CollectionShareModel,
      QAfterFilterCondition> canReshareEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'canReshare',
        value: value,
      ));
    });
  }

  QueryBuilder<CollectionShareModel, CollectionShareModel,
      QAfterFilterCondition> collectionIdEqualTo(
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

  QueryBuilder<CollectionShareModel, CollectionShareModel,
      QAfterFilterCondition> collectionIdGreaterThan(
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

  QueryBuilder<CollectionShareModel, CollectionShareModel,
      QAfterFilterCondition> collectionIdLessThan(
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

  QueryBuilder<CollectionShareModel, CollectionShareModel,
      QAfterFilterCondition> collectionIdBetween(
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

  QueryBuilder<CollectionShareModel, CollectionShareModel,
      QAfterFilterCondition> collectionIdStartsWith(
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

  QueryBuilder<CollectionShareModel, CollectionShareModel,
      QAfterFilterCondition> collectionIdEndsWith(
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

  QueryBuilder<CollectionShareModel, CollectionShareModel,
          QAfterFilterCondition>
      collectionIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'collectionId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CollectionShareModel, CollectionShareModel,
          QAfterFilterCondition>
      collectionIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'collectionId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CollectionShareModel, CollectionShareModel,
      QAfterFilterCondition> collectionIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'collectionId',
        value: '',
      ));
    });
  }

  QueryBuilder<CollectionShareModel, CollectionShareModel,
      QAfterFilterCondition> collectionIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'collectionId',
        value: '',
      ));
    });
  }

  QueryBuilder<CollectionShareModel, CollectionShareModel,
      QAfterFilterCondition> createdAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<CollectionShareModel, CollectionShareModel,
      QAfterFilterCondition> createdAtGreaterThan(
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

  QueryBuilder<CollectionShareModel, CollectionShareModel,
      QAfterFilterCondition> createdAtLessThan(
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

  QueryBuilder<CollectionShareModel, CollectionShareModel,
      QAfterFilterCondition> createdAtBetween(
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

  QueryBuilder<CollectionShareModel, CollectionShareModel,
      QAfterFilterCondition> expiresAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'expiresAt',
      ));
    });
  }

  QueryBuilder<CollectionShareModel, CollectionShareModel,
      QAfterFilterCondition> expiresAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'expiresAt',
      ));
    });
  }

  QueryBuilder<CollectionShareModel, CollectionShareModel,
      QAfterFilterCondition> expiresAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'expiresAt',
        value: value,
      ));
    });
  }

  QueryBuilder<CollectionShareModel, CollectionShareModel,
      QAfterFilterCondition> expiresAtGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'expiresAt',
        value: value,
      ));
    });
  }

  QueryBuilder<CollectionShareModel, CollectionShareModel,
      QAfterFilterCondition> expiresAtLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'expiresAt',
        value: value,
      ));
    });
  }

  QueryBuilder<CollectionShareModel, CollectionShareModel,
      QAfterFilterCondition> expiresAtBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'expiresAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<CollectionShareModel, CollectionShareModel,
      QAfterFilterCondition> idEqualTo(
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

  QueryBuilder<CollectionShareModel, CollectionShareModel,
      QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<CollectionShareModel, CollectionShareModel,
      QAfterFilterCondition> idLessThan(
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

  QueryBuilder<CollectionShareModel, CollectionShareModel,
      QAfterFilterCondition> idBetween(
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

  QueryBuilder<CollectionShareModel, CollectionShareModel,
      QAfterFilterCondition> idStartsWith(
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

  QueryBuilder<CollectionShareModel, CollectionShareModel,
      QAfterFilterCondition> idEndsWith(
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

  QueryBuilder<CollectionShareModel, CollectionShareModel,
          QAfterFilterCondition>
      idContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'id',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CollectionShareModel, CollectionShareModel,
          QAfterFilterCondition>
      idMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'id',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CollectionShareModel, CollectionShareModel,
      QAfterFilterCondition> idIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: '',
      ));
    });
  }

  QueryBuilder<CollectionShareModel, CollectionShareModel,
      QAfterFilterCondition> idIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'id',
        value: '',
      ));
    });
  }

  QueryBuilder<CollectionShareModel, CollectionShareModel,
      QAfterFilterCondition> invitationTokenEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'invitationToken',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CollectionShareModel, CollectionShareModel,
      QAfterFilterCondition> invitationTokenGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'invitationToken',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CollectionShareModel, CollectionShareModel,
      QAfterFilterCondition> invitationTokenLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'invitationToken',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CollectionShareModel, CollectionShareModel,
      QAfterFilterCondition> invitationTokenBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'invitationToken',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CollectionShareModel, CollectionShareModel,
      QAfterFilterCondition> invitationTokenStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'invitationToken',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CollectionShareModel, CollectionShareModel,
      QAfterFilterCondition> invitationTokenEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'invitationToken',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CollectionShareModel, CollectionShareModel,
          QAfterFilterCondition>
      invitationTokenContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'invitationToken',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CollectionShareModel, CollectionShareModel,
          QAfterFilterCondition>
      invitationTokenMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'invitationToken',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CollectionShareModel, CollectionShareModel,
      QAfterFilterCondition> invitationTokenIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'invitationToken',
        value: '',
      ));
    });
  }

  QueryBuilder<CollectionShareModel, CollectionShareModel,
      QAfterFilterCondition> invitationTokenIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'invitationToken',
        value: '',
      ));
    });
  }

  QueryBuilder<CollectionShareModel, CollectionShareModel,
      QAfterFilterCondition> isarIdEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isarId',
        value: value,
      ));
    });
  }

  QueryBuilder<CollectionShareModel, CollectionShareModel,
      QAfterFilterCondition> isarIdGreaterThan(
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

  QueryBuilder<CollectionShareModel, CollectionShareModel,
      QAfterFilterCondition> isarIdLessThan(
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

  QueryBuilder<CollectionShareModel, CollectionShareModel,
      QAfterFilterCondition> isarIdBetween(
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

  QueryBuilder<CollectionShareModel, CollectionShareModel,
      QAfterFilterCondition> permissionLevelEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'permissionLevel',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CollectionShareModel, CollectionShareModel,
      QAfterFilterCondition> permissionLevelGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'permissionLevel',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CollectionShareModel, CollectionShareModel,
      QAfterFilterCondition> permissionLevelLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'permissionLevel',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CollectionShareModel, CollectionShareModel,
      QAfterFilterCondition> permissionLevelBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'permissionLevel',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CollectionShareModel, CollectionShareModel,
      QAfterFilterCondition> permissionLevelStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'permissionLevel',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CollectionShareModel, CollectionShareModel,
      QAfterFilterCondition> permissionLevelEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'permissionLevel',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CollectionShareModel, CollectionShareModel,
          QAfterFilterCondition>
      permissionLevelContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'permissionLevel',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CollectionShareModel, CollectionShareModel,
          QAfterFilterCondition>
      permissionLevelMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'permissionLevel',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CollectionShareModel, CollectionShareModel,
      QAfterFilterCondition> permissionLevelIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'permissionLevel',
        value: '',
      ));
    });
  }

  QueryBuilder<CollectionShareModel, CollectionShareModel,
      QAfterFilterCondition> permissionLevelIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'permissionLevel',
        value: '',
      ));
    });
  }

  QueryBuilder<CollectionShareModel, CollectionShareModel,
      QAfterFilterCondition> sharedByUserIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'sharedByUserId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CollectionShareModel, CollectionShareModel,
      QAfterFilterCondition> sharedByUserIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'sharedByUserId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CollectionShareModel, CollectionShareModel,
      QAfterFilterCondition> sharedByUserIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'sharedByUserId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CollectionShareModel, CollectionShareModel,
      QAfterFilterCondition> sharedByUserIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'sharedByUserId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CollectionShareModel, CollectionShareModel,
      QAfterFilterCondition> sharedByUserIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'sharedByUserId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CollectionShareModel, CollectionShareModel,
      QAfterFilterCondition> sharedByUserIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'sharedByUserId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CollectionShareModel, CollectionShareModel,
          QAfterFilterCondition>
      sharedByUserIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'sharedByUserId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CollectionShareModel, CollectionShareModel,
          QAfterFilterCondition>
      sharedByUserIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'sharedByUserId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CollectionShareModel, CollectionShareModel,
      QAfterFilterCondition> sharedByUserIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'sharedByUserId',
        value: '',
      ));
    });
  }

  QueryBuilder<CollectionShareModel, CollectionShareModel,
      QAfterFilterCondition> sharedByUserIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'sharedByUserId',
        value: '',
      ));
    });
  }

  QueryBuilder<CollectionShareModel, CollectionShareModel,
      QAfterFilterCondition> sharedWithEmailIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'sharedWithEmail',
      ));
    });
  }

  QueryBuilder<CollectionShareModel, CollectionShareModel,
      QAfterFilterCondition> sharedWithEmailIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'sharedWithEmail',
      ));
    });
  }

  QueryBuilder<CollectionShareModel, CollectionShareModel,
      QAfterFilterCondition> sharedWithEmailEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'sharedWithEmail',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CollectionShareModel, CollectionShareModel,
      QAfterFilterCondition> sharedWithEmailGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'sharedWithEmail',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CollectionShareModel, CollectionShareModel,
      QAfterFilterCondition> sharedWithEmailLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'sharedWithEmail',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CollectionShareModel, CollectionShareModel,
      QAfterFilterCondition> sharedWithEmailBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'sharedWithEmail',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CollectionShareModel, CollectionShareModel,
      QAfterFilterCondition> sharedWithEmailStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'sharedWithEmail',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CollectionShareModel, CollectionShareModel,
      QAfterFilterCondition> sharedWithEmailEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'sharedWithEmail',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CollectionShareModel, CollectionShareModel,
          QAfterFilterCondition>
      sharedWithEmailContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'sharedWithEmail',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CollectionShareModel, CollectionShareModel,
          QAfterFilterCondition>
      sharedWithEmailMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'sharedWithEmail',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CollectionShareModel, CollectionShareModel,
      QAfterFilterCondition> sharedWithEmailIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'sharedWithEmail',
        value: '',
      ));
    });
  }

  QueryBuilder<CollectionShareModel, CollectionShareModel,
      QAfterFilterCondition> sharedWithEmailIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'sharedWithEmail',
        value: '',
      ));
    });
  }

  QueryBuilder<CollectionShareModel, CollectionShareModel,
      QAfterFilterCondition> sharedWithUserIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'sharedWithUserId',
      ));
    });
  }

  QueryBuilder<CollectionShareModel, CollectionShareModel,
      QAfterFilterCondition> sharedWithUserIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'sharedWithUserId',
      ));
    });
  }

  QueryBuilder<CollectionShareModel, CollectionShareModel,
      QAfterFilterCondition> sharedWithUserIdEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'sharedWithUserId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CollectionShareModel, CollectionShareModel,
      QAfterFilterCondition> sharedWithUserIdGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'sharedWithUserId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CollectionShareModel, CollectionShareModel,
      QAfterFilterCondition> sharedWithUserIdLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'sharedWithUserId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CollectionShareModel, CollectionShareModel,
      QAfterFilterCondition> sharedWithUserIdBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'sharedWithUserId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CollectionShareModel, CollectionShareModel,
      QAfterFilterCondition> sharedWithUserIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'sharedWithUserId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CollectionShareModel, CollectionShareModel,
      QAfterFilterCondition> sharedWithUserIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'sharedWithUserId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CollectionShareModel, CollectionShareModel,
          QAfterFilterCondition>
      sharedWithUserIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'sharedWithUserId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CollectionShareModel, CollectionShareModel,
          QAfterFilterCondition>
      sharedWithUserIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'sharedWithUserId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CollectionShareModel, CollectionShareModel,
      QAfterFilterCondition> sharedWithUserIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'sharedWithUserId',
        value: '',
      ));
    });
  }

  QueryBuilder<CollectionShareModel, CollectionShareModel,
      QAfterFilterCondition> sharedWithUserIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'sharedWithUserId',
        value: '',
      ));
    });
  }

  QueryBuilder<CollectionShareModel, CollectionShareModel,
      QAfterFilterCondition> statusEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'status',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CollectionShareModel, CollectionShareModel,
      QAfterFilterCondition> statusGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'status',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CollectionShareModel, CollectionShareModel,
      QAfterFilterCondition> statusLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'status',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CollectionShareModel, CollectionShareModel,
      QAfterFilterCondition> statusBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'status',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CollectionShareModel, CollectionShareModel,
      QAfterFilterCondition> statusStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'status',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CollectionShareModel, CollectionShareModel,
      QAfterFilterCondition> statusEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'status',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CollectionShareModel, CollectionShareModel,
          QAfterFilterCondition>
      statusContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'status',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CollectionShareModel, CollectionShareModel,
          QAfterFilterCondition>
      statusMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'status',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CollectionShareModel, CollectionShareModel,
      QAfterFilterCondition> statusIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'status',
        value: '',
      ));
    });
  }

  QueryBuilder<CollectionShareModel, CollectionShareModel,
      QAfterFilterCondition> statusIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'status',
        value: '',
      ));
    });
  }
}

extension CollectionShareModelQueryObject on QueryBuilder<CollectionShareModel,
    CollectionShareModel, QFilterCondition> {}

extension CollectionShareModelQueryLinks on QueryBuilder<CollectionShareModel,
    CollectionShareModel, QFilterCondition> {}

extension CollectionShareModelQuerySortBy
    on QueryBuilder<CollectionShareModel, CollectionShareModel, QSortBy> {
  QueryBuilder<CollectionShareModel, CollectionShareModel, QAfterSortBy>
      sortByAcceptedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'acceptedAt', Sort.asc);
    });
  }

  QueryBuilder<CollectionShareModel, CollectionShareModel, QAfterSortBy>
      sortByAcceptedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'acceptedAt', Sort.desc);
    });
  }

  QueryBuilder<CollectionShareModel, CollectionShareModel, QAfterSortBy>
      sortByCanReshare() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'canReshare', Sort.asc);
    });
  }

  QueryBuilder<CollectionShareModel, CollectionShareModel, QAfterSortBy>
      sortByCanReshareDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'canReshare', Sort.desc);
    });
  }

  QueryBuilder<CollectionShareModel, CollectionShareModel, QAfterSortBy>
      sortByCollectionId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'collectionId', Sort.asc);
    });
  }

  QueryBuilder<CollectionShareModel, CollectionShareModel, QAfterSortBy>
      sortByCollectionIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'collectionId', Sort.desc);
    });
  }

  QueryBuilder<CollectionShareModel, CollectionShareModel, QAfterSortBy>
      sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<CollectionShareModel, CollectionShareModel, QAfterSortBy>
      sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<CollectionShareModel, CollectionShareModel, QAfterSortBy>
      sortByExpiresAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'expiresAt', Sort.asc);
    });
  }

  QueryBuilder<CollectionShareModel, CollectionShareModel, QAfterSortBy>
      sortByExpiresAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'expiresAt', Sort.desc);
    });
  }

  QueryBuilder<CollectionShareModel, CollectionShareModel, QAfterSortBy>
      sortById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<CollectionShareModel, CollectionShareModel, QAfterSortBy>
      sortByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<CollectionShareModel, CollectionShareModel, QAfterSortBy>
      sortByInvitationToken() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'invitationToken', Sort.asc);
    });
  }

  QueryBuilder<CollectionShareModel, CollectionShareModel, QAfterSortBy>
      sortByInvitationTokenDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'invitationToken', Sort.desc);
    });
  }

  QueryBuilder<CollectionShareModel, CollectionShareModel, QAfterSortBy>
      sortByPermissionLevel() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'permissionLevel', Sort.asc);
    });
  }

  QueryBuilder<CollectionShareModel, CollectionShareModel, QAfterSortBy>
      sortByPermissionLevelDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'permissionLevel', Sort.desc);
    });
  }

  QueryBuilder<CollectionShareModel, CollectionShareModel, QAfterSortBy>
      sortBySharedByUserId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sharedByUserId', Sort.asc);
    });
  }

  QueryBuilder<CollectionShareModel, CollectionShareModel, QAfterSortBy>
      sortBySharedByUserIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sharedByUserId', Sort.desc);
    });
  }

  QueryBuilder<CollectionShareModel, CollectionShareModel, QAfterSortBy>
      sortBySharedWithEmail() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sharedWithEmail', Sort.asc);
    });
  }

  QueryBuilder<CollectionShareModel, CollectionShareModel, QAfterSortBy>
      sortBySharedWithEmailDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sharedWithEmail', Sort.desc);
    });
  }

  QueryBuilder<CollectionShareModel, CollectionShareModel, QAfterSortBy>
      sortBySharedWithUserId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sharedWithUserId', Sort.asc);
    });
  }

  QueryBuilder<CollectionShareModel, CollectionShareModel, QAfterSortBy>
      sortBySharedWithUserIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sharedWithUserId', Sort.desc);
    });
  }

  QueryBuilder<CollectionShareModel, CollectionShareModel, QAfterSortBy>
      sortByStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.asc);
    });
  }

  QueryBuilder<CollectionShareModel, CollectionShareModel, QAfterSortBy>
      sortByStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.desc);
    });
  }
}

extension CollectionShareModelQuerySortThenBy
    on QueryBuilder<CollectionShareModel, CollectionShareModel, QSortThenBy> {
  QueryBuilder<CollectionShareModel, CollectionShareModel, QAfterSortBy>
      thenByAcceptedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'acceptedAt', Sort.asc);
    });
  }

  QueryBuilder<CollectionShareModel, CollectionShareModel, QAfterSortBy>
      thenByAcceptedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'acceptedAt', Sort.desc);
    });
  }

  QueryBuilder<CollectionShareModel, CollectionShareModel, QAfterSortBy>
      thenByCanReshare() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'canReshare', Sort.asc);
    });
  }

  QueryBuilder<CollectionShareModel, CollectionShareModel, QAfterSortBy>
      thenByCanReshareDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'canReshare', Sort.desc);
    });
  }

  QueryBuilder<CollectionShareModel, CollectionShareModel, QAfterSortBy>
      thenByCollectionId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'collectionId', Sort.asc);
    });
  }

  QueryBuilder<CollectionShareModel, CollectionShareModel, QAfterSortBy>
      thenByCollectionIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'collectionId', Sort.desc);
    });
  }

  QueryBuilder<CollectionShareModel, CollectionShareModel, QAfterSortBy>
      thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<CollectionShareModel, CollectionShareModel, QAfterSortBy>
      thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<CollectionShareModel, CollectionShareModel, QAfterSortBy>
      thenByExpiresAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'expiresAt', Sort.asc);
    });
  }

  QueryBuilder<CollectionShareModel, CollectionShareModel, QAfterSortBy>
      thenByExpiresAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'expiresAt', Sort.desc);
    });
  }

  QueryBuilder<CollectionShareModel, CollectionShareModel, QAfterSortBy>
      thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<CollectionShareModel, CollectionShareModel, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<CollectionShareModel, CollectionShareModel, QAfterSortBy>
      thenByInvitationToken() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'invitationToken', Sort.asc);
    });
  }

  QueryBuilder<CollectionShareModel, CollectionShareModel, QAfterSortBy>
      thenByInvitationTokenDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'invitationToken', Sort.desc);
    });
  }

  QueryBuilder<CollectionShareModel, CollectionShareModel, QAfterSortBy>
      thenByIsarId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isarId', Sort.asc);
    });
  }

  QueryBuilder<CollectionShareModel, CollectionShareModel, QAfterSortBy>
      thenByIsarIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isarId', Sort.desc);
    });
  }

  QueryBuilder<CollectionShareModel, CollectionShareModel, QAfterSortBy>
      thenByPermissionLevel() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'permissionLevel', Sort.asc);
    });
  }

  QueryBuilder<CollectionShareModel, CollectionShareModel, QAfterSortBy>
      thenByPermissionLevelDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'permissionLevel', Sort.desc);
    });
  }

  QueryBuilder<CollectionShareModel, CollectionShareModel, QAfterSortBy>
      thenBySharedByUserId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sharedByUserId', Sort.asc);
    });
  }

  QueryBuilder<CollectionShareModel, CollectionShareModel, QAfterSortBy>
      thenBySharedByUserIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sharedByUserId', Sort.desc);
    });
  }

  QueryBuilder<CollectionShareModel, CollectionShareModel, QAfterSortBy>
      thenBySharedWithEmail() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sharedWithEmail', Sort.asc);
    });
  }

  QueryBuilder<CollectionShareModel, CollectionShareModel, QAfterSortBy>
      thenBySharedWithEmailDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sharedWithEmail', Sort.desc);
    });
  }

  QueryBuilder<CollectionShareModel, CollectionShareModel, QAfterSortBy>
      thenBySharedWithUserId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sharedWithUserId', Sort.asc);
    });
  }

  QueryBuilder<CollectionShareModel, CollectionShareModel, QAfterSortBy>
      thenBySharedWithUserIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sharedWithUserId', Sort.desc);
    });
  }

  QueryBuilder<CollectionShareModel, CollectionShareModel, QAfterSortBy>
      thenByStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.asc);
    });
  }

  QueryBuilder<CollectionShareModel, CollectionShareModel, QAfterSortBy>
      thenByStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.desc);
    });
  }
}

extension CollectionShareModelQueryWhereDistinct
    on QueryBuilder<CollectionShareModel, CollectionShareModel, QDistinct> {
  QueryBuilder<CollectionShareModel, CollectionShareModel, QDistinct>
      distinctByAcceptedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'acceptedAt');
    });
  }

  QueryBuilder<CollectionShareModel, CollectionShareModel, QDistinct>
      distinctByCanReshare() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'canReshare');
    });
  }

  QueryBuilder<CollectionShareModel, CollectionShareModel, QDistinct>
      distinctByCollectionId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'collectionId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<CollectionShareModel, CollectionShareModel, QDistinct>
      distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdAt');
    });
  }

  QueryBuilder<CollectionShareModel, CollectionShareModel, QDistinct>
      distinctByExpiresAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'expiresAt');
    });
  }

  QueryBuilder<CollectionShareModel, CollectionShareModel, QDistinct>
      distinctById({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'id', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<CollectionShareModel, CollectionShareModel, QDistinct>
      distinctByInvitationToken({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'invitationToken',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<CollectionShareModel, CollectionShareModel, QDistinct>
      distinctByPermissionLevel({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'permissionLevel',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<CollectionShareModel, CollectionShareModel, QDistinct>
      distinctBySharedByUserId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'sharedByUserId',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<CollectionShareModel, CollectionShareModel, QDistinct>
      distinctBySharedWithEmail({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'sharedWithEmail',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<CollectionShareModel, CollectionShareModel, QDistinct>
      distinctBySharedWithUserId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'sharedWithUserId',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<CollectionShareModel, CollectionShareModel, QDistinct>
      distinctByStatus({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'status', caseSensitive: caseSensitive);
    });
  }
}

extension CollectionShareModelQueryProperty on QueryBuilder<
    CollectionShareModel, CollectionShareModel, QQueryProperty> {
  QueryBuilder<CollectionShareModel, int, QQueryOperations> isarIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isarId');
    });
  }

  QueryBuilder<CollectionShareModel, DateTime?, QQueryOperations>
      acceptedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'acceptedAt');
    });
  }

  QueryBuilder<CollectionShareModel, bool, QQueryOperations>
      canReshareProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'canReshare');
    });
  }

  QueryBuilder<CollectionShareModel, String, QQueryOperations>
      collectionIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'collectionId');
    });
  }

  QueryBuilder<CollectionShareModel, DateTime, QQueryOperations>
      createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdAt');
    });
  }

  QueryBuilder<CollectionShareModel, DateTime?, QQueryOperations>
      expiresAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'expiresAt');
    });
  }

  QueryBuilder<CollectionShareModel, String, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<CollectionShareModel, String, QQueryOperations>
      invitationTokenProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'invitationToken');
    });
  }

  QueryBuilder<CollectionShareModel, String, QQueryOperations>
      permissionLevelProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'permissionLevel');
    });
  }

  QueryBuilder<CollectionShareModel, String, QQueryOperations>
      sharedByUserIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'sharedByUserId');
    });
  }

  QueryBuilder<CollectionShareModel, String?, QQueryOperations>
      sharedWithEmailProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'sharedWithEmail');
    });
  }

  QueryBuilder<CollectionShareModel, String?, QQueryOperations>
      sharedWithUserIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'sharedWithUserId');
    });
  }

  QueryBuilder<CollectionShareModel, String, QQueryOperations>
      statusProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'status');
    });
  }
}
