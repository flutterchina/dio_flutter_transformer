library dio_flutter_transformer;

import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// Dio has already implemented a [DefaultTransformer], and as the default
/// [Transformer]. If you want to custom the transformation of
/// request/response data, you can provide a [Transformer] by your self, and
/// replace the [DefaultTransformer] by setting the [dio.Transformer].
///
/// [FlutterTransformer] is especially for flutter, by which the json decoding
/// will be in background with [compute] function.

/// FlutterTransformer for Dio.
///
/// If the text to decode is under [minLength], it will not use [compute].
/// This can be an optimization since [compute] has a static performance
/// overhead, which can be avoided for small pieces of JSON.
///
/// By default, it will not use [compute] on web as it is not currently
/// supported. This can be overriden using [disableOnWeb].
class FlutterTransformer extends DefaultTransformer {
  FlutterTransformer({
    int minLength = 0,
    bool disableOnWeb = true,
  }) : super(
          jsonDecodeCallback: _getJsonParser(
            minLength: minLength,
            disableOnWeb: disableOnWeb,
          ),
        );
}

// Must be top-level function
_parseAndDecode(String response) {
  return jsonDecode(response);
}

Function _getJsonParser({
  int minLength,
  bool disableOnWeb,
}) {
  return (String text) {
    if (text.isEmpty || text.length < minLength || (kIsWeb && disableOnWeb)) {
      return _parseAndDecode(text);
    }

    return compute(_parseAndDecode, text);
  };
}
