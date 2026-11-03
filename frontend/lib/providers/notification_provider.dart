// State management notifikasi: mengelola daftar pemberitahuan jadwal menu MBG, menghitung jumlah pesan belum dibaca, dan sinkronisasi status baca ke backend.
import 'package:flutter/foundation.dart';
import '../core/network/dio_client.dart';
import '../data/models/notification_model.dart';

// ChangeNotifier: mengelola state daftar notifikasi pengguna dan memperbarui tampilan saat ada pemberitahuan baru.
class NotificationProvider extends ChangeNotifier {
  List<NotificationModel> _items = [];
  int _unreadCount = 0;
  bool _isLoading = false;
  String? _error;

  List<NotificationModel> get items => _items;
  int get unreadCount => _unreadCount;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Dipanggil watcher tiap polling. Kalau ada notifikasi baru, daftar ikut dimuat ulang.
  void setUnread(int n) {
    if (n == _unreadCount) return;
    final increased = n > _unreadCount;
    _unreadCount = n;
    notifyListeners();
    if (increased) load(silent: true);
  }

  // Mengambil daftar notifikasi terbaru dari endpoint API server.
  Future<void> load({bool silent = false}) async {
    if (!silent) {
      _isLoading = true;
      _error = null;
      notifyListeners();
    }
    try {
      final res = await DioClient.instance.get('/notifications');
      final data = (res.data['data'] ?? {}) as Map;
      _items = (data['items'] as List? ?? const [])
          .map((e) =>
              NotificationModel.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
      _unreadCount = (data['unreadCount'] ?? 0) as int;
    } catch (_) {
      if (!silent) _error = 'Gagal memuat notifikasi';
    }
    _isLoading = false;
    notifyListeners();
  }

  // Menandai satu item notifikasi spesifik sebagai telah dibaca.
  Future<void> markRead(String id) async {
    final i = _items.indexWhere((n) => n.id == id);
    if (i == -1 || _items[i].isRead) return;
    _items[i] = _items[i].copyWith(isRead: true);
    _unreadCount = _unreadCount > 0 ? _unreadCount - 1 : 0;
    notifyListeners();
    try {
      await DioClient.instance.patch('/notifications/$id/read');
    } catch (_) {}
  }

  // Menandai seluruh pesan notifikasi sekaligus sebagai telah dibaca.
  Future<void> markAllRead() async {
    if (_unreadCount == 0) return;
    _items = _items.map((n) => n.copyWith(isRead: true)).toList();
    _unreadCount = 0;
    notifyListeners();
    try {
      await DioClient.instance.patch('/notifications/read-all');
    } catch (_) {}
  }
}
