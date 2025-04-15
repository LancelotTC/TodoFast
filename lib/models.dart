class Task {
  String title;
  bool done;
  String icon;
  DateTime dateAdded;

  Task({
    required this.title,
    this.done = false,
    this.icon = '📝',
    DateTime? dateAdded,
  }) : dateAdded = dateAdded ?? DateTime.now();

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      title: json['title'],
      done: json['done'] ?? false,
      icon: json['icon'] ?? '📝',
      dateAdded: DateTime.tryParse(json['dateAdded'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'done': done,
      'icon': icon,
      'dateAdded': dateAdded.toIso8601String(),
    };
  }
}
