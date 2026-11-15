// Whether the platform asks for reduced motion outside Flutter's own
// accessibility flags. On web this reads the browser's
// `prefers-reduced-motion` media query; elsewhere MediaQuery already carries it.
export 'reduced_motion_io.dart'
    if (dart.library.js_interop) 'reduced_motion_web.dart';
