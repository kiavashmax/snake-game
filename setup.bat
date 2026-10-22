::@FILE:js/core/audio.js
(function (App) {
  'use strict';

  var ctx = null;
  var master = null;
  var muted = !!App.storage.get('muted', false);
  var volume = 0.7;
  var DEBUG = false;

  function log() {
    if (DEBUG && window.console && console.log) {
      console.log.apply(console, ['[Audio]'].concat([].slice.call(arguments)));
    }
  }

  function ensure() {
    if (ctx) return true;

    var AC = window.AudioContext || window.webkitAudioContext;
    if (!AC) {
      log('Web Audio API not supported in this browser');
      return false;
    }

    try {
      ctx = new AC();
    } catch (e) {
      log('AudioContext creation failed', e);
      return false;
    }

    master = ctx.createGain();
    master.gain.value = muted ? 0 : volume;
    master.connect(ctx.destination);

    log('AudioContext created, state =', ctx.state, '| muted =', muted);
    return true;
  }

  function unlock() {
    if (!ensure()) return;

    if (ctx.state === 'suspended') {
      var p = ctx.resume();
      if (p && p.then) {
        p.then(function () {
          log('resumed, state =', ctx.state);
        }).catch(function (e) {
          log('resume failed', e);
        });
      }
    }

    try {
      var osc = ctx.createOscillator();
      var g = ctx.createGain();
      g.gain.value = 0.0001;
      osc.connect(g);
      g.connect(master);
      osc.start();
      osc.stop(ctx.currentTime + 0.02);
    } catch (e) {
      log('warmup failed', e);
    }
  }

  function tone(opts) {
    if (!ctx || muted) {
      log('tone skipped: ctx=', !!ctx, 'muted=', muted);
      return;
    }

    if (opts.__retry == null) opts.__retry = 0;

    if (ctx.state !== 'running') {
      if (ctx.state === 'suspended' && opts.__retry < 2) {
        opts.__retry += 1;
        log('suspended, retry', opts.__retry);
        ctx.resume().then(function () {
          if (ctx.state === 'running') tone(opts);
        }).catch(function (e) {
          log('retry resume failed', e);
        });
      } else {
        log('tone skipped: state =', ctx.state);
      }
      return;
    }

    try {
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

      log('played', type, freq, '->', to, 'dur', dur, 'vol', vol);
    } catch (e) {
      log('tone error', e);
    }
  }

  App.Audio = {
    unlock: unlock,

    isMuted: function () { return muted; },

    setMuted: function (m) {
      muted = !!m;
      if (master) master.gain.value = muted ? 0 : volume;
      App.storage.set('muted', muted);
      log('muted set to', muted);
    },

    toggle: function () {
      App.Audio.setMuted(!muted);
      return muted;
    },

    reset: function () {
      muted = false;
      App.storage.set('muted', false);
      if (master) master.gain.value = volume;
      log('mute reset');
    },

    debug: function (on) {
      DEBUG = !!on;
      if (DEBUG) {
        log('debug on | ctx:', ctx ? ctx.state : 'null', '| muted:', muted, '| volume:', volume);
      }
      return DEBUG;
    },

    test: function () {
      unlock();
      setTimeout(function () {
        App.Audio.start();
        setTimeout(function () { App.Audio.eat(); }, 400);
        setTimeout(function () { App.Audio.die(); }, 900);
        setTimeout(function () { App.Audio.record(); }, 1800);
      }, 80);
    },

    start: function () {
      [440, 660, 880].forEach(function (f, i) {
        tone({ type: 'triangle', freq: f, dur: 0.15, vol: 0.5, delay: i * 0.07 });
      });
    },

    eat: function () {
      tone({ type: 'triangle', freq: 660, to: 1320, dur: 0.15, vol: 0.6 });
      tone({ type: 'sine', freq: 990, to: 1980, dur: 0.18, vol: 0.3, delay: 0.02 });
    },

    die: function () {
      tone({ type: 'sawtooth', freq: 320, to: 60, dur: 0.6, vol: 0.4 });
      tone({ type: 'square', freq: 220, to: 40, dur: 0.7, vol: 0.2, delay: 0.05 });
    },

    record: function () {
      [523, 659, 784, 1047].forEach(function (f, i) {
        tone({ type: 'triangle', freq: f, dur: 0.18, vol: 0.5, delay: i * 0.1 });
      });
    },

    tick: function () {
      tone({ type: 'sine', freq: 880, dur: 0.06, vol: 0.3 });
    }
  };

  console.log('[Audio] v1.1.1 loaded | muted =', muted,
              '| test with: App.Audio.test()');
})(window.App = window.App || {});
::@END