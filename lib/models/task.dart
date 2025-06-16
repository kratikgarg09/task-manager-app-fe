class Task {
  final int id;
  final String title;
  final String description;
  final String? status;
  final DateTime dueDate;
  final DateTime? reminderDate;
  final String? priority;
  final String? category;
  final List<String> tags;

  Task({
    required this.id,
    required this.title,
    required this.description,
    required this.status,
    required this.dueDate,
    required this.reminderDate,
    required this.priority,
    this.category,
    required this.tags,
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
      category: json['category'],
      tags: List<String>.from(json['tags'] ?? []),
    );
  }
}
