/// Some Common HTTP Status
enum HttpStatus {
  unauthorized(401);

  final int code;
  const HttpStatus(this.code);
}
