(function (App) {
  'use strict';

  var handlers = {};
  var KEY_DIR = {
    ArrowUp: 'up', ArrowDown: 'down', ArrowLeft: 'left', ArrowRight: 'right',
    w: 'up', a: 'left', s: 'down', d: 'right',
    W: 'up', A: 'left', S: 'down', D: 'right'
  };

  function on(type, fn) {
    if (!handlers[type]) handlers[type] = [];
    handlers[type].push(fn);
    return App.Input;
  }

  function emit(type, payload) {
    var list = handlers[type];
    if (!list) return;
    for (var i = 0; i < list.length; i++) list[i](payload);
  }

  function onKeyDown(e) {
    var dir = KEY_DIR[e.key];
    if (dir) { e.preventDefault(); emit('direction', dir); return; }
    if (e.key === ' ' || e.key === 'Enter') { e.preventDefault(); emit('action'); return; }
    if (e.key === 'p' || e.key === 'P' || e.key === 'Escape') emit('pause');
  }

  function bindDpad(el) {
    if (!el) return;
    el.addEventListener('pointerdown', function (e) {
      var btn = e.target.closest('[data-dir]');
      if (!btn) return;
      e.preventDefault();
      emit('direction', btn.getAttribute('data-dir'));
    }, { passive: false });
  }

  function bindSwipe(el) {
    if (!el) return;
    var drag = null;
    var threshold = App.config.input.swipe;

    el.addEventListener('pointerdown', function (e) {
      drag = { id: e.pointerId, x: e.clientX, y: e.clientY };
      if (el.setPointerCapture) el.setPointerCapture(e.pointerId);
    });

    el.addEventListener('pointermove', function (e) {
      if (!drag || e.pointerId !== drag.id) return;
      var dx = e.clientX - drag.x;
      var dy = e.clientY - drag.y;
      if (Math.abs(dx) < threshold && Math.abs(dy) < threshold) return;
      if (Math.abs(dx) > Math.abs(dy)) emit('direction', dx > 0 ? 'right' : 'left');
      else emit('direction', dy > 0 ? 'down' : 'up');
      drag.x = e.clientX;
      drag.y = e.clientY;
    });

    function release(e) { if (drag && e.pointerId === drag.id) drag = null; }
    el.addEventListener('pointerup', release);
    el.addEventListener('pointercancel', release);
  }

  App.Input = {
    init: function (options) {
      options = options || {};
      window.addEventListener('keydown', onKeyDown, { passive: false });
      bindDpad(options.dpad);
      bindSwipe(options.stage);
      return this;
    },
    on: on
  };
})(window.App = window.App || {});
