(function (App) {
  'use strict';

  function Food(board) {
    this.cols = board.cols;
    this.rows = board.rows;
    this.x = 0;
    this.y = 0;
  }

  Food.prototype.spawn = function (snake) {
    var free = [];
    for (var y = 0; y < this.rows; y++) {
      for (var x = 0; x < this.cols; x++) {
        if (!snake.isOccupied(x, y)) free.push({ x: x, y: y });
      }
    }
    if (!free.length) return false;
    var pick = free[Math.floor(Math.random() * free.length)];
    this.x = pick.x;
    this.y = pick.y;
    return true;
  };

  App.Food = Food;
})(window.App = window.App || {});
