(function (App) {
  'use strict';

  var cfg = App.config;

  function roundRect(ctx, x, y, w, h, r) {
    ctx.beginPath();
    ctx.moveTo(x + r, y);
    ctx.lineTo(x + w - r, y);
    ctx.quadraticCurveTo(x + w, y, x + w, y + r);
    ctx.lineTo(x + w, y + h - r);
    ctx.quadraticCurveTo(x + w, y + h, x + w - r, y + h);
    ctx.lineTo(x + r, y + h);
    ctx.quadraticCurveTo(x, y + h, x, y + h - r);
    ctx.lineTo(x, y + r);
    ctx.quadraticCurveTo(x, y, x + r, y);
    ctx.closePath();
  }

  function diamond(ctx, cx, cy, rx, ry) {
    ctx.beginPath();
    ctx.moveTo(cx, cy - ry);
    ctx.lineTo(cx + rx, cy);
    ctx.lineTo(cx, cy + ry);
    ctx.lineTo(cx - rx, cy);
    ctx.closePath();
  }

  function Renderer(canvas) {
    this.canvas = canvas;
    this.ctx = canvas.getContext('2d');
    this.cell = cfg.board.cell;
    this.width = cfg.board.cols * this.cell;
    this.height = cfg.board.rows * this.cell;
    this.dpr = Math.min(window.devicePixelRatio || 1, 2);

    canvas.width = this.width * this.dpr;
    canvas.height = this.height * this.dpr;
    this.ctx.setTransform(this.dpr, 0, 0, this.dpr, 0, 0);

    this.gridLayer = this.buildGrid();
  }

  Renderer.prototype.buildGrid = function () {
    var off = document.createElement('canvas');
    off.width = this.canvas.width;
    off.height = this.canvas.height;

    var g = off.getContext('2d');
    g.setTransform(this.dpr, 0, 0, this.dpr, 0, 0);
    g.fillStyle = 'rgba(212, 175, 55, 0.09)';

    var c = this.cell;
    for (var x = 1; x < cfg.board.cols; x++) {
      for (var y = 1; y < cfg.board.rows; y++) {
        g.fillRect(x * c - 0.5, y * c - 0.5, 1, 1);
      }
    }
    return off;
  };

  Renderer.prototype.draw = function (state) {
    var ctx = this.ctx;

    ctx.clearRect(0, 0, this.width, this.height);
    ctx.drawImage(this.gridLayer, 0, 0, this.width, this.height);

    this.drawFood(state.food, state.now);
    this.drawSnake(state.snake, state.alpha);
    state.particles.draw(ctx);
  };

  Renderer.prototype.drawFood = function (food, now) {
    var ctx = this.ctx;
    var c = this.cell;
    var cx = food.x * c + c / 2;
    var cy = food.y * c + c / 2;
    var pulse = Math.sin(now / 220);
    var size = c * 0.3 + pulse * 1.2;

    ctx.save();
    ctx.shadowColor = 'rgba(212, 175, 55, 0.9)';
    ctx.shadowBlur = 16 + pulse * 6;

    ctx.fillStyle = '#f7e19b';
    diamond(ctx, cx, cy, size, size * 1.15);
    ctx.fill();

    ctx.shadowBlur = 0;
    ctx.fillStyle = '#d4af37';
    diamond(ctx, cx, cy, size * 0.42, size * 0.5);
    ctx.fill();
    ctx.restore();
  };

  Renderer.prototype.drawSnake = function (snake, alpha) {
    var ctx = this.ctx;
    var c = this.cell;
    var cells = snake.cells;
    var prev = snake.prevCells;
    var count = cells.length;
    var pad = 2.4;
    var size = c - pad * 2;

    for (var i = count - 1; i >= 0; i--) {
      var cur = cells[i];
      var old = prev[i] || cur;
      var px, py;

      if (Math.abs(cur.x - old.x) > 1 || Math.abs(cur.y - old.y) > 1) {
        px = cur.x;
        py = cur.y;
      } else {
        px = old.x + (cur.x - old.x) * alpha;
        py = old.y + (cur.y - old.y) * alpha;
      }

      var x = px * c + pad;
      var y = py * c + pad;
      var isHead = i === 0;
      var fade = 1 - (i / Math.max(count, 1)) * 0.45;

      var grad = ctx.createLinearGradient(x, y, x + size, y + size);
      if (isHead) {
        grad.addColorStop(0, '#fff6d0');
        grad.addColorStop(1, '#d4af37');
      } else {
        grad.addColorStop(0, 'rgba(212, 175, 55, ' + (0.92 * fade) + ')');
        grad.addColorStop(1, 'rgba(118, 96, 46, ' + (0.92 * fade) + ')');
      }

      ctx.save();
      if (isHead) {
        ctx.shadowColor = 'rgba(212, 175, 55, 0.85)';
        ctx.shadowBlur = 16;
      }
      roundRect(ctx, x, y, size, size, Math.min(9, size / 3));
      ctx.fillStyle = grad;
      ctx.fill();
      ctx.restore();

      if (isHead) this.drawEyes(x, y, size, snake.dir);
    }
  };

  Renderer.prototype.drawEyes = function (x, y, size, dir) {
    var ctx = this.ctx;
    var cx = x + size / 2 + dir.x * size * 0.16;
    var cy = y + size / 2 + dir.y * size * 0.16;
    var ox = -dir.y * size * 0.19;
    var oy = dir.x * size * 0.19;
    var r = size * 0.085;

    ctx.fillStyle = '#0a0a12';
    ctx.beginPath();
    ctx.arc(cx + ox, cy + oy, r, 0, Math.PI * 2);
    ctx.arc(cx - ox, cy - oy, r, 0, Math.PI * 2);
    ctx.fill();
  };

  App.Renderer = Renderer;
})(window.App = window.App || {});
