(function (App) {
  'use strict';

  var KEY = App.config.storageKey;
  var fallback = {};

  function readAll() {
    try {
      return JSON.parse(localStorage.getItem(KEY) || '{}') || {};
    } catch (e) {
      return fallback;
    }
  }

  function writeAll(data) {
    try {
      localStorage.setItem(KEY, JSON.stringify(data));
    } catch (e) {
      fallback = data;
    }
  }

  App.storage = {
    get: function (key, def) {
      var data = readAll();
      return Object.prototype.hasOwnProperty.call(data, key) ? data[key] : def;
    },
    set: function (key, value) {
      var data = readAll();
      data[key] = value;
      writeAll(data);
    }
  };
})(window.App = window.App || {});
