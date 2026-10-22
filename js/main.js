(function (App) {
  'use strict';

  function boot() {
    var boardEl = document.getElementById('board');
    var dpadEl = document.getElementById('dpad');
    var stageEl = document.querySelector('.stage');

    var renderer = new App.Renderer(boardEl);
    var ui = App.UI;
    var game;

    ui.init({
      onStart: function () { game.start(); },
      onResume: function () { game.resume(); },
      onLanguage: function (code) { App.i18n.set(code); }
    });

    game = new App.Game(renderer, ui);

    App.Input.init({ stage: stageEl, dpad: dpadEl });

    App.Input.on('direction', function (dir) {
      game.direction(dir);
    });

    App.Input.on('action', function () {
      if (game.state === App.Game.State.RUNNING ||
          game.state === App.Game.State.PAUSED) {
        game.togglePause();
      } else {
        game.start();
      }
    });

    App.Input.on('pause', function () {
      game.togglePause();
    });

    var saved = App.storage.get('lang', null);
    App.i18n.set(App.i18n.has(saved) ? saved : App.i18n.default, true);

    ui.showOverlay('menu');
    game.loop();

    document.addEventListener('visibilitychange', function () {
      if (document.hidden) game.pause();
    });
  }

  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', boot);
  } else {
    boot();
  }
})(window.App = window.App || {});
