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
