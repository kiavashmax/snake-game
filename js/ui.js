(function (App) {
  'use strict';

  var dom = {};
  var actions = {};
  var overlayState = { kind: 'menu', score: 0, best: 0, record: false };

  function byId(id) {
    return document.getElementById(id);
  }

  function cache() {
    dom.score = byId('score');
    dom.best = byId('best');
    dom.overlay = byId('overlay');
    dom.title = byId('overlayTitle');
    dom.text = byId('overlayText');
    dom.scoreBox = byId('overlayScore');
    dom.button = byId('overlayBtn');
    dom.langs = byId('langs');
  }

  function renderOverlay() {
    var t = App.i18n.t;
    var s = overlayState;

    if (s.kind === 'menu') {
      dom.title.textContent = t('menu.title');
      dom.text.textContent = t('menu.hint');
      dom.scoreBox.classList.add('is-hidden');
      dom.button.textContent = t('menu.start');
    } else if (s.kind === 'paused') {
      dom.title.textContent = t('paused.title');
      dom.text.textContent = t('paused.hint');
      dom.scoreBox.classList.add('is-hidden');
      dom.button.textContent = t('paused.resume');
    } else {
      dom.title.textContent = s.record ? t('over.record') : t('over.title');
      dom.text.textContent = '';
      dom.scoreBox.innerHTML =
        '<span class="overlay__label">' + t('over.score') + '</span>' +
        '<span class="overlay__big">' + s.score + '</span>' +
        '<span class="overlay__label">' + t('over.best') + ': ' + s.best + '</span>';
      dom.scoreBox.classList.remove('is-hidden');
      dom.button.textContent = t('over.retry');
    }
  }

  function renderLanguages() {
    dom.langs.innerHTML = '';

    App.i18n.list().forEach(function (code) {
      var btn = document.createElement('button');
      btn.type = 'button';
      btn.className = 'lang';
      btn.textContent = App.i18n.pack(code).name || code;
      btn.setAttribute('lang', code);

      if (code === App.i18n.current) btn.classList.add('is-active');

      btn.addEventListener('click', function () {
        if (actions.onLanguage) actions.onLanguage(code);
      });

      dom.langs.appendChild(btn);
    });
  }

  App.UI = {
    init: function (callbacks) {
      actions = callbacks || {};
      cache();

      dom.button.addEventListener('click', function () {
        dom.button.blur();
        if (overlayState.kind === 'paused') {
          if (actions.onResume) actions.onResume();
        } else {
          if (actions.onStart) actions.onStart();
        }
      });

      App.i18n.onChange(function () {
        renderLanguages();
        renderOverlay();
      });

      renderLanguages();
      renderOverlay();
    },

    setScore: function (value) {
      dom.score.textContent = value;
    },

    setBest: function (value) {
      dom.best.textContent = value;
    },

    showOverlay: function (kind, data) {
      data = data || {};
      overlayState.kind = kind;
      overlayState.score = data.score || 0;
      overlayState.best = data.best || 0;
      overlayState.record = !!data.record;

      renderOverlay();
      dom.overlay.classList.remove('is-hidden');
    },

    hideOverlay: function () {
      dom.overlay.classList.add('is-hidden');
    }
  };
})(window.App = window.App || {});
