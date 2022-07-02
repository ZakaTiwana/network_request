typedef ParseFunction<R extends Object> = R Function(Map<String, dynamic>);

/// Tries to contvert [list] to `List<T>`
/// assumes that [list] is `List<Map<String, dynamic>>`
/// and uses the [parseJson] to parse into `T`
/// if fails the return `null`;
List<E>? tryToListParseJson<E extends Object>(
    dynamic list, ParseFunction<E> parseJson) {
  try {
    if (list == null) {
      return null;
    }
    final castList = (list as List<dynamic>)
        .map<Map<String, dynamic>>((e) => e as Map<String, dynamic>);
    final result = castList.map<E>((e) => parseJson(e)).toList();
    print('parsed total = ${result.length}');
    return result;
  } catch (e) {
    print("tryToListParseJson<$E> | msg = ${e.toString()}");
    return null;
  }
}
