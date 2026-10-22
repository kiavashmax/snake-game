(function (App) {
  'use strict';

  var cfg = App.config;

  var State = {
    IDLE: 'idle',
    RUNNING: 'running',
    PAUSED: 'paused',
    OVER: 'over'
  };

  function Game(renderer, ui) {
    this.renderer = renderer;
    this.ui = ui;
    this.snake = new App.Snake(cfg.board, cfg.input.buffer);
    this.food = new App.Food(cfg.board);
    this.particles = new App.Particles();
    this.state = State.IDLE;
    this.score = 0;
    this.streak = 0;
    this.best = App.storage.get('best', 0) || 0;
    this.speed = cfg.speed.start;
    this.accumulator = 0;
    this.lastFrame = 0;
    this.frame = this.frame.bind(this);
    this.ui.setBest(this.best);
    this.ui.setScore(0);
  }

  Game.State = State;

  Game.prototype.loop = function () {
    this.lastFrame = performance.now();
    requestAnimationFrame(this.frame);
  };

  Game.prototype.start = function () {
    this.snake.reset();
    this.food.spawn(this.snake);
    this.particles.clear();
    this.score = 0;
    this.streak = 0;
    this.speed = cfg.speed.start;
    this.accumulator = 0;
    this.state = State.RUNNING;
    this.lastFrame = performance.now();
    this.ui.setScore(0);
    this.ui.hideOverlay();
    if (App.Audio) App.Audio.start();
  };

  Game.prototype.pause = function () {
    if (this.state !== State.RUNNING) return;
    this.state = State.PAUSED;
    if (App.Audio) App.Audio.pause();
    this.ui.showOverlay('paused', { score: this.score });
  };

  Game.prototype.resume = function () {
    if (this.state !== State.PAUSED) return;
    this.state = State.RUNNING;
    this.lastFrame = performance.now();
    if (App.Audio) App.Audio.resume();
    this.ui.hideOverlay();
  };

  Game.prototype.togglePause = function () {
    if (this.state === State.RUNNING) this.pause();
    else if (this.state === State.PAUSED) this.resume();
  };

  Game.prototype.direction = function (name) {
    if (this.state !== State.RUNNING) return;
    this.snake.queue(name);
  };

  Game.prototype.step = function () {
    var move = this.snake.step();
    if (move.died) { this.finish(); return; }
    if (move.head.x === this.food.x && move.head.y === this.food.y) this.eat(move.head);
  };

  Game.prototype.eat = function (head) {
    this.snake.feed();
    this.score += 1;
    this.streak += 1;
    this.ui.setScore(this.score);
    this.particles.burst(head.x, head.y, cfg.board.cell, cfg.colors.spark, 12);
    this.food.spawn(this.snake);
    if (App.Audio) App.Audio.eat(this.streak);
    if (this.score > 0 && this.score % 10 === 0) {
      if (App.Audio) App.Audio.milestone();
    } else if (this.score > 0 && this.score % 5 === 0) {
      if (App.Audio) App.Audio.speedUp();
    }
    if (this.speed < cfg.speed.max) {
      this.speed = Math.min(cfg.speed.max, this.speed + cfg.speed.step);
    }
  };

  Game.prototype.finish = function () {
    this.state = State.OVER;
    var head = this.snake.cells[0];
    this.particles.burst(head.x, head.y, cfg.board.cell, cfg.colors.spark, 22);
    var record = this.score > this.best;
    if (record) {
      this.best = this.score;
      App.storage.set('best', this.best);
      this.ui.setBest(this.best);
    }
    if (App.Audio) {
      App.Audio.die();
      if (record) setTimeout(function () { App.Audio.record(); }, 650);
    }
    this.streak = 0;
    this.ui.showOverlay('over', {
      score: this.score,
      best: this.best,
      record: record
    });
  };

  Game.prototype.frame = function (now) {
    var dt = now - this.lastFrame;
    this.lastFrame = now;
    if (dt < 0) dt = 0;
    if (dt > 120) dt = 120;
    var interval = 1000 / this.speed;
    if (this.state === State.RUNNING) {
      this.accumulator += dt;
      var guard = 0;
      while (this.accumulator >= interval && guard < 5) {
        this.accumulator -= interval;
        this.step();
        guard++;
        interval = 1000 / this.speed;
        if (this.state !== State.RUNNING) break;
      }
      if (guard >= 5) this.accumulator = 0;
    }
    this.particles.update(dt);
    var alpha = this.state === State.RUNNING
      ? Math.min(this.accumulator / interval, 1) : 1;
    this.renderer.draw({
      now: now, alpha: alpha,
      snake: this.snake, food: this.food, particles: this.particles
    });
    requestAnimationFrame(this.frame);
  };

  App.Game = Game;
})(window.App = window.App || {});
