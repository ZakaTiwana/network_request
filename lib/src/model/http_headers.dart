/// Some Common HTTP Headers
enum HttpHeaders {
  contentTypeHeader('content-type');

  final String key;
  const HttpHeaders(this.key);
}
