import 'dart:async';

import 'package:http/http.dart' as http;

import 'model/type_def.dart';

class RequestWithProgress extends http.Request with http.Abortable {
  RequestWithProgress(
    super.method,
    super.url, {
    Progress? onProgress,
    Future<void>? abortTrigger,
  })  : onProgress = onProgress,
        abortTrigger = abortTrigger;

  final Progress? onProgress;
  @override
  final Future<void>? abortTrigger;

  int _bytesCount = 0;
  int _totalBytes = 0;

  @override
  http.ByteStream finalize() {
    final byteStream = super.finalize();
    _totalBytes = contentLength;

    return http.ByteStream(
      byteStream.transform(StreamTransformer.fromHandlers(
        handleData: (data, sink) {
          _bytesCount += data.length;
          onProgress?.call(_bytesCount, _totalBytes, _bytesCount / _totalBytes);
          sink.add(data);
        },
        handleError: (error, stack, sink) {
          sink.addError(error, stack);
        },
        handleDone: (sink) {
          sink.close();
        },
      )),
    );
  }
}
