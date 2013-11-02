var QueryBuilder,
  __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

QueryBuilder = (function() {
  QueryBuilder.queryDetails = null;

  QueryBuilder.originalQuery = null;

  function QueryBuilder(originalQuery, queryDetails) {
    this.buildMasterNodeQuery = __bind(this.buildMasterNodeQuery, this);
    this.buildDataNodeQuery = __bind(this.buildDataNodeQuery, this);
    this.originalQuery = originalQuery;
    this.queryDetails = queryDetails;
  }

  QueryBuilder.prototype.buildDataNodeQuery = function() {
    return this.buildQuery(this.queryDetails, false);
  };

  QueryBuilder.prototype.buildMasterNodeQuery = function() {
    return this.buildQuery(this.queryDetails, true);
  };

  QueryBuilder.prototype.buildQuery = function(parsedQuery, master) {
    var alias, aliasCount, f, groupFields, nameOrFunc, orderFields, selColumns, sql, _i, _len, _ref;
    if (master == null) {
      master = False;
    }
    sql = 'SELECT ';
    selColumns = [];
    _ref = parsedQuery.fields;
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      f = _ref[_i];
      alias = ' ';
      nameOrFunc = '';
      if (f.name) {
        alias += 'as ' + f.name.value;
        nameOrFunc = f.field.name;
      } else {
        nameOrFunc = f.field.value;
      }
      aliasCount = 0;
      if (nameOrFunc.toUpperCase() === 'AVG') {
        if (master) {
          selColumns.push('SUM(_A' + aliasCount + ')/COUNT(_A' + (aliasCount + 1) + ')');
        } else {
          selColumns.push('SUM(' + f.field["arguments"][0].value + ') as _A' + aliasCount + ', COUNT(' + f.field["arguments"][0].value + ') as _A' + (aliasCount + 1));
        }
        aliasCount += 2;
      } else if (['MIN', 'MAX', 'SUM', 'COUNT', 'TOTAL'].indexOf(nameOrFunc.toUpperCase()) !== -1) {
        selColumns.push(nameOrFunc + '(' + f.field.name.value + ')' + alias);
      } else {
        selColumns.push(nameOrFunc + alias);
      }
    }
    console.log(JSON.stringify(selColumns));
    sql += selColumns.join(', ');
    if (parsedQuery.source) {
      sql += 'FROM ' + parsedQuery.source.name.value;
    }
    if (parsedQuery.group) {
      sql += ' GROUP BY ';
      groupFields = (function() {
        var _j, _len1, _ref1, _results;
        _ref1 = parsedQuery.group.fields;
        _results = [];
        for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
          f = _ref1[_j];
          _results.push(f.value);
        }
        return _results;
      })();
    }
    sql += groupFields.join(', ');
    if (parsedQuery.order) {
      sql += ' ORDER BY ';
      orderFields = (function() {
        var _j, _len1, _ref1, _results;
        _ref1 = parsedQuery.order.orderings;
        _results = [];
        for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
          f = _ref1[_j];
          _results.push(f.value.value + ' ' + f.direction);
        }
        return _results;
      })();
    }
    sql += orderFields.join(', ');
    return sql;
  };

  return QueryBuilder;

})();

module.exports = QueryBuilder;
