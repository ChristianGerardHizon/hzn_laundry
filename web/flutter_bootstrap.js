{{flutter_js}}
{{flutter_build_config}}

// Do not pass serviceWorkerSettings. Flutter's generated worker precaches the
// entire app before first frame and can leave the HTML splash up for minutes.
const _swCleanupFlag = 'hznLaundrySwCleanupDone';

function loadFlutterEngine() {
  _flutter.loader.load({
    config: {
      canvasKitBaseUrl: "canvaskit/",
    },
  });
}

function versionKey(payload) {
  if (!payload || typeof payload !== 'object') return null;
  const version = payload.version;
  const build = payload.build_number;
  if (version == null && build == null) return null;
  return `${version ?? ''}+${build ?? ''}`;
}

function startVersionPoll() {
  let currentVersion = null;

  const readVersion = () =>
    fetch('version.json', { cache: 'no-store' }).then((res) => {
      if (!res.ok) return null;
      return res.json();
    });

  readVersion()
    .then((payload) => {
      currentVersion = versionKey(payload);
    })
    .catch(() => {});

  let reloadingForDeploy = false;

  setInterval(() => {
    readVersion()
      .then((payload) => {
        const next = versionKey(payload);
        if (currentVersion && next && next !== currentVersion) {
          reloadForNewDeploy();
        }
        if (!currentVersion && next) {
          currentVersion = next;
        }
      })
      .catch(() => {});
  }, 60000);

  function reloadForNewDeploy() {
    if (reloadingForDeploy) return;
    reloadingForDeploy = true;
    const bootAssets = [
      'index.html',
      'flutter_bootstrap.js',
      'flutter.js',
      'main.dart.js',
      'main.dart.wasm',
    ];
    Promise.all(
      bootAssets.map((path) =>
        fetch(path, { cache: 'reload' }).catch(() => null),
      ),
    ).finally(() => {
      location.reload();
    });
  }
}

async function retireLegacyServiceWorker() {
  if (!('serviceWorker' in navigator)) return false;

  const hadController = !!navigator.serviceWorker.controller;
  const registrations = await navigator.serviceWorker.getRegistrations();
  if (!hadController && registrations.length === 0) return false;

  if (sessionStorage.getItem(_swCleanupFlag) === '1') return false;

  await Promise.all(registrations.map((reg) => reg.unregister()));
  if (window.caches) {
    const keys = await caches.keys();
    await Promise.all(keys.map((key) => caches.delete(key)));
  }

  if (hadController) {
    sessionStorage.setItem(_swCleanupFlag, '1');
    location.reload();
    return true;
  }
  return false;
}

retireLegacyServiceWorker()
  .then((reloading) => {
    if (reloading) return;
    sessionStorage.removeItem(_swCleanupFlag);
    loadFlutterEngine();
    startVersionPoll();
  })
  .catch(() => {
    loadFlutterEngine();
    startVersionPoll();
  });
