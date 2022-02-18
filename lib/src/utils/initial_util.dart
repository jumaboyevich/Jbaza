import 'dart:io';

import 'package:hive/hive.dart';
import 'package:jbaza/jbaza.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:share/share.dart';

String mAppVersion = '0.0.1';
bool isEnableSentry = false;

Future<void> setupConfigs(Function app, String sentryKey,
    {List<TypeAdapter>? adapters,
    double traces = 0.5,
    String? appVersion,
    bool enableSentry = false}) async {
  if (appVersion != null) mAppVersion = appVersion;
  isEnableSentry = enableSentry;
  adapters ??= [];
  adapters.add(VMExceptionAdapter());
  await _initHive(adapters);
  if (enableSentry) {
    await SentryFlutter.init(
      (options) {
        options.dsn = sentryKey;
        options.tracesSampleRate = traces;
      },
      appRunner: app(),
    );
  } else {
    app();
  }
}

Future<void> _initHive([List<TypeAdapter>? adapters]) async {
  final directory = await getAppDirPath();
  Hive.init(directory!.path);
  adapters?.forEach((element) {
    Hive.registerAdapter(element);
  });
}

Future<Directory?> getAppDirPath({String? value}) async {
  switch (value) {
    case 'library':
      return getLibraryDirectory();
    case 'temporary':
      return getTemporaryDirectory();
    case 'support':
      return getApplicationSupportDirectory();
    case 'documents':
      return getApplicationDocumentsDirectory();
    case 'external':
      return getExternalStorageDirectory();
    case 'downloads':
      return getDownloadsDirectory();
    default:
      return getApplicationSupportDirectory();
  }
}

Future<void> jbShare(
    {String? text,
    String? path,
    String? fileTitle,
    bool isFile = false}) async {
  if (isFile) {
    if (path == null) throw VMException('Share path null');
    Share.shareFiles([path], text: fileTitle);
  } else {
    if (text == null) throw VMException('Share text null');
    Share.share(text);
  }
}
