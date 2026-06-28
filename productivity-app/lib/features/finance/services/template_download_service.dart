import 'dart:typed_data';

import 'template_download_service_stub.dart'
    if (dart.library.html) 'template_download_service_web.dart'
    if (dart.library.io) 'template_download_service_io.dart';

class TemplateDownloadResult {
  final String? savedPath;
  final bool downloadTriggered;
  final bool cancelled;

  const TemplateDownloadResult({
    this.savedPath,
    this.downloadTriggered = false,
    this.cancelled = false,
  });
}

Future<TemplateDownloadResult> saveTemplateBytes({
  required Uint8List bytes,
  required String fileName,
  required String mimeType,
}) {
  return saveTemplateBytesImpl(
    bytes: bytes,
    fileName: fileName,
    mimeType: mimeType,
  );
}
