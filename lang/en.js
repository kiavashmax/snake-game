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
