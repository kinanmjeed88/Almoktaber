// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'maintenance_log.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetMaintenanceLogCollection on Isar {
  IsarCollection<MaintenanceLog> get maintenanceLogs => this.collection();
}

const MaintenanceLogSchema = CollectionSchema(
  name: r'MaintenanceLog',
  id: 2311724503968887616,
  properties: {
    r'fault': PropertySchema(
      id: 0,
      name: r'fault',
      type: IsarType.string,
    ),
    r'maintenanceDate': PropertySchema(
      id: 1,
      name: r'maintenanceDate',
      type: IsarType.dateTime,
    ),
    r'solution': PropertySchema(
      id: 2,
      name: r'solution',
      type: IsarType.string,
    )
  },
  estimateSize: _maintenanceLogEstimateSize,
  serialize: _maintenanceLogSerialize,
  deserialize: _maintenanceLogDeserialize,
  deserializeProp: _maintenanceLogDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {
    r'device': LinkSchema(
      id: -753380273260056967,
      name: r'device',
      target: r'Device',
      single: true,
    )
  },
  embeddedSchemas: {},
  getId: _maintenanceLogGetId,
  getLinks: _maintenanceLogGetLinks,
  attach: _maintenanceLogAttach,
  version: '3.1.0+1',
);

int _maintenanceLogEstimateSize(
  MaintenanceLog object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.fault.length * 3;
  bytesCount += 3 + object.solution.length * 3;
  return bytesCount;
}

void _maintenanceLogSerialize(
  MaintenanceLog object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.fault);
  writer.writeDateTime(offsets[1], object.maintenanceDate);
  writer.writeString(offsets[2], object.solution);
}

MaintenanceLog _maintenanceLogDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = MaintenanceLog(
    fault: reader.readString(offsets[0]),
    maintenanceDate: reader.readDateTime(offsets[1]),
    solution: reader.readString(offsets[2]),
  );
  object.id = id;
  return object;
}

P _maintenanceLogDeserializeProp<P>(
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
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _maintenanceLogGetId(MaintenanceLog object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _maintenanceLogGetLinks(MaintenanceLog object) {
  return [object.device];
}

void _maintenanceLogAttach(
    IsarCollection<dynamic> col, Id id, MaintenanceLog object) {
  object.id = id;
  object.device.attach(col, col.isar.collection<Device>(), r'device', id);
}

extension MaintenanceLogQueryWhereSort
    on QueryBuilder<MaintenanceLog, MaintenanceLog, QWhere> {
  QueryBuilder<MaintenanceLog, MaintenanceLog, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension MaintenanceLogQueryWhere
    on QueryBuilder<MaintenanceLog, MaintenanceLog, QWhereClause> {
  QueryBuilder<MaintenanceLog, MaintenanceLog, QAfterWhereClause> idEqualTo(
      Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<MaintenanceLog, MaintenanceLog, QAfterWhereClause> idNotEqualTo(
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

  QueryBuilder<MaintenanceLog, MaintenanceLog, QAfterWhereClause> idGreaterThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<MaintenanceLog, MaintenanceLog, QAfterWhereClause> idLessThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<MaintenanceLog, MaintenanceLog, QAfterWhereClause> idBetween(
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

extension MaintenanceLogQueryFilter
    on QueryBuilder<MaintenanceLog, MaintenanceLog, QFilterCondition> {
  QueryBuilder<MaintenanceLog, MaintenanceLog, QAfterFilterCondition>
      faultEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'fault',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MaintenanceLog, MaintenanceLog, QAfterFilterCondition>
      faultGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'fault',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MaintenanceLog, MaintenanceLog, QAfterFilterCondition>
      faultLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'fault',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MaintenanceLog, MaintenanceLog, QAfterFilterCondition>
      faultBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'fault',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MaintenanceLog, MaintenanceLog, QAfterFilterCondition>
      faultStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'fault',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MaintenanceLog, MaintenanceLog, QAfterFilterCondition>
      faultEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'fault',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MaintenanceLog, MaintenanceLog, QAfterFilterCondition>
      faultContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'fault',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MaintenanceLog, MaintenanceLog, QAfterFilterCondition>
      faultMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'fault',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MaintenanceLog, MaintenanceLog, QAfterFilterCondition>
      faultIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'fault',
        value: '',
      ));
    });
  }

  QueryBuilder<MaintenanceLog, MaintenanceLog, QAfterFilterCondition>
      faultIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'fault',
        value: '',
      ));
    });
  }

  QueryBuilder<MaintenanceLog, MaintenanceLog, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<MaintenanceLog, MaintenanceLog, QAfterFilterCondition>
      idGreaterThan(
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

  QueryBuilder<MaintenanceLog, MaintenanceLog, QAfterFilterCondition>
      idLessThan(
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

  QueryBuilder<MaintenanceLog, MaintenanceLog, QAfterFilterCondition> idBetween(
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

  QueryBuilder<MaintenanceLog, MaintenanceLog, QAfterFilterCondition>
      maintenanceDateEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'maintenanceDate',
        value: value,
      ));
    });
  }

  QueryBuilder<MaintenanceLog, MaintenanceLog, QAfterFilterCondition>
      maintenanceDateGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'maintenanceDate',
        value: value,
      ));
    });
  }

  QueryBuilder<MaintenanceLog, MaintenanceLog, QAfterFilterCondition>
      maintenanceDateLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'maintenanceDate',
        value: value,
      ));
    });
  }

  QueryBuilder<MaintenanceLog, MaintenanceLog, QAfterFilterCondition>
      maintenanceDateBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'maintenanceDate',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<MaintenanceLog, MaintenanceLog, QAfterFilterCondition>
      solutionEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'solution',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MaintenanceLog, MaintenanceLog, QAfterFilterCondition>
      solutionGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'solution',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MaintenanceLog, MaintenanceLog, QAfterFilterCondition>
      solutionLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'solution',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MaintenanceLog, MaintenanceLog, QAfterFilterCondition>
      solutionBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'solution',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MaintenanceLog, MaintenanceLog, QAfterFilterCondition>
      solutionStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'solution',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MaintenanceLog, MaintenanceLog, QAfterFilterCondition>
      solutionEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'solution',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MaintenanceLog, MaintenanceLog, QAfterFilterCondition>
      solutionContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'solution',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MaintenanceLog, MaintenanceLog, QAfterFilterCondition>
      solutionMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'solution',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MaintenanceLog, MaintenanceLog, QAfterFilterCondition>
      solutionIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'solution',
        value: '',
      ));
    });
  }

  QueryBuilder<MaintenanceLog, MaintenanceLog, QAfterFilterCondition>
      solutionIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'solution',
        value: '',
      ));
    });
  }
}

extension MaintenanceLogQueryObject
    on QueryBuilder<MaintenanceLog, MaintenanceLog, QFilterCondition> {}

extension MaintenanceLogQueryLinks
    on QueryBuilder<MaintenanceLog, MaintenanceLog, QFilterCondition> {
  QueryBuilder<MaintenanceLog, MaintenanceLog, QAfterFilterCondition> device(
      FilterQuery<Device> q) {
    return QueryBuilder.apply(this, (query) {
      return query.link(q, r'device');
    });
  }

  QueryBuilder<MaintenanceLog, MaintenanceLog, QAfterFilterCondition>
      deviceIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'device', 0, true, 0, true);
    });
  }
}

extension MaintenanceLogQuerySortBy
    on QueryBuilder<MaintenanceLog, MaintenanceLog, QSortBy> {
  QueryBuilder<MaintenanceLog, MaintenanceLog, QAfterSortBy> sortByFault() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fault', Sort.asc);
    });
  }

  QueryBuilder<MaintenanceLog, MaintenanceLog, QAfterSortBy> sortByFaultDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fault', Sort.desc);
    });
  }

  QueryBuilder<MaintenanceLog, MaintenanceLog, QAfterSortBy>
      sortByMaintenanceDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'maintenanceDate', Sort.asc);
    });
  }

  QueryBuilder<MaintenanceLog, MaintenanceLog, QAfterSortBy>
      sortByMaintenanceDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'maintenanceDate', Sort.desc);
    });
  }

  QueryBuilder<MaintenanceLog, MaintenanceLog, QAfterSortBy> sortBySolution() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'solution', Sort.asc);
    });
  }

  QueryBuilder<MaintenanceLog, MaintenanceLog, QAfterSortBy>
      sortBySolutionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'solution', Sort.desc);
    });
  }
}

extension MaintenanceLogQuerySortThenBy
    on QueryBuilder<MaintenanceLog, MaintenanceLog, QSortThenBy> {
  QueryBuilder<MaintenanceLog, MaintenanceLog, QAfterSortBy> thenByFault() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fault', Sort.asc);
    });
  }

  QueryBuilder<MaintenanceLog, MaintenanceLog, QAfterSortBy> thenByFaultDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fault', Sort.desc);
    });
  }

  QueryBuilder<MaintenanceLog, MaintenanceLog, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<MaintenanceLog, MaintenanceLog, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<MaintenanceLog, MaintenanceLog, QAfterSortBy>
      thenByMaintenanceDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'maintenanceDate', Sort.asc);
    });
  }

  QueryBuilder<MaintenanceLog, MaintenanceLog, QAfterSortBy>
      thenByMaintenanceDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'maintenanceDate', Sort.desc);
    });
  }

  QueryBuilder<MaintenanceLog, MaintenanceLog, QAfterSortBy> thenBySolution() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'solution', Sort.asc);
    });
  }

  QueryBuilder<MaintenanceLog, MaintenanceLog, QAfterSortBy>
      thenBySolutionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'solution', Sort.desc);
    });
  }
}

extension MaintenanceLogQueryWhereDistinct
    on QueryBuilder<MaintenanceLog, MaintenanceLog, QDistinct> {
  QueryBuilder<MaintenanceLog, MaintenanceLog, QDistinct> distinctByFault(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'fault', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<MaintenanceLog, MaintenanceLog, QDistinct>
      distinctByMaintenanceDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'maintenanceDate');
    });
  }

  QueryBuilder<MaintenanceLog, MaintenanceLog, QDistinct> distinctBySolution(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'solution', caseSensitive: caseSensitive);
    });
  }
}

extension MaintenanceLogQueryProperty
    on QueryBuilder<MaintenanceLog, MaintenanceLog, QQueryProperty> {
  QueryBuilder<MaintenanceLog, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<MaintenanceLog, String, QQueryOperations> faultProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'fault');
    });
  }

  QueryBuilder<MaintenanceLog, DateTime, QQueryOperations>
      maintenanceDateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'maintenanceDate');
    });
  }

  QueryBuilder<MaintenanceLog, String, QQueryOperations> solutionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'solution');
    });
  }
}
