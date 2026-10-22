(function (App) {
  'use strict';

  function Particles() {
    this.list = [];
  }

  Particles.prototype.clear = function () {
    this.list.length = 0;
  };

  Particles.prototype.burst = function (gx, gy, cellSize, colors, amount) {
    var cx = gx * cellSize + cellSize / 2;
    var cy = gy * cellSize + cellSize / 2;

    for (var i = 0; i < (amount || 12); i++) {
      var angle = Math.random() * Math.PI * 2;
      var speed = 1 + Math.random() * 3;

      this.list.push({
        x: cx,
        y: cy,
        vx: Math.cos(angle) * speed,
        vy: Math.sin(angle) * speed,
        life: 1,
        decay: 0.02 + Math.random() * 0.03,
        radius: 1.5 + Math.random() * 2,
        color: colors[Math.floor(Math.random() * colors.length)]
      });
    }
  };

  Particles.prototype.update = function (dt) {
    var frame = dt / 16.67;

    for (var i = this.list.length - 1; i >= 0; i--) {
      var p = this.list[i];

      p.x += p.vx * frame;
      p.y += p.vy * frame;
      p.vy += 0.12 * frame;
      p.vx *= 0.99;
      p.life -= p.decay * frame;

      if (p.life <= 0) this.list.splice(i, 1);
    }
  };

  Particles.prototype.draw = function (ctx) {
    for (var i = 0; i < this.list.length; i++) {
      var p = this.list[i];
      ctx.globalAlpha = p.life > 0 ? p.life : 0;
      ctx.fillStyle = p.color;
      ctx.beginPath();
      ctx.arc(p.x, p.y, p.radius, 0, Math.PI * 2);
      ctx.fill();
    }
    ctx.globalAlpha = 1;
  };

  App.Particles = Particles;
})(window.App = window.App || {});
