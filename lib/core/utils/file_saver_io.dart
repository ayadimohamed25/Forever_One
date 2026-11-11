import 'dart:io';
import 'dart:typed_data';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';

/// Mobile/desktop: write to the documents folder, then open it with the
/// system viewer.
Future<void> saveAndOpenFile(
    Uint8List bytes, String filename, String mimeType) async {
  final dir = await getApplicationDocumentsDirectory();
  final file = File('${dir.path}/$filename');
  await file.writeAsBytes(bytes, flush: true);
  await OpenFilex.open(file.path, type: mimeType);
}
