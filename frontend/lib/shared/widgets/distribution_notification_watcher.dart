import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

/// Bungkus halaman Home dengan widget ini. Ia akan:
///  - mengambil notifikasi belum dibaca dari GET /notifications?unread=true
///  - menampilkan pop-up "Ompreng MBG akan dibagikan" (satu per satu)
///  - menandai notifikasi sebagai dibaca setelah siswa menekan "Oke"
///  - memeriksa ulang tiap [interval] dan saat aplikasi kembali dibuka
///
/// Pemakaian:
///   DistributionNotificationWatcher(
///     dio: dio, // instance Dio Anda yang sudah memakai baseUrl .../api/v1 + token
///     onUnreadChanged: (n) => setState(() => unread = n), // opsional, untuk badge
///     child: Scaffold(...),
///   )
class DistributionNotificationWatcher extends StatefulWidget {
  const DistributionNotificationWatcher({
    super.key,
    required this.dio,
    required this.child,
    this.interval = const Duration(seconds: 30),
    this.onUnreadChanged,
  });

  final Dio dio;
  final Widget child;
  final Duration interval;
  final ValueChanged<int>? onUnreadChanged;

  @override
  State<DistributionNotificationWatcher> createState() =>
      _DistributionNotificationWatcherState();
}

class _DistributionNotificationWatcherState
    extends State<DistributionNotificationWatcher> with WidgetsBindingObserver {
  Timer? _timer;
  final Set<String> _handled = {};
  final List<Map<String, dynamic>> _queue = [];
  bool _dialogOpen = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _check();
    _timer = Timer.periodic(widget.interval, (_) => _check());
  }

  @override
  void dispose() {
    _timer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _check();
  }

  Future<void> _check() async {
    try {
      final res = await widget.dio
          .get('/notifications', queryParameters: {'unread': 'true'});
      final data = (res.data['data'] ?? {}) as Map;
      final items = (data['items'] as List? ?? const []);

      if (!mounted) return;
      widget.onUnreadChanged?.call((data['unreadCount'] ?? 0) as int);

      for (final raw in items) {
        final n = Map<String, dynamic>.from(raw as Map);
        final id = n['id'].toString();
        if (n['type'] == 'distribution' && _handled.add(id)) {
          _queue.add(n);
        }
      }
      _drainQueue();
    } catch (_) {
      // Gagal sementara (offline/token habis): abaikan, dicoba lagi pada siklus berikutnya.
    }
  }

  Future<void> _drainQueue() async {
    if (_dialogOpen) return;
    _dialogOpen = true;
    while (_queue.isNotEmpty && mounted) {
      final n = _queue.removeAt(0);
      await _showDialog(n);
      try {
        await widget.dio.patch('/notifications/${n['id']}/read');
      } catch (_) {}
    }
    _dialogOpen = false;
    if (mounted) _check(); // perbarui badge setelah ditandai dibaca
  }

  Future<void> _showDialog(Map<String, dynamic> n) {
    final data = (n['data'] is Map) ? Map<String, dynamic>.from(n['data']) : <String, dynamic>{};
    final items = (data['items'] as List? ?? const [])
        .map((e) => e is Map ? (e['name'] ?? '').toString() : e.toString())
        .where((s) => s.isNotEmpty)
        .toList();
    final body = (n['body'] ?? '').toString();
    final firstLine = body.split('\n').first; // baris pertama = tanggal

    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.lunch_dining, color: Color(0xFF2E7D32)),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                (n['title'] ?? 'Ompreng MBG akan dibagikan').toString(),
                style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (data['schoolName'] != null)
                Text(data['schoolName'].toString(),
                    style: const TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 2),
              Text(firstLine, style: TextStyle(color: Colors.grey.shade700)),
              const SizedBox(height: 14),
              const Text('Menu yang akan diterima:',
                  style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 6),
              if (items.isEmpty)
                Text(body)
              else
                ...items.map(
                  (name) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('•  '),
                        Expanded(child: Text(name)),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
        actions: [
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: const Color(0xFF2E7D32)),
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Oke, mengerti'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) => widget.child;
}