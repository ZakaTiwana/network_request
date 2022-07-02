class MockAPIUser {
  const MockAPIUser({
    required this.id,
    required this.name,
    required this.profilePic,
  });
  final int id;
  final String name;
  final String? profilePic;

  factory MockAPIUser.fromJson(Map<String, dynamic> json) {
    return MockAPIUser(
      id: json['id'],
      name: json['name'],
      profilePic: json['profilePic'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'profilePic': profilePic,
    };
  }

  Map<String, String> toMapOnlyString() {
    final map = toMap()..removeWhere((key, value) => value == null);
    return map.map((key, value) => MapEntry(key, value.toString()));
  }
}
