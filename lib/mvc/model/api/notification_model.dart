class NotificationModel {
  int id;
  String title;
  String body;

  NotificationModel({
    required this.id,
    required this.title,
    required this.body,
  });

  /*@override
  String toString() => title;*/

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      body: json['body'] ?? '',
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'body': body,
    };
  }
}