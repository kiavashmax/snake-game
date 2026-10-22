# Magic Serpent

A modular, bilingual (EN / FA) snake game. Pure HTML + CSS + vanilla JS.
Default language is English; switch instantly from the language pills.

## Install / update

Run `setup.bat`. It creates every file from the content blocks stored inside it.

- `[NEW ]` a file was created
- `[UPD ]` content changed on disk
- `[SAME]` unchanged, untouched
- `[CLEAN]` leftovers from an older broken run were removed

## Update workflow

1. Open `setup.bat` in a UTF-8 editor (VSCode / Notepad++).
2. Edit the block between `::@FILE:<path>` and the next `::@END`.
3. Save and re-run `setup.bat`.

To add a new file, append a new block with the file marker, then the content,
then `::@END`. The folder is created automatically.

## Play locally

Just open `index.html`. If fonts fail to load over `file://`, serve the folder
(e.g. `python -m http.server 8080` or `npx serve .`).

## Controls

| Action           | Key                                |
|------------------|------------------------------------|
| Move             | Arrow keys / WASD / swipe / D-pad  |
| Pause            | Space, P, Esc                      |
| Start / Resume   | Space, Enter, overlay button       |

## Adding a language

1. Add `lang/xx.js` via a new block in `setup.bat`, registering the pack:

```js
(function (App) {
  'use strict';
  App.i18n.register('xx', {
    name: 'Your Lang',
    dir: 'ltr',              // 'rtl' for Persian/Arabic/Hebrew
    font: 'Main',            // 'Main' for Latin, 'Main-FA' for Persian
    strings: { /* same keys as lang/en.js */ }
  });
})(window.App = window.App || {});
```

2. Add `<script src="lang/xx.js"></script>` to `index.html`.

Language pills appear automatically. Missing keys fall back to English.

## Fonts

Place `main.ttf` (Latin) and `main-fa.ttf` (Persian) in `assets/fonts/`.
They are referenced from `css/style.css` with `@font-face`.

## Tuning

Numbers that affect gameplay live in `js/core/config.js`:

- `board.cols` / `board.rows` -- grid size
- `speed.start` / `speed.max` / `speed.step` -- pacing
- `input.buffer` -- how many turns can be queued
- `input.swipe` -- minimum swipe distance in pixels
