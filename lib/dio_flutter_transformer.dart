library dio_flutter_transformer;

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// Dio has already implemented a [DefaultTransformer], and as the default
/// [Transformer]. If you want to custom the transformation of
/// request/response data, you can provide a [Transformer] by your self, and
/// replace the [DefaultTransformer] by setting the [dio.Transformer].
///
/// [FlutterTransformer] is especially for flutter, by which the json decoding
/// will be in background with [compute] function.

class FlutterTransformer extends Transformer {
  Future<String> transformRequest(RequestOptions options) async {
    var data = options.data ?? "";
    if (data is! String) {
      if (options.contentType.mimeType == ContentType.json.mimeType) {
        return json.encode(options.data);
      } else if (data is Map) {
        return Transformer.urlEncodeMap(data);
      }
    }
    return data.toString();
  }

  /// As an agreement, you must return the [response]
  /// when the Options.responseType is [ResponseType.stream].
  Future transformResponse(
    RequestOptions options,
    ResponseBody response,
  ) async {
    if (options.responseType == ResponseType.stream) {
      return response;
    }
    // Handle timeout
    Stream<List<int>> stream = response.stream;
    if (options.receiveTimeout > 0) {
      stream = stream
          .timeout(new Duration(milliseconds: options.receiveTimeout),
              onTimeout: (EventSink sink) {
        sink.addError(new DioError(
          message: "Receiving data timeout[${options.receiveTimeout}ms]",
          type: DioErrorType.RECEIVE_TIMEOUT,
        ));
        sink.close();
      });
    }
    int length = 0;
    int received = 0;
    bool showDownloadProgress = options.onReceiveProgress != null;
    if (showDownloadProgress) {
      length = int.parse(
          response.headers.value(HttpHeaders.contentLengthHeader) ?? "-1");
    }
    Completer completer = new Completer();
    Stream _stream = stream.transform<List<int>>(
        StreamTransformer.fromHandlers(handleData: (data, sink) {
      sink.add(data);
      if (showDownloadProgress) {
        received += data.length;
        options.onReceiveProgress(received, length);
      }
    }));
    List<int> buffer = new List<int>();
    StreamSubscription subscription;
    subscription = _stream.listen(
      (element) => buffer.addAll(element),
      onError: (e) => completer.completeError(e),
      onDone: () => completer.complete(),
      cancelOnError: true,
    );
    options.cancelToken?.whenCancel?.then((_) {
      return subscription.cancel();
    });
    await completer.future;
    if (options.responseType == ResponseType.bytes) return buffer;
    String responseBody = utf8.decode(buffer, allowMalformed: true);
    if (responseBody != null &&
        responseBody.isNotEmpty &&
        options.responseType == ResponseType.json &&
        response.headers.contentType?.mimeType == ContentType.json.mimeType) {
      // Use Compute
      return compute(_parseAndDecode, responseBody);
    }
    return responseBody;
  }
}

// Must be top-level function
_parseAndDecode(String response) {
  return jsonDecode(response);
}
