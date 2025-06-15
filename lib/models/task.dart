class Task {
  final int id;
  final String title;
  final String description;
  final String? status;
  final DateTime dueDate;
  final DateTime? reminderDate;
  final String? priority;

  Task({
    required this.id,
    required this.title,
    required this.description,
    required this.status,
    required this.dueDate,
    required this.reminderDate,
    required this.priority,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      status: json['status'] as String?,
      dueDate: DateTime.parse(json['dueDate']),
      reminderDate: json['reminderTime'] != null
          ? DateTime.parse(json['reminderTime'])
          : null,
      priority: json['priority'] as String?,
    );
  }
}
