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
<link rel="icon" href="icon.svg">
<link rel="apple-touch-icon" href="icon-180.png">
<meta name="apple-mobile-web-app-capable" content="yes">
<meta name="mobile-web-app-capable" content="yes">
<meta name="apple-mobile-web-app-title" content="عدّاد الغازات">
<meta name="theme-color" content="#c8f169">
<style>
#install{position:fixed;bottom:calc(16px + env(safe-area-inset-bottom,0px));left:calc(16px + env(safe-area-inset-left,0px));z-index:9;border:3px solid #2a1a3b;background:#8a5cf6;color:#fff;border-radius:999px;padding:10px 16px;font:700 .95rem Marhey,system-ui,sans-serif;box-shadow:3px 3px 0 #2a1a3b;cursor:pointer}
</style>
</head>
<body>
HEAD
  grep -v '^<meta charset' app.html
  cat <<'TAIL'
<button id="install" hidden>📲 ثبّت التطبيق</button>
<script>
if('serviceWorker' in navigator && location.protocol !== 'file:') navigator.serviceWorker.register('sw.js').catch(() => {});
let deferredInstall = null;
addEventListener('beforeinstallprompt', e => { e.preventDefault(); deferredInstall = e; document.getElementById('install').hidden = false; });
document.getElementById('install').addEventListener('click', async () => {
  if(!deferredInstall) return; deferredInstall.prompt();
  await deferredInstall.userChoice.catch(() => {}); deferredInstall = null; document.getElementById('install').hidden = true;
});
addEventListener('appinstalled', () => { document.getElementById('install').hidden = true; });
</script>
</body>
</html>
TAIL
} > index.html
