var QueryBuilder, ResultsMerger, async, db, http, nodes, sqlparser, _;

db = require('./database');

async = require('async');

_ = require('underscore');

http = require('http');

ResultsMerger = require('./resultsMerger');

QueryBuilder = require('./queryBuilder');

sqlparser = require('./sqlparser');

nodes = [
  {
    host: 'localhost',
    port: process.env.PORT || 3000,
    path: '/node1'
  }, {
    host: 'localhost',
    port: process.env.PORT || 3000,
    path: '/node2'
  }
];

exports.runQuery = function(query, script, cb) {
  var dbcalls, merger, node, nodeQuery, queryBuilder, queryData;
  console.log('running query...');
  merger = new ResultsMerger({
    queryText: query
  });
  queryData = sqlparser.parse(query);
  queryBuilder = new QueryBuilder(query, queryData);
  nodeQuery = queryBuilder.buildDataNodeQuery();
  dbcalls = (function() {
    var _i, _len, _results;
    _results = [];
    for (_i = 0, _len = nodes.length; _i < _len; _i++) {
      node = nodes[_i];
      _results.push((function(node) {
        return function(done) {
          var reqOptions, request;
          reqOptions = {
            host: node.host,
            port: node.port,
            method: 'POST',
            path: node.path + '/executeQuery',
            headers: {
              'Content-Type': 'application/json'
            }
          };
          request = http.request(reqOptions, function(response) {
            var data;
            data = '';
            response.on('data', function(chunk) {
              return data += chunk;
            });
            return response.on('end', function() {
              var alteredData, parsedData, x;
              parsedData = JSON.parse(data);
              merger.receiveChunk(node, parsedData);
              alteredData = (function() {
                var _j, _len1, _results1;
                _results1 = [];
                for (_j = 0, _len1 = parsedData.length; _j < _len1; _j++) {
                  x = parsedData[_j];
                  x['_node'] = "" + node.host + ":" + node.port + node.path;
                  _results1.push(x);
                }
                return _results1;
              })();
              return done(null, alteredData);
            });
          });
          request.on('error', function(err) {
            return done(err);
          });
          request.write(JSON.stringify({
            query: nodeQuery,
            script: script
          }));
          return request.end();
        };
      })(node));
    }
    return _results;
  })();
  return async.parallel(dbcalls, function(err, results) {
    if (err) {
      cb(err);
    }
    results = merger.complete();
    return cb(null, {
      data: results,
      query: nodeQuery
    });
  });
};
