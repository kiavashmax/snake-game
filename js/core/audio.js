(function (App) {
  'use strict';

  var ctx = null;
  var master = null;
  var muted = !!App.storage.get('muted', false);
  var MASTER_GAIN = 1.5;
  var DEBUG = false;

  function log() {
    if (DEBUG && window.console && console.log) {
      console.log.apply(console, ['[Audio]'].concat([].slice.call(arguments)));
    }
  }

  function ensure() {
    if (ctx) return true;
    var AC = window.AudioContext || window.webkitAudioContext;
    if (!AC) { log('no Web Audio API'); return false; }

    try { ctx = new AC(); } catch (e) { log('ctx failed', e); return false; }

    master = ctx.createGain();
    master.gain.value = muted ? 0 : MASTER_GAIN;

    var sat = ctx.createWaveShaper();
    var n = 2048;
    var curve = new Float32Array(n);
    for (var i = 0; i < n; i++) {
      var x = (i / (n - 1)) * 2 - 1;
      curve[i] = Math.tanh(x * 1.2);
    }
    sat.curve = curve;
    sat.oversample = '2x';

    var comp = ctx.createDynamicsCompressor();
    comp.threshold.value = -10;
    comp.knee.value = 4;
    comp.ratio.value = 6;
    comp.attack.value = 0.003;
    comp.release.value = 0.15;

    master.connect(sat);
    sat.connect(comp);
    comp.connect(ctx.destination);

    log('ctx ready | state=' + ctx.state + ' | muted=' + muted);
    return true;
  }

  function unlock() {
    if (!ensure()) return;
    if (ctx.state === 'suspended') {
      var p = ctx.resume();
      if (p && p.then) p.then(function () { log('resumed'); }).catch(function(){});
    }
    try {
      var o = ctx.createOscillator();
      var g = ctx.createGain();
      g.gain.value = 0.0001;
      o.connect(g); g.connect(master);
      o.start(); o.stop(ctx.currentTime + 0.02);
    } catch (e) {}
  }

  function tone(opts) {
    if (!ctx || muted) return;
    if (ctx.state !== 'running') {
      if (ctx.state === 'suspended' && (opts.__retry || 0) < 2) {
        opts.__retry = (opts.__retry || 0) + 1;
        ctx.resume().then(function () {
          if (ctx.state === 'running') tone(opts);
        }).catch(function(){});
      }
      return;
    }
    try {
      var now = ctx.currentTime;
      var osc = ctx.createOscillator();
      var g = ctx.createGain();
      var type = opts.type || 'sine';
      var f = opts.freq || 440;
      var to = opts.to || f;
      var dur = opts.dur || 0.15;
      var vol = opts.vol == null ? 0.7 : opts.vol;
      var delay = opts.delay || 0;

      osc.type = type;
      osc.frequency.setValueAtTime(f, now + delay);
      if (to !== f) osc.frequency.exponentialRampToValueAtTime(to, now + delay + dur);

      g.gain.setValueAtTime(0.0001, now + delay);
      g.gain.linearRampToValueAtTime(vol, now + delay + 0.008);
      g.gain.exponentialRampToValueAtTime(0.0001, now + delay + dur);

      osc.connect(g);
      g.connect(master);
      osc.start(now + delay);
      osc.stop(now + delay + dur + 0.05);
    } catch (e) { log('tone err', e); }
  }

  function noise(opts) {
    if (!ctx || muted) return;
    if (ctx.state !== 'running') return;
    try {
      var dur = opts.dur || 0.1;
      var vol = opts.vol == null ? 0.25 : opts.vol;
      var delay = opts.delay || 0;
      var hp = opts.hp || 1000;
      var now = ctx.currentTime;

      var samples = Math.floor(ctx.sampleRate * dur);
      var buf = ctx.createBuffer(1, samples, ctx.sampleRate);
      var data = buf.getChannelData(0);
      for (var i = 0; i < samples; i++) data[i] = Math.random() * 2 - 1;

      var src = ctx.createBufferSource();
      src.buffer = buf;

      var filter = ctx.createBiquadFilter();
      filter.type = 'highpass';
      filter.frequency.value = hp;

      var g = ctx.createGain();
      g.gain.setValueAtTime(vol, now + delay);
      g.gain.exponentialRampToValueAtTime(0.0001, now + delay + dur);

      src.connect(filter);
      filter.connect(g);
      g.connect(master);
      src.start(now + delay);
      src.stop(now + delay + dur);
    } catch (e) { log('noise err', e); }
  }

  App.Audio = {
    unlock: unlock,
    isMuted: function () { return muted; },

    setMuted: function (m) {
      muted = !!m;
      if (master) master.gain.value = muted ? 0 : MASTER_GAIN;
      App.storage.set('muted', muted);
    },

    toggle: function () {
      App.Audio.setMuted(!muted);
      return muted;
    },

    reset: function () {
      muted = false;
      App.storage.set('muted', false);
      if (master) master.gain.value = MASTER_GAIN;
    },

    debug: function (on) {
      DEBUG = !!on;
      if (DEBUG) log('debug | ctx:', ctx ? ctx.state : 'null', '| muted:', muted);
      return DEBUG;
    },

    test: function () {
      unlock();
      setTimeout(function () {
        App.Audio.start();
        setTimeout(function () { App.Audio.eat(1); }, 500);
        setTimeout(function () { App.Audio.eat(5); }, 800);
        setTimeout(function () { App.Audio.milestone(); }, 1100);
        setTimeout(function () { App.Audio.speedUp(); }, 1500);
        setTimeout(function () { App.Audio.die(); }, 1900);
        setTimeout(function () { App.Audio.record(); }, 2700);
      }, 80);
    },

    start: function () {
      [523.25, 659.25, 783.99, 1046.50].forEach(function (f, i) {
        tone({ type: 'triangle', freq: f, dur: 0.18, vol: 0.85, delay: i * 0.08 });
        tone({ type: 'sine', freq: f / 2, dur: 0.22, vol: 0.4, delay: i * 0.08 });
      });
    },

    eat: function (streak) {
      var s = Math.min(streak || 0, 10);
      var base = 660 + s * 25;
      tone({ type: 'triangle', freq: base, to: base * 1.8, dur: 0.13, vol: 0.9 });
      tone({ type: 'sine', freq: base * 1.5, to: base * 2.5, dur: 0.15, vol: 0.55, delay: 0.02 });
      noise({ dur: 0.05, vol: 0.22, hp: 2500 });
    },

    die: function () {
      tone({ type: 'sawtooth', freq: 300, to: 50, dur: 0.8, vol: 0.85 });
      tone({ type: 'square', freq: 200, to: 30, dur: 0.9, vol: 0.5, delay: 0.08 });
      tone({ type: 'sine', freq: 120, to: 40, dur: 0.9, vol: 0.6, delay: 0.15 });
      noise({ dur: 0.3, vol: 0.18, hp: 200, delay: 0.2 });
    },

    record: function () {
      [523.25, 659.25, 783.99, 1046.50, 1318.51].forEach(function (f, i) {
        tone({ type: 'triangle', freq: f, dur: 0.22, vol: 0.85, delay: i * 0.11 });
        tone({ type: 'sine', freq: f * 2, dur: 0.18, vol: 0.35, delay: i * 0.11 });
      });
    },

    milestone: function () {
      [784, 988, 1175, 1568].forEach(function (f, i) {
        tone({ type: 'sine', freq: f, dur: 0.22, vol: 0.8, delay: i * 0.07 });
      });
      tone({ type: 'triangle', freq: 392, dur: 0.35, vol: 0.5 });
    },

    speedUp: function () {
      tone({ type: 'triangle', freq: 400, to: 1400, dur: 0.32, vol: 0.8 });
      tone({ type: 'sine', freq: 800, to: 2800, dur: 0.36, vol: 0.4, delay: 0.05 });
    },

    pause: function () {
      tone({ type: 'sine', freq: 660, to: 330, dur: 0.18, vol: 0.7 });
      tone({ type: 'sine', freq: 330, to: 165, dur: 0.22, vol: 0.5, delay: 0.08 });
    },

    resume: function () {
      tone({ type: 'sine', freq: 330, to: 660, dur: 0.18, vol: 0.7 });
      tone({ type: 'sine', freq: 660, to: 990, dur: 0.22, vol: 0.5, delay: 0.08 });
    },

    hover: function () {
      tone({ type: 'sine', freq: 880, dur: 0.05, vol: 0.35 });
    },

    click: function () {
      tone({ type: 'triangle', freq: 1200, to: 1800, dur: 0.08, vol: 0.6 });
    },

    muteSound: function (on) {
      if (on) tone({ type: 'sine', freq: 660, to: 330, dur: 0.18, vol: 0.7 });
      else    tone({ type: 'sine', freq: 330, to: 660, dur: 0.18, vol: 0.7 });
    },

    tick: function () {
      tone({ type: 'sine', freq: 880, dur: 0.06, vol: 0.45 });
    }
  };

  console.log('[Audio] v1.2.0 loaded | muted=' + muted + ' | test: App.Audio.test()');
})(window.App = window.App || {});
