import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

class AppPaths {
  AppPaths._();

  static Future<Directory> appSupportDir() async {
    if (kIsWeb) {
      throw UnsupportedError('Filesystem non disponibile sul Web');
    }
    final dir = await getApplicationSupportDirectory();
    if (!dir.existsSync()) {
      dir.createSync(recursive: true);
    }
    return dir;
  }

  static Future<Directory> logsDir() async {
    final base = await appSupportDir();
    final dir = Directory('${base.path}${Platform.pathSeparator}logs');
    if (!dir.existsSync()) {
      dir.createSync(recursive: true);
    }
    return dir;
  }

  static Future<Directory> attachmentsDir(String ownerId) async {
    final base = await appSupportDir();
    final dir = Directory(
      '${base.path}${Platform.pathSeparator}attachments${Platform.pathSeparator}$ownerId',
    );
    if (!dir.existsSync()) {
      dir.createSync(recursive: true);
    }
    return dir;
  }

  static Future<Directory> exportsDir() async {
    final base = await appSupportDir();
    final dir = Directory('${base.path}${Platform.pathSeparator}exports');
    if (!dir.existsSync()) {
      dir.createSync(recursive: true);
    }
    return dir;
  }

  static Future<Directory> templatesDir() async {
    final base = await appSupportDir();
    final dir = Directory('${base.path}${Platform.pathSeparator}templates');
    if (!dir.existsSync()) {
      dir.createSync(recursive: true);
    }
    return dir;
  }
}
