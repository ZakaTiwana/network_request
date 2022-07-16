class Todo {
  const Todo({
    required this.id,
    required this.userId,
    required this.title,
    required this.completed,
  });
  final int id;
  final int userId;
  final String title;
  final bool completed;

  factory Todo.fromJson(Map<String, dynamic> json) {
    return Todo(
      id: json['id'],
      completed: json['completed'],
      title: json['title'],
      userId: json['userId'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "userId": userId,
      "id": id,
      "title": title,
      "completed": completed,
    };
  }
}
