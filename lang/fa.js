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
