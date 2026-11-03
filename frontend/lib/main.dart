// Titik masuk utama aplikasi (entry point): menginisialisasi binding Flutter, format tanggal lokal Indonesia, registrasi seluruh Provider global, dan konfigurasi tema serta router aplikasi.
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'providers/auth_provider.dart';
import 'providers/scan_provider.dart';
import 'providers/history_provider.dart';
import 'providers/menu_provider.dart';
import 'providers/theme_provider.dart';
import 'data/services/auth_service.dart';
import 'data/services/history_service.dart';
import 'data/services/menu_service.dart';
import 'data/services/stats_service.dart';
import 'providers/nutrition_provider.dart';
import 'providers/sppg_provider.dart';
import 'data/services/sppg_service.dart';
import 'providers/notification_provider.dart'; 
     

// Fungsi main(): fungsi yang pertama kali dieksekusi saat aplikasi Android/iOS dijalankan.
void main() async {
  // WidgetsFlutterBinding.ensureInitialized(): memastikan sistem Flutter engine sudah siap sebelum menjalankan kode async.
  WidgetsFlutterBinding.ensureInitialized();

  // initializeDateFormatting: memuat lokalisasi bahasa Indonesia ('id_ID') untuk format penanggalan tanggal dan hari.
  await initializeDateFormatting('id_ID', null);

  // runApp(): menjalankan widget akar aplikasi ke layar perangkat.
  runApp(const MbgNutritionApp());
}

// StatelessWidget: widget akar aplikasi yang membungkus seluruh hierarki widget dengan Provider state management.
class MbgNutritionApp extends StatelessWidget {
  const MbgNutritionApp({super.key});

  @override
  Widget build(BuildContext context) {
    // MultiProvider: mendaftarkan seluruh state provider di tingkat teratas agar bisa diakses dari halaman mana pun di aplikasi.
    return MultiProvider(
      providers: [
        // ThemeProvider: mengatur mode tema terang/gelap aplikasi.
        ChangeNotifierProvider(create: (_) => ThemeProvider()..loadTheme()),
        // NotificationProvider: mengelola daftar notifikasi jadwal distribusi menu MBG.
        ChangeNotifierProvider(create: (_) => NotificationProvider()),

        // AuthProvider: mengelola sesi login, pendaftaran pengguna, dan profil siswa/petugas.
        ChangeNotifierProvider(
          create: (_) => AuthProvider(AuthService()),
        ),

        // ScanProvider: mengelola alur foto kamera, deteksi model AI, dan analisis nutrisi.
        ChangeNotifierProvider(create: (_) => ScanProvider()),

        // HistoryProvider: memuat riwayat rekaman pemindaian gizi makanan pengguna.
        ChangeNotifierProvider(
          create: (_) =>
              HistoryProvider(HistoryService(), statsService: StatsService()),
        ),

        // MenuProvider: mengambil data jadwal menu makanan bergizi gratis dari server.
        ChangeNotifierProvider(
          create: (_) => MenuProvider(MenuService()),
        ),

        // NutritionProvider: mengelola data agregat dan statistik grafik gizi mingguan/bulanan.
        ChangeNotifierProvider(
          create: (_) => NutritionProvider(StatsService()),
        ),

        // SppgProvider: mengambil daftar kantor SPPG dan wilayah sekolah untuk opsi registrasi.
        ChangeNotifierProvider(
          create: (_) => SppgProvider(SppgService()),
        ),
      ],
      // Consumer<ThemeProvider>: mendengarkan perubahan mode tema agar aplikasi otomatis berganti antara light theme dan dark theme.
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          // AppRouter.createRouter: membuat konfigurasi routing GoRouter yang terhubung dengan state autentikasi.
          final router = AppRouter.createRouter(context);
          // MaterialApp.router: kerangka utama Material Design yang mendukung navigasi deklaratif GoRouter.
          return MaterialApp.router(
            title: 'MBG Nutrition',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.themeMode,
            routerConfig: router,
          );
        },
      ),
    );
  }
}
