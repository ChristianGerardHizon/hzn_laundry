import 'dart:io';

void main() async {
  final root = File(Platform.script.toFilePath()).parent.path;
  final serverDir = '$root/server';

  final pb = _findBinary(root, serverDir);
  if (pb == null) {
    stderr.writeln('Error: pocketbase binary not found in PATH or server/');
    exit(1);
  }

  const httpAddr = '127.0.0.1:8088';
  final env = _loadEnvForPocketBase(root, httpAddr);
  final public = _resolvePublicDir(root, serverDir);

  print('Starting PocketBase server (dev mode)...');
  print('HTTP:       http://$httpAddr');
  print('Data dir:   $serverDir/pb_data');
  print('Hooks dir:  $serverDir/pb_hooks');
  print('Public dir: ${public.path}');
  if (public.isRawWebFallback) {
    stderr.writeln(
      'WARNING: Serving raw web/ (Flutter templates). /login will stick on splash.',
    );
    stderr.writeln(
      'Run: flutter build web --dart-define=ENV=dev',
    );
    stderr.writeln(
      'Then restart serve (uses build/web), or copy build/web → server/pb_public.',
    );
  }
  print(
    'Resend:     ${env.containsKey('RESEND_API_KEY') ? 'RESEND_API_KEY set' : 'RESEND_API_KEY missing (invite/history emails will skip)'}',
  );
  print('App URL:    ${env['APP_BASE_URL']}');

  final process = await Process.start(
    pb,
    [
      'serve',
      '--http=$httpAddr',
      '--dir',
      '$serverDir/pb_data',
      '--hooksDir',
      '$serverDir/pb_hooks',
      '--migrationsDir',
      '$serverDir/pb_migrations',
      '--publicDir',
      public.path,
      '--dev',
    ],
    environment: env,
    mode: ProcessStartMode.inheritStdio,
  );

  exit(await process.exitCode);
}

/// Loads repo-root `.env` into a copy of [Platform.environment] for PocketBase
/// hooks (`$os.getenv`). Sets local defaults for APP_BASE_URL / APP_ENV.
Map<String, String> _loadEnvForPocketBase(String root, String httpAddr) {
  final env = Map<String, String>.from(Platform.environment);
  final dotenv = File('$root/.env');
  if (dotenv.existsSync()) {
    for (final raw in dotenv.readAsLinesSync()) {
      final line = raw.trim();
      if (line.isEmpty || line.startsWith('#')) continue;
      final eq = line.indexOf('=');
      if (eq <= 0) continue;
      final key = line.substring(0, eq).trim();
      var value = line.substring(eq + 1).trim();
      if ((value.startsWith('"') && value.endsWith('"')) ||
          (value.startsWith("'") && value.endsWith("'"))) {
        value = value.substring(1, value.length - 1);
      }
      if (key.isNotEmpty) env[key] = value;
    }
  }

  env.putIfAbsent('APP_BASE_URL', () => 'http://$httpAddr');
  env.putIfAbsent('APP_ENV', () => 'dev');
  return env;
}

/// Resolved public dir for PocketBase `--publicDir`.
class _PublicDir {
  const _PublicDir(this.path, {this.isRawWebFallback = false});

  final String path;

  /// True when serving source `web/` templates (Flutter SPA will not boot).
  final bool isRawWebFallback;
}

/// Prefer deployed `server/pb_public`, then local `build/web`, then raw `web/`
/// so invite/reset/oauth static pages work without a Flutter web build.
_PublicDir _resolvePublicDir(String root, String serverDir) {
  final deployed = Directory('$serverDir/pb_public');
  if (deployed.existsSync()) return _PublicDir(deployed.path);

  final built = Directory('$root/build/web');
  if (built.existsSync()) return _PublicDir(built.path);

  return _PublicDir('$root/web', isRawWebFallback: true);
}

String? _findBinary(String root, String serverDir) {
  final isWindows = Platform.isWindows;

  // Check PATH
  final which = isWindows ? 'where' : 'which';
  final result = Process.runSync(which, ['pocketbase']);
  if (result.exitCode == 0) return 'pocketbase';

  // Check server/ directory
  final localBin = '$serverDir/pocketbase${isWindows ? '.exe' : ''}';
  if (File(localBin).existsSync()) return localBin;

  return null;
}
