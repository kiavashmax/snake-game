(function (App) {
  'use strict';

  var packs = {};
  var current = 'en';
  var FALLBACK = 'en';
  var listeners = [];

  function resolve(dict, path) {
    if (!dict) return undefined;
    var parts = path.split('.');
    var node = dict;
    for (var i = 0; i < parts.length; i++) {
      if (node === null || typeof node !== 'object') return undefined;
      node = node[parts[i]];
    }
    return typeof node === 'string' ? node : undefined;
  }

  function t(key, vars) {
    var value = resolve(packs[current] && packs[current].strings, key);
    if (value === undefined) value = resolve(packs[FALLBACK] && packs[FALLBACK].strings, key);
    if (value === undefined) return key;
    if (vars) {
      Object.keys(vars).forEach(function (name) {
        value = value.split('{' + name + '}').join(vars[name]);
      });
    }
    return value;
  }

  function apply(root) {
    root = root || document;
    var nodes = root.querySelectorAll('[data-i18n]');
    for (var i = 0; i < nodes.length; i++) {
      nodes[i].textContent = t(nodes[i].getAttribute('data-i18n'));
    }
    var titled = root.querySelectorAll('[data-i18n-title]');
    for (var j = 0; j < titled.length; j++) {
      titled[j].setAttribute('title', t(titled[j].getAttribute('data-i18n-title')));
    }
  }

  App.i18n = {
    default: FALLBACK,
    register: function (code, pack) { packs[code] = pack; },
    has: function (code) { return !!packs[code]; },
    pack: function (code) { return packs[code] || packs[FALLBACK] || {}; },
    list: function () { return Object.keys(packs); },
    t: t,
    apply: apply,
    get current() { return current; },
    set: function (code, silent) {
      if (!packs[code]) return false;
      current = code;
      var pack = packs[code];
      var root = document.documentElement;
      root.setAttribute('lang', code);
      root.setAttribute('dir', pack.dir || 'ltr');
      root.style.setProperty(
        '--font-game',
        "'" + (pack.font || 'Main') + "', Tahoma, system-ui, sans-serif"
      );
      document.title = t('app.title');
      apply();
      if (!silent) App.storage.set('lang', code);
      for (var i = 0; i < listeners.length; i++) listeners[i](code);
      return true;
    },
    onChange: function (fn) { listeners.push(fn); }
  };
})(window.App = window.App || {});
