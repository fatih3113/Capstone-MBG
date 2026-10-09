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

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Indonesian locale for date formatting
  await initializeDateFormatting('id_ID', null);

  runApp(const MbgNutritionApp());
}

class MbgNutritionApp extends StatelessWidget {
  const MbgNutritionApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Theme
        ChangeNotifierProvider(create: (_) => ThemeProvider()..loadTheme()),

        // Auth
        ChangeNotifierProvider(
          create: (_) => AuthProvider(AuthService()),
        ),

        // Scan
        ChangeNotifierProvider(create: (_) => ScanProvider()),

        // History
        ChangeNotifierProvider(
          create: (_) =>
              HistoryProvider(HistoryService(), statsService: StatsService()),
        ),

        // Menu
        ChangeNotifierProvider(
          create: (_) => MenuProvider(MenuService()),
        ),

        // Nutrition Stats
        ChangeNotifierProvider(
          create: (_) => NutritionProvider(StatsService()),
        ),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          final router = AppRouter.createRouter(context);
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
