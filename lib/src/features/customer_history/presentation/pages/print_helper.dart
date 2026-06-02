// Conditional import: stub for non-web, real impl for web.
export 'print_helper_stub.dart'
    if (dart.library.js_interop) 'print_helper_web.dart';
