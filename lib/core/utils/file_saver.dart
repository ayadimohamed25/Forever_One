// Hands a generated file (a PDF report) to the user, the right way for each
// platform: a browser download on web, save-then-open on mobile/desktop.
// The platform file is picked at compile time, so web builds never touch
// dart:io (which is what made the report fail in the browser).
export 'file_saver_io.dart' if (dart.library.js_interop) 'file_saver_web.dart';
