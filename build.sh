#!/bin/sh
# Builds the installable standalone app (index.html) from app.html (the shared Claude artifact source).
cd "$(dirname "$0")"
{ cat <<'HEAD'
<!doctype html>
<html lang="ar" dir="rtl">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1, viewport-fit=cover">
<link rel="manifest" href="manifest.json">
<link rel="icon" href="logo2.svg">
<link rel="apple-touch-icon" href="logo2-180.png">
<meta name="apple-mobile-web-app-capable" content="yes">
<meta name="mobile-web-app-capable" content="yes">
<meta name="apple-mobile-web-app-title" content="عدّاد الغازات">
<meta name="theme-color" content="#c8f169">
<style>
.installcard{display:flex;align-items:center;gap:10px;background:#8a5cf6;color:#fff;border:3px solid #2a1a3b;border-radius:18px;box-shadow:4px 4px 0 #2a1a3b;padding:10px 12px;margin:0 0 16px;transform:rotate(-1deg)}
.installcard img{width:44px;height:44px;border-radius:10px;border:2px solid #2a1a3b;flex:none}
.installcard div{flex:1;min-width:0;font-size:.85rem;line-height:1.4}
.installcard b{font-size:1rem}
.installcard button{flex:none;border:3px solid #2a1a3b;background:#ffd23f;color:#2a1a3b;border-radius:999px;padding:6px 14px;font:700 .95rem Marhey,system-ui,sans-serif;box-shadow:2px 2px 0 #2a1a3b;cursor:pointer}
.installcard .x{background:none;border:0;box-shadow:none;color:#fff;padding:0 4px;font-size:1.2rem}
.steps{display:grid;gap:10px;text-align:right;margin:10px 0}
.steps div{display:flex;gap:10px;align-items:center;background:#fff;border:2px solid #2a1a3b;border-radius:12px;padding:8px 10px}
.steps span{flex:none;width:30px;height:30px;border-radius:50%;background:#ffd23f;border:2px solid #2a1a3b;display:grid;place-items:center;font-weight:700}
</style>
</head>
<body>
HEAD
  grep -v '^<meta charset' app.html
  cat <<'TAIL'
<script>
if('serviceWorker' in navigator && location.protocol !== 'file:'){
  // When a new version takes over, reload once so the screen shows it right away.
  const hadController = !!navigator.serviceWorker.controller; let reloaded = false;
  navigator.serviceWorker.addEventListener('controllerchange', () => { if(hadController && !reloaded){ reloaded = true; location.reload(); } });
  navigator.serviceWorker.register('sw.js', {updateViaCache:'none'}).then(reg => {
    reg.update().catch(() => {});
    document.addEventListener('visibilitychange', () => { if(document.visibilityState === 'visible') reg.update().catch(() => {}); });
  }).catch(() => {});
}
(function(){
  const standalone = matchMedia('(display-mode: standalone)').matches || navigator.standalone === true;
  if(standalone) return;                                   // already opened from the home screen
  let dismissed = false; try { dismissed = localStorage.getItem('gas-install-x') === '1'; } catch(e) {}
  const ua = navigator.userAgent, ios = /iPhone|iPad|iPod/i.test(ua), inApp = /FBAN|FBAV|Instagram|WhatsApp|Line\//i.test(ua);
  let deferred = null;
  const card = document.createElement('div');
  card.className = 'installcard';
  card.innerHTML = '<img src="logo2-192.png" alt=""><div><b>📲 ثبّت التطبيق على الشاشة</b><br>يفتح بضغطة واحدة مثل أي تطبيق</div><button id="installbtn">ثبّت</button><button class="x" id="installx" title="إخفاء">✕</button>';
  if(!dismissed) document.querySelector('.status').after(card);
  addEventListener('beforeinstallprompt', e => { e.preventDefault(); deferred = e; if(!card.isConnected) document.querySelector('.status').after(card); });
  addEventListener('appinstalled', () => card.remove());
  card.addEventListener('click', async e => {
    if(e.target.id === 'installx'){ card.remove(); try { localStorage.setItem('gas-install-x','1'); } catch(_) {} return; }
    if(e.target.id !== 'installbtn') return;
    if(deferred){ deferred.prompt(); const r = await deferred.userChoice.catch(() => null); deferred = null; if(r && r.outcome === 'accepted') card.remove(); return; }
    const steps = inApp
      ? [['⋮','افتح القائمة في أعلى الشاشة'],['🌐','اختر «فتح في المتصفح» (Chrome أو Safari)'],['📲','ثم اضغط زر «ثبّت» مرة أخرى']]
      : ios
      ? [['⬆️','اضغط زر المشاركة في أسفل Safari (مربع فيه سهم)'],['➕','مرّر للأسفل واختر «إضافة إلى الشاشة الرئيسية»'],['✅','اضغط «إضافة» في الأعلى']]
      : [['⋮','اضغط القائمة ⋮ في أعلى Chrome'],['📲','اختر «تثبيت التطبيق» أو «إضافة إلى الشاشة الرئيسية»'],['✅','اضغط «تثبيت»']];
    document.getElementById('overlay').innerHTML = '<div class="overlay" data-close="1"><div class="card"><h3>📲 طريقة التثبيت' + (ios ? ' على آيفون' : '') + '</h3><div class="steps">' +
      steps.map((s,i) => '<div><span>' + s[0] + '</span>' + s[1] + '</div>').join('') +
      '</div><div class="muted">بعدها ستجد أيقونة السحابة 👑 على شاشة الهاتف</div><button class="btn" data-close="1" style="margin-top:12px">فهمت</button></div></div>';
  });
})();
</script>
</body>
</html>
TAIL
} > index.html
