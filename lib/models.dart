class Task {
  String title;
  String icon;
  bool done;

  Task({
    required this.title,
    required this.icon,
    this.done = false,
  });

  Map<String, dynamic> toJson() => {
        'title': title,
        'icon': icon,
        'done': done,
      };

  factory Task.fromJson(Map<String, dynamic> json) => Task(
        title: json['title'],
        icon: json['icon'],
        done: json['done'] ?? false,
      );
}
