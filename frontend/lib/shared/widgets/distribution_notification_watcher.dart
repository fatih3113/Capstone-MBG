// Komponen pemantau notifikasi distribusi: secara berkala mengecek API untuk notifikasi distribusi makanan baru dan menampilkan dialog pop-up konfirmasi penerimaan ompreng MBG.
import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Bungkus halaman Home dengan widget ini. Ia akan:
///  - mengambil notifikasi belum dibaca dari GET /notifications?unread=true
///  - menampilkan pop-up "Ompreng MBG akan dibagikan" (satu per satu)
///  - mengingat ID yang sudah di-popup (SharedPreferences) agar tidak muncul dua kali
///  - status "dibaca" baru berubah saat dibuka dari halaman Notifikasi (menu)
///  - memeriksa ulang tiap [interval] dan saat aplikasi kembali dibuka
///
/// Pemakaian:
///   DistributionNotificationWatcher(
///     dio: dio, // instance Dio Anda yang sudah memakai baseUrl .../api/v1 + token
///     onUnreadChanged: (n) => setState(() => unread = n), // opsional, untuk badge
///     child: Scaffold(...),
///   )
// StatefulWidget: dipakai karena widget ini memantau siklus hidup aplikasi (lifecycle) dan menjalankan timer polling berkala di latar belakang.
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

// WidgetsBindingObserver: memantau transisi aplikasi saat kembali aktif dari background (resumed) agar langsung memeriksa notifikasi baru.
class _DistributionNotificationWatcherState
    extends State<DistributionNotificationWatcher> with WidgetsBindingObserver {
  Timer? _timer;
  final Set<String> _handled = {};
  final List<Map<String, dynamic>> _queue = [];
  bool _dialogOpen = false;

  static const _kShownKey = 'shown_distribution_notif_ids';

  // Membaca riwayat ID notifikasi yang sudah pernah ditampilkan dari memori lokal SharedPreferences.
  Future<void> _loadShown() async {
    final prefs = await SharedPreferences.getInstance();
    _handled.addAll(prefs.getStringList(_kShownKey) ?? const []);
  }

  // Menyimpan daftar ID notifikasi agar dialog pop-up tidak muncul berulang kali untuk jadwal yang sama.
  Future<void> _saveShown() async {
    final prefs = await SharedPreferences.getInstance();
    final list = _handled.toList();
    await prefs.setStringList(
        _kShownKey, list.length > 200 ? list.sublist(list.length - 200) : list);
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadShown().then((_) {
      if (mounted) _check();
    });
    // Timer.periodic: memicu pengecekan berkala ke server setiap interval durasi tertentu.
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

  // Fungsi pengecekan data notifikasi yang belum dibaca dari server melalui REST API.
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

  // Mengosongkan antrean pop-up satu per satu secara berurutan agar pesan tidak bertumpuk di layar.
  Future<void> _drainQueue() async {
    if (_dialogOpen) return;
    _dialogOpen = true;
    while (_queue.isNotEmpty && mounted) {
      final n = _queue.removeAt(0);
      await _showDialog(n);
      await _saveShown();
    }
    _dialogOpen = false;
  }

  // Fungsi pembuka dialog pop-up pemberitahuan jadwal pembagian makanan bergizi.
  Future<void> _showDialog(Map<String, dynamic> n) {
    final data = (n['data'] is Map) ? Map<String, dynamic>.from(n['data']) : <String, dynamic>{};
    final items = (data['items'] as List? ?? const [])
        .map((e) => e is Map ? (e['name'] ?? '').toString() : e.toString())
        .where((s) => s.isNotEmpty)
        .toList();
    final body = (n['body'] ?? '').toString();
    final firstLine = body.split('\n').first; // baris pertama = tanggal

    // showDialog: menampilkan jendela dialog modal yang tidak dapat ditutup selain menekan tombol konfirmasi.
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      // AlertDialog: kotak dialog Material standar berisi judul, rincian menu makanan, dan tombol aksi.
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        // Row: menyusun ikon makanan ompreng dan teks judul jadwal distribusi secara horizontal.
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
        // SingleChildScrollView: mencegah overflow jika daftar menu yang akan dibagikan cukup panjang.
        content: SingleChildScrollView(
          // Column: menyusun informasi nama sekolah, tanggal, dan rincian menu makanan secara vertikal.
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
          // FilledButton: tombol konfirmasi untuk menutup dialog pemberitahuan.
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
