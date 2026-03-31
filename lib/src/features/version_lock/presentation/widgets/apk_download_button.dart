import 'dart:io';

import 'package:background_downloader/background_downloader.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:open_filex/open_filex.dart';

import '../../../../core/packages/pocketbase/pocketbase_provider.dart';

enum _DownloadState { idle, downloading, downloaded, error }

/// A button that downloads the latest APK and opens it for installation.
///
/// Caches the downloaded file so subsequent taps re-open it without
/// re-downloading.
class ApkDownloadButton extends HookConsumerWidget {
  const ApkDownloadButton({super.key, required this.latestVersion});

  final String latestVersion;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // APK download is not supported on web
    if (kIsWeb) return const SizedBox.shrink();

    final downloadState = useState(_DownloadState.idle);
    final progress = useState(0.0);
    final cachedFilePath = useState<String?>(null);

    // Check for cached APK on mount
    useEffect(() {
      _checkCachedApk(cachedFilePath, downloadState, latestVersion);
      return null;
    }, [latestVersion]);

    Future<void> onPressed() async {
      switch (downloadState.value) {
        case _DownloadState.idle:
        case _DownloadState.error:
          await _downloadApk(
            context: context,
            downloadState: downloadState,
            progress: progress,
            cachedFilePath: cachedFilePath,
            latestVersion: latestVersion,
          );
        case _DownloadState.downloaded:
          await _openApk(context, cachedFilePath.value!);
        case _DownloadState.downloading:
          break;
      }
    }

    // Progress < 0 means the server didn't send Content-Length,
    // so the downloader can't calculate progress.
    final hasKnownProgress =
        downloadState.value == _DownloadState.downloading &&
            progress.value >= 0;
    final isDownloading = downloadState.value == _DownloadState.downloading;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (isDownloading) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: LinearProgressIndicator(
              value: hasKnownProgress ? progress.value : null,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            hasKnownProgress
                ? '${(progress.value * 100).toStringAsFixed(0)}%'
                : 'Downloading…',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 16),
        ],
        FilledButton.icon(
          onPressed: downloadState.value == _DownloadState.downloading
              ? null
              : onPressed,
          icon: Icon(_iconForState(downloadState.value)),
          label: Text(_labelForState(downloadState.value)),
        ),
      ],
    );
  }

  IconData _iconForState(_DownloadState state) {
    return switch (state) {
      _DownloadState.idle => Icons.download,
      _DownloadState.downloading => Icons.downloading,
      _DownloadState.downloaded => Icons.install_mobile,
      _DownloadState.error => Icons.refresh,
    };
  }

  String _labelForState(_DownloadState state) {
    return switch (state) {
      _DownloadState.idle => 'Download Update',
      _DownloadState.downloading => 'Downloading...',
      _DownloadState.downloaded => 'Install',
      _DownloadState.error => 'Retry Download',
    };
  }

  /// Minimum size (1 MB) to consider a cached file a valid APK.
  /// Prevents treating error responses saved as .apk as valid downloads.
  static const _minApkSizeBytes = 1024 * 1024;

  static Future<void> _checkCachedApk(
    ValueNotifier<String?> cachedFilePath,
    ValueNotifier<_DownloadState> downloadState,
    String latestVersion,
  ) async {
    // Clean up legacy unversioned APK if it exists
    final legacyTask = DownloadTask(
      url: 'https://example.com',
      baseDirectory: BaseDirectory.temporary,
      filename: 'hizonelaundry_update.apk',
    );
    final legacyPath = await legacyTask.filePath();
    final legacyFile = File(legacyPath);
    if (await legacyFile.exists()) {
      await legacyFile.delete();
    }

    // Check for version-specific cached APK
    final dummyTask = DownloadTask(
      url: 'https://example.com',
      baseDirectory: BaseDirectory.temporary,
      filename: 'hizonelaundry_update_$latestVersion.apk',
    );
    final path = await dummyTask.filePath();
    final file = File(path);
    if (await file.exists()) {
      final size = await file.length();
      if (size >= _minApkSizeBytes) {
        cachedFilePath.value = path;
        downloadState.value = _DownloadState.downloaded;
      } else {
        // Corrupted or error response — delete it
        await file.delete();
      }
    }
  }

  static Future<void> _downloadApk({
    required BuildContext context,
    required ValueNotifier<_DownloadState> downloadState,
    required ValueNotifier<double> progress,
    required ValueNotifier<String?> cachedFilePath,
    required String latestVersion,
  }) async {
    downloadState.value = _DownloadState.downloading;
    progress.value = 0.0;

    // Clean up old versioned APKs before downloading
    final versionedFilename = 'hizonelaundry_update_$latestVersion.apk';
    final dummyTask = DownloadTask(
      url: 'https://example.com',
      baseDirectory: BaseDirectory.temporary,
      filename: versionedFilename,
    );
    final targetPath = await dummyTask.filePath();
    final tempDir = File(targetPath).parent;
    if (await tempDir.exists()) {
      await for (final entity in tempDir.list()) {
        if (entity is File) {
          final name = entity.uri.pathSegments.last;
          if (name.startsWith('hizonelaundry_update_') &&
              name.endsWith('.apk') &&
              name != versionedFilename) {
            await entity.delete();
          }
        }
      }
    }

    final url = '$pocketbaseUrl/api/download/latest';

    final task = DownloadTask(
      url: url,
      baseDirectory: BaseDirectory.temporary,
      filename: versionedFilename,
      updates: Updates.statusAndProgress,
    );

    final result = await FileDownloader().download(
      task,
      onProgress: (p) {
        progress.value = p;
      },
      onStatus: (status) {
        // Status updates handled via result
      },
    );

    if (result.status == TaskStatus.complete) {
      final actualPath = await result.task.filePath();

      // Verify the downloaded file is a valid APK (not an error response)
      final downloadedFile = File(actualPath);
      if (!await downloadedFile.exists()) {
        downloadState.value = _DownloadState.error;
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Download completed but file not found.'),
            ),
          );
        }
        return;
      }

      final fileSize = await downloadedFile.length();
      if (fileSize < _minApkSizeBytes) {
        await downloadedFile.delete();
        downloadState.value = _DownloadState.error;
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Download failed. Please try again.'),
            ),
          );
        }
        return;
      }

      cachedFilePath.value = actualPath;
      downloadState.value = _DownloadState.downloaded;

      if (context.mounted) {
        await _openApk(context, actualPath);
      }
    } else {
      downloadState.value = _DownloadState.error;
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Download failed. Please try again.'),
          ),
        );
      }
    }
  }

  static Future<void> _openApk(BuildContext context, String filePath) async {
    final result = await OpenFilex.open(filePath);
    if (result.type != ResultType.done && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not open file: ${result.message}')),
      );
    }
  }
}
