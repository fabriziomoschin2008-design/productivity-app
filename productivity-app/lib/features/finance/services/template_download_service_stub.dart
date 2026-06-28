import 'dart:typed_data';

import 'template_download_service.dart';

Future<TemplateDownloadResult> saveTemplateBytesImpl({
  required Uint8List bytes,
  required String fileName,
  required String mimeType,
}) async {
  throw UnsupportedError(
    'Download template non supportato su questa piattaforma',
  );
}
