class NotificationModel {
  final String id;
  final String title;
  final String body;
  final String type;
  final Map<String, dynamic> data;
  final bool isRead;
  final DateTime createdAt;

  const NotificationModel({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    required this.data,
    required this.isRead,
    required this.createdAt,
  });

  String get schoolName => (data['schoolName'] ?? '').toString();

  DateTime? get scheduleDate {
    final raw = data['date'];
    return raw == null ? null : DateTime.tryParse(raw.toString())?.toLocal();
  }

  List<Map<String, dynamic>> get items => (data['items'] as List? ?? const [])
      .whereType<Map>()
      .map((e) => Map<String, dynamic>.from(e))
      .toList();

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'].toString(),
      title: (json['title'] ?? '').toString(),
      body: (json['body'] ?? '').toString(),
      type: (json['type'] ?? 'distribution').toString(),
      data: json['data'] is Map
          ? Map<String, dynamic>.from(json['data'] as Map)
          : <String, dynamic>{},
      isRead: json['isRead'] == true,
      createdAt:
          DateTime.tryParse((json['createdAt'] ?? '').toString())?.toLocal() ??
              DateTime.now(),
    );
  }

  NotificationModel copyWith({bool? isRead}) => NotificationModel(
        id: id,
        title: title,
        body: body,
        type: type,
        data: data,
        isRead: isRead ?? this.isRead,
        createdAt: createdAt,
      );
}