import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';

import 'template_download_service.dart';

Future<TemplateDownloadResult> saveTemplateBytesImpl({
  required Uint8List bytes,
  required String fileName,
  required String mimeType,
}) async {
  final outputPath = await FilePicker.platform.saveFile(
    dialogTitle: 'Scegli dove salvare il template',
    fileName: fileName,
    type: FileType.custom,
    allowedExtensions: const ['xlsx'],
    bytes: Platform.isAndroid || Platform.isIOS ? bytes : null,
  );

  if (outputPath == null || outputPath.isEmpty) {
    return const TemplateDownloadResult(cancelled: true);
  }

  if (!Platform.isAndroid && !Platform.isIOS) {
    await File(outputPath).writeAsBytes(bytes, flush: true);
  }

  return TemplateDownloadResult(savedPath: outputPath);
}
