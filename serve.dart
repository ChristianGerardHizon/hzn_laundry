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

  print('Starting PocketBase server (dev mode)...');
  print('HTTP:       http://$httpAddr');
  print('Data dir:   $serverDir/pb_data');
  print('Hooks dir:  $serverDir/pb_hooks');
  print('Public dir: $serverDir/pb_public');

  final process = await Process.start(
    pb,
    [
      'serve',
      '--http=$httpAddr',
      '--dir', '$serverDir/pb_data',
      '--hooksDir', '$serverDir/pb_hooks',
      '--migrationsDir', '$serverDir/pb_migrations',
      '--publicDir', '$serverDir/pb_public',
      '--dev',
    ],
    mode: ProcessStartMode.inheritStdio,
  );

  exit(await process.exitCode);
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
