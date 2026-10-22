(function (App) {
  'use strict';

  App.config = {
    board: { cols: 20, rows: 20, cell: 30 },
    speed: { start: 7, max: 16, step: 0.28 },
    input: { buffer: 3, swipe: 24 },
    snake: { startLength: 3 },
    colors: { spark: ['#d4af37', '#f0d27a', '#ff9a3c', '#a78bfa'] },
    storageKey: 'magic-serpent'
  };
})(window.App = window.App || {});
