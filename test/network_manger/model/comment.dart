class Comment {
  const Comment({
    required this.id,
    required this.postId,
    required this.name,
    required this.email,
    required this.body,
  });
  final int id;
  final int postId;
  final String name;
  final String email;
  final String body;

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id'],
      body: json['body'],
      email: json['email'],
      name: json['name'],
      postId: json['postId'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "postId": postId,
      "id": id,
      "name": name,
      "email": email,
      "body": body
    };
  }
}
