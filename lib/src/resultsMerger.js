var ResultsMerger, _,
  __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

_ = require('underscore');

ResultsMerger = (function() {
  ResultsMerger.isDone = false;

  ResultsMerger.results = null;

  ResultsMerger.queryDetails = null;

  function ResultsMerger(queryDetails) {
    this.complete = __bind(this.complete, this);
    this.receiveChunk = __bind(this.receiveChunk, this);
    this.queryDetails = queryDetails;
    this.results = [];
  }

  ResultsMerger.prototype.receiveChunk = function(source, data) {
    if (this.isDone) {
      throw 'No more chunks from you, you already told me you were done.';
    }
    return this.results = _.union(this.results, data);
  };

  ResultsMerger.prototype.complete = function() {
    this.isDone = true;
    return this.results;
  };

  return ResultsMerger;

})();

module.exports = ResultsMerger;
