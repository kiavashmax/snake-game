(function (App) {
  'use strict';

  var ctx = null;
  var master = null;
  var muted = !!App.storage.get('muted', false);
  var volume = 0.35;

  function ensure() {
    if (ctx) return true;
    var AC = window.AudioContext || window.webkitAudioContext;
    if (!AC) return false;
    try { ctx = new AC(); } catch (e) { return false; }
    master = ctx.createGain();
    master.gain.value = muted ? 0 : volume;
    master.connect(ctx.destination);
    return true;
  }

  function unlock() {
    if (!ensure()) return;
    if (ctx.state === 'suspended') ctx.resume();
  }

  function tone(opts) {
    if (!ctx || muted) return;
    if (ctx.state === 'suspended') return;

    var now = ctx.currentTime;
    var osc = ctx.createOscillator();
    var gain = ctx.createGain();
    var type = opts.type || 'sine';
    var freq = opts.freq || 440;
    var to = opts.to || freq;
    var dur = opts.dur || 0.15;
    var vol = opts.vol == null ? 0.6 : opts.vol;
    var delay = opts.delay || 0;

    osc.type = type;
    osc.frequency.setValueAtTime(freq, now + delay);
    if (to !== freq) {
      osc.frequency.exponentialRampToValueAtTime(to, now + delay + dur);
    }

    gain.gain.setValueAtTime(0.0001, now + delay);
    gain.gain.linearRampToValueAtTime(vol, now + delay + 0.01);
    gain.gain.exponentialRampToValueAtTime(0.0001, now + delay + dur);

    osc.connect(gain);
    gain.connect(master);
    osc.start(now + delay);
    osc.stop(now + delay + dur + 0.05);
  }

  App.Audio = {
    unlock: unlock,

    isMuted: function () { return muted; },

    setMuted: function (m) {
      muted = !!m;
      if (master) master.gain.value = muted ? 0 : volume;
      App.storage.set('muted', muted);
    },

    toggle: function () {
      App.Audio.setMuted(!muted);
      return muted;
    },

    start: function () {
      [440, 660, 880].forEach(function (f, i) {
        tone({ type: 'triangle', freq: f, dur: 0.12, vol: 0.35, delay: i * 0.06 });
      });
    },

    eat: function () {
      tone({ type: 'triangle', freq: 660, to: 1320, dur: 0.14, vol: 0.45 });
      tone({ type: 'sine', freq: 990, to: 1980, dur: 0.16, vol: 0.2, delay: 0.02 });
    },

    die: function () {
      tone({ type: 'sawtooth', freq: 320, to: 60, dur: 0.5, vol: 0.3 });
      tone({ type: 'square', freq: 220, to: 40, dur: 0.6, vol: 0.15, delay: 0.05 });
    },

    record: function () {
      [523, 659, 784, 1047].forEach(function (f, i) {
        tone({ type: 'triangle', freq: f, dur: 0.16, vol: 0.35, delay: i * 0.09 });
      });
    },

    tick: function () {
      tone({ type: 'sine', freq: 880, dur: 0.05, vol: 0.2 });
    }
  };
})(window.App = window.App || {});
