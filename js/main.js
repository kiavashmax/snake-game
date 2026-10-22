(function (App) {
  'use strict';

  function boot() {
    var boardEl = document.getElementById('board');
    var dpadEl = document.getElementById('dpad');
    var stageEl = document.querySelector('.stage');
    var muteBtn = document.getElementById('muteBtn');

    var renderer = new App.Renderer(boardEl);
    var ui = App.UI;
    var game;

    ui.init({
      onStart: function () { App.Audio.unlock(); game.start(); },
      onResume: function () { game.resume(); },
      onLanguage: function (code) { App.i18n.set(code); }
    });

    game = new App.Game(renderer, ui);
    App.Input.init({ stage: stageEl, dpad: dpadEl });

    App.Input.on('direction', function (dir) { game.direction(dir); });

    App.Input.on('action', function () {
      App.Audio.unlock();
      if (game.state === App.Game.State.RUNNING ||
          game.state === App.Game.State.PAUSED) {
        game.togglePause();
      } else {
        game.start();
      }
    });

    App.Input.on('pause', function () { game.togglePause(); });

    var saved = App.storage.get('lang', null);
    App.i18n.set(App.i18n.has(saved) ? saved : App.i18n.default, true);

    ui.showOverlay('menu');
    game.loop();

    document.addEventListener('visibilitychange', function () {
      if (document.hidden) game.pause();
    });

    function refreshMute() {
      var m = App.Audio.isMuted();
      muteBtn.textContent = m ? '\uD83D\uDD07' : '\uD83D\uDD0A';
      muteBtn.classList.toggle('is-muted', m);
      muteBtn.setAttribute('aria-label', App.i18n.t(m ? 'audio.off' : 'audio.on'));
    }

    muteBtn.addEventListener('click', function () {
      App.Audio.unlock();
      if (App.Audio.isMuted()) {
        App.Audio.setMuted(false);
        refreshMute();
        App.Audio.muteSound(false);
      } else {
        App.Audio.muteSound(true);
        setTimeout(function () {
          App.Audio.setMuted(true);
          refreshMute();
        }, 90);
      }
    });

    window.addEventListener('pointerdown', function () { App.Audio.unlock(); },
      { once: true, passive: true });
    window.addEventListener('keydown', function () { App.Audio.unlock(); },
      { once: true });

    App.i18n.onChange(refreshMute);
    refreshMute();
  }

  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', boot);
  } else {
    boot();
  }
})(window.App = window.App || {});
