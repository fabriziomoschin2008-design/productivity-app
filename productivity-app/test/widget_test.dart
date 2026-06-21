import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_quill/flutter_quill.dart';

void main() {
  test('quill editor config is valid', () {
    const config = QuillEditorConfig();
    expect(config.customShortcuts, isEmpty);
    expect(config.customActions, isEmpty);
  });
}
