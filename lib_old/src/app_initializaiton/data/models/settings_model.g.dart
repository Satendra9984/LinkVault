// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settings_model.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetIsarAppSettingsModelCollection on Isar {
  IsarCollection<IsarAppSettingsModel> get isarAppSettingsModels =>
      this.collection();
}

const IsarAppSettingsModelSchema = CollectionSchema(
  name: r'IsarAppSettingsModel',
  id: -2963969059272788992,
  properties: {
    r'seenOnboarding': PropertySchema(
      id: 0,
      name: r'seenOnboarding',
      type: IsarType.bool,
    ),
    r'theme': PropertySchema(
      id: 1,
      name: r'theme',
      type: IsarType.string,
    )
  },
  estimateSize: _isarAppSettingsModelEstimateSize,
  serialize: _isarAppSettingsModelSerialize,
  deserialize: _isarAppSettingsModelDeserialize,
  deserializeProp: _isarAppSettingsModelDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {},
  getId: _isarAppSettingsModelGetId,
  getLinks: _isarAppSettingsModelGetLinks,
  attach: _isarAppSettingsModelAttach,
  version: '3.1.0+1',
);

int _isarAppSettingsModelEstimateSize(
  IsarAppSettingsModel object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.theme;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  return bytesCount;
}

void _isarAppSettingsModelSerialize(
  IsarAppSettingsModel object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeBool(offsets[0], object.seenOnboarding);
  writer.writeString(offsets[1], object.theme);
}

IsarAppSettingsModel _isarAppSettingsModelDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = IsarAppSettingsModel(
    seenOnboarding: reader.readBoolOrNull(offsets[0]) ?? false,
    theme: reader.readStringOrNull(offsets[1]),
  );
  object.id = id;
  return object;
}

P _isarAppSettingsModelDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readBoolOrNull(offset) ?? false) as P;
    case 1:
      return (reader.readStringOrNull(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _isarAppSettingsModelGetId(IsarAppSettingsModel object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _isarAppSettingsModelGetLinks(
    IsarAppSettingsModel object) {
  return [];
}

void _isarAppSettingsModelAttach(
    IsarCollection<dynamic> col, Id id, IsarAppSettingsModel object) {
  object.id = id;
}

extension IsarAppSettingsModelQueryWhereSort
    on QueryBuilder<IsarAppSettingsModel, IsarAppSettingsModel, QWhere> {
  QueryBuilder<IsarAppSettingsModel, IsarAppSettingsModel, QAfterWhere>
      anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension IsarAppSettingsModelQueryWhere
    on QueryBuilder<IsarAppSettingsModel, IsarAppSettingsModel, QWhereClause> {
  QueryBuilder<IsarAppSettingsModel, IsarAppSettingsModel, QAfterWhereClause>
      idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<IsarAppSettingsModel, IsarAppSettingsModel, QAfterWhereClause>
      idNotEqualTo(Id id) {
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

  QueryBuilder<IsarAppSettingsModel, IsarAppSettingsModel, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<IsarAppSettingsModel, IsarAppSettingsModel, QAfterWhereClause>
      idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<IsarAppSettingsModel, IsarAppSettingsModel, QAfterWhereClause>
      idBetween(
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

extension IsarAppSettingsModelQueryFilter on QueryBuilder<IsarAppSettingsModel,
    IsarAppSettingsModel, QFilterCondition> {
  QueryBuilder<IsarAppSettingsModel, IsarAppSettingsModel,
      QAfterFilterCondition> idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarAppSettingsModel, IsarAppSettingsModel,
      QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<IsarAppSettingsModel, IsarAppSettingsModel,
      QAfterFilterCondition> idLessThan(
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

  QueryBuilder<IsarAppSettingsModel, IsarAppSettingsModel,
      QAfterFilterCondition> idBetween(
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

  QueryBuilder<IsarAppSettingsModel, IsarAppSettingsModel,
      QAfterFilterCondition> seenOnboardingEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'seenOnboarding',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarAppSettingsModel, IsarAppSettingsModel,
      QAfterFilterCondition> themeIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'theme',
      ));
    });
  }

  QueryBuilder<IsarAppSettingsModel, IsarAppSettingsModel,
      QAfterFilterCondition> themeIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'theme',
      ));
    });
  }

  QueryBuilder<IsarAppSettingsModel, IsarAppSettingsModel,
      QAfterFilterCondition> themeEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'theme',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAppSettingsModel, IsarAppSettingsModel,
      QAfterFilterCondition> themeGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'theme',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAppSettingsModel, IsarAppSettingsModel,
      QAfterFilterCondition> themeLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'theme',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAppSettingsModel, IsarAppSettingsModel,
      QAfterFilterCondition> themeBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'theme',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAppSettingsModel, IsarAppSettingsModel,
      QAfterFilterCondition> themeStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'theme',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAppSettingsModel, IsarAppSettingsModel,
      QAfterFilterCondition> themeEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'theme',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAppSettingsModel, IsarAppSettingsModel,
          QAfterFilterCondition>
      themeContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'theme',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAppSettingsModel, IsarAppSettingsModel,
          QAfterFilterCondition>
      themeMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'theme',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAppSettingsModel, IsarAppSettingsModel,
      QAfterFilterCondition> themeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'theme',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarAppSettingsModel, IsarAppSettingsModel,
      QAfterFilterCondition> themeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'theme',
        value: '',
      ));
    });
  }
}

extension IsarAppSettingsModelQueryObject on QueryBuilder<IsarAppSettingsModel,
    IsarAppSettingsModel, QFilterCondition> {}

extension IsarAppSettingsModelQueryLinks on QueryBuilder<IsarAppSettingsModel,
    IsarAppSettingsModel, QFilterCondition> {}

extension IsarAppSettingsModelQuerySortBy
    on QueryBuilder<IsarAppSettingsModel, IsarAppSettingsModel, QSortBy> {
  QueryBuilder<IsarAppSettingsModel, IsarAppSettingsModel, QAfterSortBy>
      sortBySeenOnboarding() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'seenOnboarding', Sort.asc);
    });
  }

  QueryBuilder<IsarAppSettingsModel, IsarAppSettingsModel, QAfterSortBy>
      sortBySeenOnboardingDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'seenOnboarding', Sort.desc);
    });
  }

  QueryBuilder<IsarAppSettingsModel, IsarAppSettingsModel, QAfterSortBy>
      sortByTheme() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'theme', Sort.asc);
    });
  }

  QueryBuilder<IsarAppSettingsModel, IsarAppSettingsModel, QAfterSortBy>
      sortByThemeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'theme', Sort.desc);
    });
  }
}

extension IsarAppSettingsModelQuerySortThenBy
    on QueryBuilder<IsarAppSettingsModel, IsarAppSettingsModel, QSortThenBy> {
  QueryBuilder<IsarAppSettingsModel, IsarAppSettingsModel, QAfterSortBy>
      thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<IsarAppSettingsModel, IsarAppSettingsModel, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<IsarAppSettingsModel, IsarAppSettingsModel, QAfterSortBy>
      thenBySeenOnboarding() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'seenOnboarding', Sort.asc);
    });
  }

  QueryBuilder<IsarAppSettingsModel, IsarAppSettingsModel, QAfterSortBy>
      thenBySeenOnboardingDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'seenOnboarding', Sort.desc);
    });
  }

  QueryBuilder<IsarAppSettingsModel, IsarAppSettingsModel, QAfterSortBy>
      thenByTheme() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'theme', Sort.asc);
    });
  }

  QueryBuilder<IsarAppSettingsModel, IsarAppSettingsModel, QAfterSortBy>
      thenByThemeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'theme', Sort.desc);
    });
  }
}

extension IsarAppSettingsModelQueryWhereDistinct
    on QueryBuilder<IsarAppSettingsModel, IsarAppSettingsModel, QDistinct> {
  QueryBuilder<IsarAppSettingsModel, IsarAppSettingsModel, QDistinct>
      distinctBySeenOnboarding() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'seenOnboarding');
    });
  }

  QueryBuilder<IsarAppSettingsModel, IsarAppSettingsModel, QDistinct>
      distinctByTheme({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'theme', caseSensitive: caseSensitive);
    });
  }
}

extension IsarAppSettingsModelQueryProperty on QueryBuilder<
    IsarAppSettingsModel, IsarAppSettingsModel, QQueryProperty> {
  QueryBuilder<IsarAppSettingsModel, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<IsarAppSettingsModel, bool, QQueryOperations>
      seenOnboardingProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'seenOnboarding');
    });
  }

  QueryBuilder<IsarAppSettingsModel, String?, QQueryOperations>
      themeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'theme');
    });
  }
}
