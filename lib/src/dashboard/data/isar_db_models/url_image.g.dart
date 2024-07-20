// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'url_image.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetUrlImageCollection on Isar {
  IsarCollection<UrlImage> get urlImages => this.collection();
}

const UrlImageSchema = CollectionSchema(
  name: r'UrlImage',
  id: -7543795334065980052,
  properties: {
    r'base64ImageBytes': PropertySchema(
      id: 0,
      name: r'base64ImageBytes',
      type: IsarType.string,
    ),
    r'imageUrl': PropertySchema(
      id: 1,
      name: r'imageUrl',
      type: IsarType.string,
    )
  },
  estimateSize: _urlImageEstimateSize,
  serialize: _urlImageSerialize,
  deserialize: _urlImageDeserialize,
  deserializeProp: _urlImageDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {},
  getId: _urlImageGetId,
  getLinks: _urlImageGetLinks,
  attach: _urlImageAttach,
  version: '3.1.0+1',
);

int _urlImageEstimateSize(
  UrlImage object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.base64ImageBytes.length * 3;
  bytesCount += 3 + object.imageUrl.length * 3;
  return bytesCount;
}

void _urlImageSerialize(
  UrlImage object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.base64ImageBytes);
  writer.writeString(offsets[1], object.imageUrl);
}

UrlImage _urlImageDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = UrlImage(
    base64ImageBytes: reader.readString(offsets[0]),
    imageUrl: reader.readString(offsets[1]),
  );
  object.id = id;
  return object;
}

P _urlImageDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readString(offset)) as P;
    case 1:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _urlImageGetId(UrlImage object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _urlImageGetLinks(UrlImage object) {
  return [];
}

void _urlImageAttach(IsarCollection<dynamic> col, Id id, UrlImage object) {
  object.id = id;
}

extension UrlImageQueryWhereSort on QueryBuilder<UrlImage, UrlImage, QWhere> {
  QueryBuilder<UrlImage, UrlImage, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension UrlImageQueryWhere on QueryBuilder<UrlImage, UrlImage, QWhereClause> {
  QueryBuilder<UrlImage, UrlImage, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<UrlImage, UrlImage, QAfterWhereClause> idNotEqualTo(Id id) {
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

  QueryBuilder<UrlImage, UrlImage, QAfterWhereClause> idGreaterThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<UrlImage, UrlImage, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<UrlImage, UrlImage, QAfterWhereClause> idBetween(
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
}

extension UrlImageQueryFilter
    on QueryBuilder<UrlImage, UrlImage, QFilterCondition> {
  QueryBuilder<UrlImage, UrlImage, QAfterFilterCondition>
      base64ImageBytesEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'base64ImageBytes',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UrlImage, UrlImage, QAfterFilterCondition>
      base64ImageBytesGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'base64ImageBytes',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UrlImage, UrlImage, QAfterFilterCondition>
      base64ImageBytesLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'base64ImageBytes',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UrlImage, UrlImage, QAfterFilterCondition>
      base64ImageBytesBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'base64ImageBytes',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UrlImage, UrlImage, QAfterFilterCondition>
      base64ImageBytesStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'base64ImageBytes',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UrlImage, UrlImage, QAfterFilterCondition>
      base64ImageBytesEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'base64ImageBytes',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UrlImage, UrlImage, QAfterFilterCondition>
      base64ImageBytesContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'base64ImageBytes',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UrlImage, UrlImage, QAfterFilterCondition>
      base64ImageBytesMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'base64ImageBytes',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UrlImage, UrlImage, QAfterFilterCondition>
      base64ImageBytesIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'base64ImageBytes',
        value: '',
      ));
    });
  }

  QueryBuilder<UrlImage, UrlImage, QAfterFilterCondition>
      base64ImageBytesIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'base64ImageBytes',
        value: '',
      ));
    });
  }

  QueryBuilder<UrlImage, UrlImage, QAfterFilterCondition> idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<UrlImage, UrlImage, QAfterFilterCondition> idGreaterThan(
    Id value, {
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

  QueryBuilder<UrlImage, UrlImage, QAfterFilterCondition> idLessThan(
    Id value, {
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

  QueryBuilder<UrlImage, UrlImage, QAfterFilterCondition> idBetween(
    Id lower,
    Id upper, {
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

  QueryBuilder<UrlImage, UrlImage, QAfterFilterCondition> imageUrlEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'imageUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UrlImage, UrlImage, QAfterFilterCondition> imageUrlGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'imageUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UrlImage, UrlImage, QAfterFilterCondition> imageUrlLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'imageUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UrlImage, UrlImage, QAfterFilterCondition> imageUrlBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'imageUrl',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UrlImage, UrlImage, QAfterFilterCondition> imageUrlStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'imageUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UrlImage, UrlImage, QAfterFilterCondition> imageUrlEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'imageUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UrlImage, UrlImage, QAfterFilterCondition> imageUrlContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'imageUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UrlImage, UrlImage, QAfterFilterCondition> imageUrlMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'imageUrl',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UrlImage, UrlImage, QAfterFilterCondition> imageUrlIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'imageUrl',
        value: '',
      ));
    });
  }

  QueryBuilder<UrlImage, UrlImage, QAfterFilterCondition> imageUrlIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'imageUrl',
        value: '',
      ));
    });
  }
}

extension UrlImageQueryObject
    on QueryBuilder<UrlImage, UrlImage, QFilterCondition> {}

extension UrlImageQueryLinks
    on QueryBuilder<UrlImage, UrlImage, QFilterCondition> {}

extension UrlImageQuerySortBy on QueryBuilder<UrlImage, UrlImage, QSortBy> {
  QueryBuilder<UrlImage, UrlImage, QAfterSortBy> sortByBase64ImageBytes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'base64ImageBytes', Sort.asc);
    });
  }

  QueryBuilder<UrlImage, UrlImage, QAfterSortBy> sortByBase64ImageBytesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'base64ImageBytes', Sort.desc);
    });
  }

  QueryBuilder<UrlImage, UrlImage, QAfterSortBy> sortByImageUrl() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'imageUrl', Sort.asc);
    });
  }

  QueryBuilder<UrlImage, UrlImage, QAfterSortBy> sortByImageUrlDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'imageUrl', Sort.desc);
    });
  }
}

extension UrlImageQuerySortThenBy
    on QueryBuilder<UrlImage, UrlImage, QSortThenBy> {
  QueryBuilder<UrlImage, UrlImage, QAfterSortBy> thenByBase64ImageBytes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'base64ImageBytes', Sort.asc);
    });
  }

  QueryBuilder<UrlImage, UrlImage, QAfterSortBy> thenByBase64ImageBytesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'base64ImageBytes', Sort.desc);
    });
  }

  QueryBuilder<UrlImage, UrlImage, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<UrlImage, UrlImage, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<UrlImage, UrlImage, QAfterSortBy> thenByImageUrl() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'imageUrl', Sort.asc);
    });
  }

  QueryBuilder<UrlImage, UrlImage, QAfterSortBy> thenByImageUrlDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'imageUrl', Sort.desc);
    });
  }
}

extension UrlImageQueryWhereDistinct
    on QueryBuilder<UrlImage, UrlImage, QDistinct> {
  QueryBuilder<UrlImage, UrlImage, QDistinct> distinctByBase64ImageBytes(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'base64ImageBytes',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<UrlImage, UrlImage, QDistinct> distinctByImageUrl(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'imageUrl', caseSensitive: caseSensitive);
    });
  }
}

extension UrlImageQueryProperty
    on QueryBuilder<UrlImage, UrlImage, QQueryProperty> {
  QueryBuilder<UrlImage, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<UrlImage, String, QQueryOperations> base64ImageBytesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'base64ImageBytes');
    });
  }

  QueryBuilder<UrlImage, String, QQueryOperations> imageUrlProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'imageUrl');
    });
  }
}
