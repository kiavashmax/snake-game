(function (App) {
  'use strict';

  var DIRS = {
    up:    { x: 0,  y: -1 },
    down:  { x: 0,  y: 1  },
    left:  { x: -1, y: 0  },
    right: { x: 1,  y: 0  }
  };

  function clone(cell) {
    return { x: cell.x, y: cell.y };
  }

  function Snake(board, bufferSize) {
    this.cols = board.cols;
    this.rows = board.rows;
    this.bufferSize = bufferSize || 3;
    this.reset();
  }

  Snake.DIRS = DIRS;

  Snake.prototype.reset = function () {
    var startX = Math.floor(this.cols / 2);
    var startY = Math.floor(this.rows / 2);
    var length = App.config.snake.startLength;

    this.cells = [];
    for (var i = 0; i < length; i++) {
      this.cells.push({ x: startX - i, y: startY });
    }

    this.prevCells = this.cells.map(clone);
    this.dir = DIRS.right;
    this.pending = [];
    this.grow = 0;
    this.alive = true;
  };

  Snake.prototype.queue = function (name) {
    var next = DIRS[name];
    if (!next) return;

    var last = this.pending.length
      ? this.pending[this.pending.length - 1]
      : this.dir;

    if (next.x === last.x && next.y === last.y) return;
    if (next.x === -last.x && next.y === -last.y) return;
    if (this.pending.length >= this.bufferSize) return;

    this.pending.push(next);
  };

  Snake.prototype.feed = function () {
    this.grow += 1;
  };

  Snake.prototype.isOccupied = function (x, y) {
    for (var i = 0; i < this.cells.length; i++) {
      if (this.cells[i].x === x && this.cells[i].y === y) return true;
    }
    return false;
  };

  Snake.prototype.bitesItself = function (head) {
    var limit = this.grow > 0 ? this.cells.length : this.cells.length - 1;
    for (var i = 0; i < limit; i++) {
      if (this.cells[i].x === head.x && this.cells[i].y === head.y) return true;
    }
    return false;
  };

  Snake.prototype.step = function () {
    if (this.pending.length) this.dir = this.pending.shift();

    var head = {
      x: this.cells[0].x + this.dir.x,
      y: this.cells[0].y + this.dir.y
    };

    if (head.x < 0) head.x = this.cols - 1;
    else if (head.x >= this.cols) head.x = 0;
    if (head.y < 0) head.y = this.rows - 1;
    else if (head.y >= this.rows) head.y = 0;

    this.prevCells = this.cells.map(clone);

    if (this.bitesItself(head)) {
      this.alive = false;
      return { died: true, head: head };
    }

    this.cells.unshift(head);

    if (this.grow > 0) this.grow -= 1;
    else this.cells.pop();

    return { died: false, head: head };
  };

  App.Snake = Snake;
})(window.App = window.App || {});
