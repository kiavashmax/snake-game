@echo off
setlocal
title Magic Serpent - v1.2.0 - Setup / Update
cd /d "%~dp0"

set "APP_VERSION=1.2.0"

echo.
echo   ================================================
echo     MAGIC SERPENT  -  v%APP_VERSION%  -  setup / update
echo   ================================================
echo.

if exist "%~dp0ndex.html" (
    echo   [CLEAN] Removing leftovers from the old Substring bug...
    del /q "%~dp0ndex.html" 2>nul
    if exist "%~dp0s"   rmdir /s /q "%~dp0s"   2>nul
    if exist "%~dp0ss"  rmdir /s /q "%~dp0ss"  2>nul
    if exist "%~dp0ang" rmdir /s /q "%~dp0ang" 2>nul
    echo   [CLEAN] Done.
    echo.
)

echo   Extracting files from this script...
echo.

set "MG_BAT=%~f0"

powershell -NoProfile -ExecutionPolicy Bypass -Command ^
  "$bat = $env:MG_BAT;" ^
  "$lines = [IO.File]::ReadAllLines($bat, [Text.Encoding]::UTF8);" ^
  "$root = Split-Path $bat -Parent;" ^
  "$marker = '::@FILE:';" ^
  "$cur = $null;" ^
  "$buf = New-Object Collections.ArrayList;" ^
  "$new = 0; $upd = 0; $same = 0;" ^
  "foreach ($ln in $lines) {" ^
  "  if ($ln.StartsWith($marker)) { $cur = $ln.Substring($marker.Length).Trim(); $buf.Clear() }" ^
  "  elseif ($ln -eq '::@END' -and $cur) {" ^
  "    $c = ($buf -join [Environment]::NewLine) + [Environment]::NewLine;" ^
  "    $d = Join-Path $root $cur;" ^
  "    $p = Split-Path $d -Parent;" ^
  "    if (-not (Test-Path -LiteralPath $p)) { New-Item -ItemType Directory -Path $p -Force | Out-Null };" ^
  "    $act = 'NEW';" ^
  "    if (Test-Path -LiteralPath $d) {" ^
  "      $e = [IO.File]::ReadAllText($d, [Text.Encoding]::UTF8);" ^
  "      if ($e -eq $c) { $act = 'SAME' } else { $act = 'UPD' }" ^
  "    }" ^
  "    if ($act -ne 'SAME') { [IO.File]::WriteAllText($d, $c, (New-Object Text.UTF8Encoding($false))) };" ^
  "    Write-Host ('  [{0,-4}] {1}' -f $act, $cur);" ^
  "    if ($act -eq 'NEW') { $new++ } elseif ($act -eq 'UPD') { $upd++ } else { $same++ };" ^
  "    $cur = $null" ^
  "  }" ^
  "  elseif ($cur) { $buf.Add($ln) | Out-Null }" ^
  "}" ^
  "Write-Host '';" ^
  "Write-Host ('  Summary: {0} new, {1} updated, {2} unchanged' -f $new, $upd, $same);" ^
  "exit 0"

if errorlevel 1 (
    echo.
    echo   [FAIL] Setup did not finish. Check the messages above.
    echo.
    pause
    exit /b 1
)

if not exist "%~dp0index.html" (
    echo.
    echo   [FAIL] index.html was not created. Something is wrong with this bat.
    echo.
    pause
    exit /b 1
)

echo.
echo   Done. Files are in: %~dp0
echo   Version: %APP_VERSION%
echo   Open index.html in a browser to play.
echo.
pause
exit /b 0

:: ============================================================
::  FILE CONTENT BLOCKS  (v1.2.0)
:: ============================================================


::@FILE:index.html
<!doctype html>
<html lang="en" dir="ltr">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width,initial-scale=1,viewport-fit=cover,user-scalable=no">
<meta name="theme-color" content="#05050a">
<title>Magic Serpent</title>
<link rel="stylesheet" href="css/style.css">
</head>
<body>

<header class="hud">
  <div class="hud__item">
    <span class="hud__label" data-i18n="hud.score">Score</span>
    <span class="hud__value" id="score">0</span>
  </div>
  <div class="hud__item">
    <span class="hud__label" data-i18n="hud.best">Best</span>
    <span class="hud__value" id="best">0</span>
  </div>
</header>

<main class="stage">
  <canvas id="board" width="600" height="600"></canvas>
</main>

<nav class="dpad" id="dpad">
  <button class="dpad__btn dpad__btn--up"    type="button" data-dir="up">&#9650;</button>
  <button class="dpad__btn dpad__btn--left"  type="button" data-dir="left">&#9664;</button>
  <button class="dpad__btn dpad__btn--right" type="button" data-dir="right">&#9654;</button>
  <button class="dpad__btn dpad__btn--down"  type="button" data-dir="down">&#9660;</button>
</nav>

<div class="overlay" id="overlay">
  <div class="overlay__panel">
    <h1 class="overlay__title" id="overlayTitle">Magic Serpent</h1>
    <p class="overlay__text" id="overlayText"></p>
    <div class="overlay__score is-hidden" id="overlayScore"></div>
    <button class="btn" id="overlayBtn" type="button">Start</button>
  </div>
</div>

<button class="mute" id="muteBtn" type="button" aria-label="Sound">&#128266;</button>
<div class="langs" id="langs"></div>
<div class="version">v1.2.0</div>

<script src="js/core/config.js"></script>
<script src="js/core/storage.js"></script>
<script src="js/core/audio.js"></script>
<script src="js/core/i18n.js"></script>

<script src="lang/en.js"></script>
<script src="lang/fa.js"></script>

<script src="js/core/input.js"></script>
<script src="js/game/snake.js"></script>
<script src="js/game/food.js"></script>
<script src="js/game/particles.js"></script>
<script src="js/game/renderer.js"></script>
<script src="js/game/game.js"></script>

<script src="js/ui.js"></script>
<script src="js/main.js"></script>
</body>
</html>
::@END


::@FILE:css/style.css
@font-face {
  font-family: 'Main';
  src: url('../assets/fonts/main.ttf') format('truetype');
  font-weight: 400;
  font-style: normal;
  font-display: swap;
}

@font-face {
  font-family: 'Main-FA';
  src: url('../assets/fonts/main-fa.ttf') format('truetype');
  font-weight: 400;
  font-style: normal;
  font-display: swap;
}

:root {
  --gold: #d4af37;
  --gold-light: #f7e19b;
  --ink: #e6e1d4;
  --ink-dim: #8d877b;
  --font-game: 'Main', Tahoma, system-ui, sans-serif;
  --radius: 14px;
}

*, *::before, *::after { box-sizing: border-box; }

html, body {
  margin: 0;
  height: 100%;
  overflow: hidden;
}

body {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  gap: clamp(8px, 2vh, 18px);
  padding: max(10px, env(safe-area-inset-top)) 12px max(10px, env(safe-area-inset-bottom));
  background: radial-gradient(ellipse at 50% -10%, #1c1033 0%, #0b0716 45%, #05050a 100%);
  color: var(--ink);
  font-family: var(--font-game);
  font-size: 16px;
  user-select: none;
  -webkit-user-select: none;
  -webkit-tap-highlight-color: transparent;
  touch-action: none;
}

.hud {
  display: flex;
  align-items: center;
  gap: clamp(16px, 5vw, 40px);
  padding: 8px 20px;
  border-radius: 999px;
  background: rgba(255, 255, 255, 0.03);
  border: 1px solid rgba(212, 175, 55, 0.16);
}

.hud__item { display: flex; align-items: baseline; gap: 8px; }

.hud__label {
  color: var(--ink-dim);
  font-size: 0.76rem;
  letter-spacing: 1px;
  text-transform: uppercase;
}

.hud__value {
  color: var(--gold);
  font-weight: 700;
  font-size: 1.1rem;
  min-width: 1.4ch;
  text-align: center;
  font-variant-numeric: tabular-nums;
}

.stage {
  position: relative;
  width: min(92vw, 54vh, 560px);
  aspect-ratio: 1 / 1;
}

.stage canvas {
  display: block;
  width: 100%;
  height: 100%;
  border-radius: var(--radius);
  border: 1px solid rgba(212, 175, 55, 0.22);
  background: radial-gradient(circle at 50% 42%, rgba(46, 30, 82, 0.55), rgba(7, 6, 14, 0.96) 72%);
  box-shadow: 0 0 60px rgba(120, 80, 220, 0.12), inset 0 0 70px rgba(0, 0, 0, 0.65);
  touch-action: none;
}

.dpad {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  grid-template-rows: repeat(3, 1fr);
  gap: clamp(6px, 1.5vw, 10px);
  width: min(220px, 52vw, 32vh);
  aspect-ratio: 1 / 1;
  direction: ltr;
}

.dpad__btn {
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 0;
  border: 1px solid rgba(212, 175, 55, 0.25);
  border-radius: 14px;
  background: linear-gradient(180deg, rgba(45, 30, 72, 0.9), rgba(22, 15, 38, 0.9));
  color: var(--gold);
  font-size: clamp(1rem, 4vw, 1.35rem);
  font-family: var(--font-game);
  cursor: pointer;
  touch-action: none;
  transition: transform 0.08s ease, background 0.12s ease;
}

.dpad__btn:active {
  background: linear-gradient(180deg, rgba(212, 175, 55, 0.35), rgba(140, 110, 30, 0.35));
  transform: scale(0.93);
}

.dpad__btn--up    { grid-area: 1 / 2; }
.dpad__btn--left  { grid-area: 2 / 1; }
.dpad__btn--right { grid-area: 2 / 3; }
.dpad__btn--down  { grid-area: 3 / 2; }

@media (hover: hover) and (pointer: fine) {
  .dpad { display: none; }
}

.overlay {
  position: fixed;
  inset: 0;
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 20px;
  background: rgba(5, 4, 12, 0.78);
  backdrop-filter: blur(10px);
  -webkit-backdrop-filter: blur(10px);
  z-index: 60;
  transition: opacity 0.2s ease, visibility 0.2s ease;
}

.overlay.is-hidden {
  opacity: 0;
  visibility: hidden;
  pointer-events: none;
}

.overlay__panel {
  width: min(420px, 100%);
  padding: 32px 26px 28px;
  text-align: center;
  border-radius: 22px;
  background: linear-gradient(180deg, rgba(30, 20, 52, 0.96), rgba(12, 9, 22, 0.98));
  border: 1px solid rgba(212, 175, 55, 0.22);
  box-shadow: 0 30px 80px rgba(0, 0, 0, 0.6), 0 0 60px rgba(212, 175, 55, 0.06);
}

.overlay__title {
  margin: 0 0 10px;
  font-size: clamp(1.5rem, 6vw, 2rem);
  font-weight: 700;
  color: var(--gold);
  text-shadow: 0 0 26px rgba(212, 175, 55, 0.35);
}

.overlay__text {
  margin: 0 0 18px;
  min-height: 1.8em;
  color: var(--ink-dim);
  font-size: 0.95rem;
  line-height: 1.9;
}

.overlay__score { margin: 0 0 20px; }
.overlay__score.is-hidden { display: none; }

.overlay__label {
  display: block;
  color: var(--ink-dim);
  font-size: 0.78rem;
  letter-spacing: 1px;
  text-transform: uppercase;
}

.overlay__big {
  display: block;
  color: var(--gold);
  font-size: clamp(2.4rem, 12vw, 3.4rem);
  font-weight: 700;
  line-height: 1.25;
  text-shadow: 0 0 30px rgba(212, 175, 55, 0.4);
  font-variant-numeric: tabular-nums;
}

.btn {
  display: inline-block;
  padding: 14px 42px;
  border: none;
  border-radius: 999px;
  background: linear-gradient(180deg, #f0d27a, #c9a12f);
  color: #100b06;
  font-family: inherit;
  font-size: 1rem;
  font-weight: 700;
  letter-spacing: 0.5px;
  cursor: pointer;
  box-shadow: 0 10px 30px rgba(212, 175, 55, 0.22);
  transition: transform 0.1s ease, box-shadow 0.15s ease;
}

.btn:active {
  transform: scale(0.96);
  box-shadow: 0 4px 14px rgba(212, 175, 55, 0.25);
}

.langs {
  position: fixed;
  top: max(10px, env(safe-area-inset-top));
  inset-inline-end: 12px;
  display: flex;
  gap: 6px;
  z-index: 70;
}

.lang {
  padding: 6px 12px;
  border-radius: 999px;
  border: 1px solid rgba(212, 175, 55, 0.2);
  background: rgba(20, 14, 34, 0.8);
  color: var(--ink-dim);
  font-family: inherit;
  font-size: 0.72rem;
  letter-spacing: 0.4px;
  cursor: pointer;
  transition: color 0.15s ease, background 0.15s ease;
}

.lang.is-active {
  color: #100b06;
  background: linear-gradient(180deg, #f0d27a, #c9a12f);
  border-color: transparent;
}

.mute {
  position: fixed;
  top: max(10px, env(safe-area-inset-top));
  inset-inline-start: 12px;
  width: 40px;
  height: 40px;
  padding: 0;
  border-radius: 999px;
  border: 1px solid rgba(212, 175, 55, 0.2);
  background: rgba(20, 14, 34, 0.8);
  color: var(--gold);
  font-family: inherit;
  font-size: 1.1rem;
  line-height: 1;
  cursor: pointer;
  z-index: 70;
  display: flex;
  align-items: center;
  justify-content: center;
  transition: color 0.15s ease, opacity 0.15s ease;
}

.mute.is-muted {
  color: var(--ink-dim);
  opacity: 0.6;
}

.version {
  position: fixed;
  bottom: max(8px, env(safe-area-inset-bottom));
  inset-inline-end: 12px;
  color: var(--ink-dim);
  font-size: 0.65rem;
  letter-spacing: 0.5px;
  opacity: 0.45;
  pointer-events: none;
  z-index: 5;
}
::@END


::@FILE:js/core/config.js
(function (App) {
  'use strict';

  App.config = {
    board: { cols: 20, rows: 20, cell: 30 },
    speed: { start: 7, max: 16, step: 0.28 },
    input: { buffer: 3, swipe: 24 },
    snake: { startLength: 3 },
    colors: { spark: ['#d4af37', '#f0d27a', '#ff9a3c', '#a78bfa'] },
    storageKey: 'magic-serpent'
  };
})(window.App = window.App || {});
::@END


::@FILE:js/core/storage.js
(function (App) {
  'use strict';

  var KEY = App.config.storageKey;
  var fallback = {};

  function readAll() {
    try { return JSON.parse(localStorage.getItem(KEY) || '{}') || {}; }
    catch (e) { return fallback; }
  }

  function writeAll(data) {
    try { localStorage.setItem(KEY, JSON.stringify(data)); }
    catch (e) { fallback = data; }
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
::@END


::@FILE:js/core/audio.js
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
::@END


::@FILE:js/core/i18n.js
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
::@END


::@FILE:js/core/input.js
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
::@END


::@FILE:js/game/snake.js
(function (App) {
  'use strict';

  var DIRS = {
    up:    { x: 0,  y: -1 },
    down:  { x: 0,  y: 1  },
    left:  { x: -1, y: 0  },
    right: { x: 1,  y: 0  }
  };

  function clone(cell) { return { x: cell.x, y: cell.y }; }

  function Snake(board, bufferSize) {
    this.cols = board.cols;
    this.rows = board.rows;
    this.bufferSize = bufferSize || 3;
    this.reset();
  }

  Snake.DIRS = DIRS;

  Snake.prototype.reset = function () {
    var startX = Math.floor(this.cols / 2);
    var startY = Math.floor(this.rows / 2);
    var length = App.config.snake.startLength;
    this.cells = [];
    for (var i = 0; i < length; i++) this.cells.push({ x: startX - i, y: startY });
    this.prevCells = this.cells.map(clone);
    this.dir = DIRS.right;
    this.pending = [];
    this.grow = 0;
    this.alive = true;
  };

  Snake.prototype.queue = function (name) {
    var next = DIRS[name];
    if (!next) return;
    var last = this.pending.length ? this.pending[this.pending.length - 1] : this.dir;
    if (next.x === last.x && next.y === last.y) return;
    if (next.x === -last.x && next.y === -last.y) return;
    if (this.pending.length >= this.bufferSize) return;
    this.pending.push(next);
  };

  Snake.prototype.feed = function () { this.grow += 1; };

  Snake.prototype.isOccupied = function (x, y) {
    for (var i = 0; i < this.cells.length; i++) {
      if (this.cells[i].x === x && this.cells[i].y === y) return true;
    }
    return false;
  };

  Snake.prototype.bitesItself = function (head) {
    var limit = this.grow > 0 ? this.cells.length : this.cells.length - 1;
    for (var i = 0; i < limit; i++) {
      if (this.cells[i].x === head.x && this.cells[i].y === head.y) return true;
    }
    return false;
  };

  Snake.prototype.step = function () {
    if (this.pending.length) this.dir = this.pending.shift();
    var head = { x: this.cells[0].x + this.dir.x, y: this.cells[0].y + this.dir.y };
    if (head.x < 0) head.x = this.cols - 1;
    else if (head.x >= this.cols) head.x = 0;
    if (head.y < 0) head.y = this.rows - 1;
    else if (head.y >= this.rows) head.y = 0;
    this.prevCells = this.cells.map(clone);
    if (this.bitesItself(head)) { this.alive = false; return { died: true, head: head }; }
    this.cells.unshift(head);
    if (this.grow > 0) this.grow -= 1;
    else this.cells.pop();
    return { died: false, head: head };
  };

  App.Snake = Snake;
})(window.App = window.App || {});
::@END


::@FILE:js/game/food.js
(function (App) {
  'use strict';

  function Food(board) {
    this.cols = board.cols;
    this.rows = board.rows;
    this.x = 0;
    this.y = 0;
  }

  Food.prototype.spawn = function (snake) {
    var free = [];
    for (var y = 0; y < this.rows; y++) {
      for (var x = 0; x < this.cols; x++) {
        if (!snake.isOccupied(x, y)) free.push({ x: x, y: y });
      }
    }
    if (!free.length) return false;
    var pick = free[Math.floor(Math.random() * free.length)];
    this.x = pick.x;
    this.y = pick.y;
    return true;
  };

  App.Food = Food;
})(window.App = window.App || {});
::@END


::@FILE:js/game/particles.js
(function (App) {
  'use strict';

  function Particles() { this.list = []; }

  Particles.prototype.clear = function () { this.list.length = 0; };

  Particles.prototype.burst = function (gx, gy, cellSize, colors, amount) {
    var cx = gx * cellSize + cellSize / 2;
    var cy = gy * cellSize + cellSize / 2;
    for (var i = 0; i < (amount || 12); i++) {
      var angle = Math.random() * Math.PI * 2;
      var speed = 1 + Math.random() * 3;
      this.list.push({
        x: cx, y: cy,
        vx: Math.cos(angle) * speed,
        vy: Math.sin(angle) * speed,
        life: 1,
        decay: 0.02 + Math.random() * 0.03,
        radius: 1.5 + Math.random() * 2,
        color: colors[Math.floor(Math.random() * colors.length)]
      });
    }
  };

  Particles.prototype.update = function (dt) {
    var frame = dt / 16.67;
    for (var i = this.list.length - 1; i >= 0; i--) {
      var p = this.list[i];
      p.x += p.vx * frame;
      p.y += p.vy * frame;
      p.vy += 0.12 * frame;
      p.vx *= 0.99;
      p.life -= p.decay * frame;
      if (p.life <= 0) this.list.splice(i, 1);
    }
  };

  Particles.prototype.draw = function (ctx) {
    for (var i = 0; i < this.list.length; i++) {
      var p = this.list[i];
      ctx.globalAlpha = p.life > 0 ? p.life : 0;
      ctx.fillStyle = p.color;
      ctx.beginPath();
      ctx.arc(p.x, p.y, p.radius, 0, Math.PI * 2);
      ctx.fill();
    }
    ctx.globalAlpha = 1;
  };

  App.Particles = Particles;
})(window.App = window.App || {});
::@END


::@FILE:js/game/renderer.js
(function (App) {
  'use strict';

  var cfg = App.config;

  function roundRect(ctx, x, y, w, h, r) {
    ctx.beginPath();
    ctx.moveTo(x + r, y);
    ctx.lineTo(x + w - r, y);
    ctx.quadraticCurveTo(x + w, y, x + w, y + r);
    ctx.lineTo(x + w, y + h - r);
    ctx.quadraticCurveTo(x + w, y + h, x + w - r, y + h);
    ctx.lineTo(x + r, y + h);
    ctx.quadraticCurveTo(x, y + h, x, y + h - r);
    ctx.lineTo(x, y + r);
    ctx.quadraticCurveTo(x, y, x + r, y);
    ctx.closePath();
  }

  function diamond(ctx, cx, cy, rx, ry) {
    ctx.beginPath();
    ctx.moveTo(cx, cy - ry);
    ctx.lineTo(cx + rx, cy);
    ctx.lineTo(cx, cy + ry);
    ctx.lineTo(cx - rx, cy);
    ctx.closePath();
  }

  function Renderer(canvas) {
    this.canvas = canvas;
    this.ctx = canvas.getContext('2d');
    this.cell = cfg.board.cell;
    this.width = cfg.board.cols * this.cell;
    this.height = cfg.board.rows * this.cell;
    this.dpr = Math.min(window.devicePixelRatio || 1, 2);
    canvas.width = this.width * this.dpr;
    canvas.height = this.height * this.dpr;
    this.ctx.setTransform(this.dpr, 0, 0, this.dpr, 0, 0);
    this.gridLayer = this.buildGrid();
  }

  Renderer.prototype.buildGrid = function () {
    var off = document.createElement('canvas');
    off.width = this.canvas.width;
    off.height = this.canvas.height;
    var g = off.getContext('2d');
    g.setTransform(this.dpr, 0, 0, this.dpr, 0, 0);
    g.fillStyle = 'rgba(212, 175, 55, 0.09)';
    var c = this.cell;
    for (var x = 1; x < cfg.board.cols; x++) {
      for (var y = 1; y < cfg.board.rows; y++) {
        g.fillRect(x * c - 0.5, y * c - 0.5, 1, 1);
      }
    }
    return off;
  };

  Renderer.prototype.draw = function (state) {
    var ctx = this.ctx;
    ctx.clearRect(0, 0, this.width, this.height);
    ctx.drawImage(this.gridLayer, 0, 0, this.width, this.height);
    this.drawFood(state.food, state.now);
    this.drawSnake(state.snake, state.alpha);
    state.particles.draw(ctx);
  };

  Renderer.prototype.drawFood = function (food, now) {
    var ctx = this.ctx;
    var c = this.cell;
    var cx = food.x * c + c / 2;
    var cy = food.y * c + c / 2;
    var pulse = Math.sin(now / 220);
    var size = c * 0.3 + pulse * 1.2;
    ctx.save();
    ctx.shadowColor = 'rgba(212, 175, 55, 0.9)';
    ctx.shadowBlur = 16 + pulse * 6;
    ctx.fillStyle = '#f7e19b';
    diamond(ctx, cx, cy, size, size * 1.15);
    ctx.fill();
    ctx.shadowBlur = 0;
    ctx.fillStyle = '#d4af37';
    diamond(ctx, cx, cy, size * 0.42, size * 0.5);
    ctx.fill();
    ctx.restore();
  };

  Renderer.prototype.drawSnake = function (snake, alpha) {
    var ctx = this.ctx;
    var c = this.cell;
    var cells = snake.cells;
    var prev = snake.prevCells;
    var count = cells.length;
    var pad = 2.4;
    var size = c - pad * 2;

    for (var i = count - 1; i >= 0; i--) {
      var cur = cells[i];
      var old = prev[i] || cur;
      var px, py;
      if (Math.abs(cur.x - old.x) > 1 || Math.abs(cur.y - old.y) > 1) {
        px = cur.x; py = cur.y;
      } else {
        px = old.x + (cur.x - old.x) * alpha;
        py = old.y + (cur.y - old.y) * alpha;
      }
      var x = px * c + pad;
      var y = py * c + pad;
      var isHead = i === 0;
      var fade = 1 - (i / Math.max(count, 1)) * 0.45;
      var grad = ctx.createLinearGradient(x, y, x + size, y + size);
      if (isHead) {
        grad.addColorStop(0, '#fff6d0');
        grad.addColorStop(1, '#d4af37');
      } else {
        grad.addColorStop(0, 'rgba(212, 175, 55, ' + (0.92 * fade) + ')');
        grad.addColorStop(1, 'rgba(118, 96, 46, ' + (0.92 * fade) + ')');
      }
      ctx.save();
      if (isHead) {
        ctx.shadowColor = 'rgba(212, 175, 55, 0.85)';
        ctx.shadowBlur = 16;
      }
      roundRect(ctx, x, y, size, size, Math.min(9, size / 3));
      ctx.fillStyle = grad;
      ctx.fill();
      ctx.restore();
      if (isHead) this.drawEyes(x, y, size, snake.dir);
    }
  };

  Renderer.prototype.drawEyes = function (x, y, size, dir) {
    var ctx = this.ctx;
    var cx = x + size / 2 + dir.x * size * 0.16;
    var cy = y + size / 2 + dir.y * size * 0.16;
    var ox = -dir.y * size * 0.19;
    var oy = dir.x * size * 0.19;
    var r = size * 0.085;
    ctx.fillStyle = '#0a0a12';
    ctx.beginPath();
    ctx.arc(cx + ox, cy + oy, r, 0, Math.PI * 2);
    ctx.arc(cx - ox, cy - oy, r, 0, Math.PI * 2);
    ctx.fill();
  };

  App.Renderer = Renderer;
})(window.App = window.App || {});
::@END


::@FILE:js/game/game.js
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
::@END


::@FILE:js/ui.js
(function (App) {
  'use strict';

  var dom = {};
  var actions = {};
  var overlayState = { kind: 'menu', score: 0, best: 0, record: false };
  var lastHover = 0;

  function byId(id) { return document.getElementById(id); }

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

  function hoverSound() {
    var now = Date.now();
    if (now - lastHover < 90) return;
    lastHover = now;
    if (App.Audio) App.Audio.hover();
  }

  function clickSound() {
    if (App.Audio) { App.Audio.unlock(); App.Audio.click(); }
  }

  function wireButtonSounds(el) {
    if (!el) return;
    el.addEventListener('mouseenter', hoverSound);
    el.addEventListener('pointerdown', clickSound);
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
      wireButtonSounds(btn);
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
      wireButtonSounds(dom.button);

      var extraButtons = document.querySelectorAll('.dpad__btn, .mute');
      for (var i = 0; i < extraButtons.length; i++) wireButtonSounds(extraButtons[i]);

      App.i18n.onChange(function () {
        renderLanguages();
        renderOverlay();
      });

      renderLanguages();
      renderOverlay();
    },

    setScore: function (value) { dom.score.textContent = value; },
    setBest: function (value) { dom.best.textContent = value; },

    showOverlay: function (kind, data) {
      data = data || {};
      overlayState.kind = kind;
      overlayState.score = data.score || 0;
      overlayState.best = data.best || 0;
      overlayState.record = !!data.record;
      renderOverlay();
      dom.overlay.classList.remove('is-hidden');
    },

    hideOverlay: function () { dom.overlay.classList.add('is-hidden'); }
  };
})(window.App = window.App || {});
::@END


::@FILE:js/main.js
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
::@END


::@FILE:lang/en.js
(function (App) {
  'use strict';

  App.i18n.register('en', {
    name: 'English',
    dir: 'ltr',
    font: 'Main',
    strings: {
      app: { title: 'Magic Serpent' },
      hud: { score: 'Score', best: 'Best' },
      menu: {
        title: 'Magic Serpent',
        hint: 'Eat diamonds, grow longer, never bite yourself.',
        start: 'Start'
      },
      paused: {
        title: 'Paused',
        hint: 'Press Space or the button to keep going.',
        resume: 'Resume'
      },
      over: {
        title: 'Game Over',
        record: 'New Record!',
        score: 'Score',
        best: 'Best',
        retry: 'Play Again'
      },
      audio: { on: 'Sound on', off: 'Sound off' }
    }
  });
})(window.App = window.App || {});
::@END


::@FILE:lang/fa.js
(function (App) {
  'use strict';

  App.i18n.register('fa', {
    name: 'فارسی',
    dir: 'rtl',
    font: 'Main-FA',
    strings: {
      app: { title: 'مار جادویی' },
      hud: { score: 'امتیاز', best: 'رکورد' },
      menu: {
        title: 'مار جادویی',
        hint: 'الماس‌ها رو بخور، بزرگ‌تر شو، به خودت نزن.',
        start: 'شروع بازی'
      },
      paused: {
        title: 'توقف',
        hint: 'برای ادامه Space رو بزن یا دکمه رو لمس کن.',
        resume: 'ادامه'
      },
      over: {
        title: 'بازی تموم شد',
        record: 'رکورد جدید!',
        score: 'امتیاز',
        best: 'رکورد',
        retry: 'دوباره بازی کن'
      },
      audio: { on: 'صدا روشن', off: 'صدا خاموش' }
    }
  });
})(window.App = window.App || {});
::@END


::@FILE:README.md
# Magic Serpent

A modular, bilingual (EN / FA) snake game. Pure HTML + CSS + vanilla JS.

## Version

Current: v1.2.0

## Install / update

Run setup.bat. It creates every file from the content blocks stored inside it.

- [NEW ] a file was created
- [UPD ] content changed on disk
- [SAME] unchanged, untouched

## Controls

| Action           | Key                                |
|------------------|------------------------------------|
| Move             | Arrow keys / WASD / swipe / D-pad  |
| Pause            | Space, P, Esc                      |
| Start / Resume   | Space, Enter, overlay button       |

## Audio

Synthesized in real time with the Web Audio API (no audio files).
Signals flow through a WaveShaper (soft saturation) and a DynamicsCompressor
for louder output without clipping. Mute preference is saved to localStorage.

Available SFX: start, eat (pitch scales with streak), milestone (every 10 pts),
speedUp (every 5 pts), pause, resume, die, record, hover, click, mute, tick.

Diagnostics:
  App.Audio.test()          plays all SFX in sequence
  App.Audio.debug(true)     enables verbose console logging
  App.Audio.reset()         clears the mute flag

## Changelog

### v1.2.0
- Louder audio engine: soft saturation + compressor, master gain 1.5.
- New SFX: milestone, speedUp, pause, resume, hover, click, mute toggle.
- Eat pitch scales with streak (caps at +10).
- Mute button now plays an audible confirmation.

### v1.1.0
- Added browser audio via the Web Audio API: eat, die, record, start.
- Added a mute toggle button (persisted in localStorage).
- Added a version tag in the bottom-right corner.

### v1.0.0
- Initial release.
::@END


::@FILE:LICENSE
MIT License

Copyright (c) 2026 kiavashmax

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
::@END


::@FILE:.gitignore
node_modules/
.DS_Store
Thumbs.db
*.log
::@END