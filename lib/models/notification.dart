// filename: models/notification.dart

class AppNotification {
  final String title;
  final String description;
  final String time;
  bool isRead;

  AppNotification({
    required this.title,
    required this.description,
    required this.time,
    this.isRead = false,
  });
}