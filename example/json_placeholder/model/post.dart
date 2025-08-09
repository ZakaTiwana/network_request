class Post {
  const Post({
    required this.id,
    required this.userId,
    required this.title,
    required this.body,
  });
  final int id;
  final int userId;
  final String title;
  final String body;

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'],
      body: json['body'],
      title: json['title'],
      userId: json['userId'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "userId": userId,
      "id": id,
      "title": title,
      "body": body,
    };
  }
}

class PostWithDecodeError {
  const PostWithDecodeError({
    required this.id,
    required this.userId,
    required this.title,
    required this.body,
  });
  final int id;
  final int userId;
  final String title;
  final String body;

  factory PostWithDecodeError.fromJson(Map<String, dynamic> json) {
    return PostWithDecodeError(
      id: json['id'],
      body: json['body2'],
      title: json['title'],
      userId: json['userId'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "userId": userId,
      "id": id,
      "title": title,
      "body2": body,
    };
  }
}
