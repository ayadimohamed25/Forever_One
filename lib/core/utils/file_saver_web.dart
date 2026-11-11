import 'dart:js_interop';
import 'dart:typed_data';
import 'package:web/web.dart' as web;

/// Web: hand the bytes to the browser as a download. The browser shows it
/// in its download bar (and opens PDFs in a tab if the user chose so).
Future<void> saveAndOpenFile(
    Uint8List bytes, String filename, String mimeType) async {
  final blob = web.Blob(
    [bytes.toJS].toJS,
    web.BlobPropertyBag(type: mimeType),
  );
  final url = web.URL.createObjectURL(blob);
  final anchor = web.document.createElement('a') as web.HTMLAnchorElement
    ..href = url
    ..download = filename
    ..style.display = 'none';
  web.document.body?.append(anchor);
  anchor.click();
  anchor.remove();
  // Give the browser a moment to start the download before freeing it.
  Future.delayed(const Duration(seconds: 30), () => web.URL.revokeObjectURL(url));
}
