import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_quill/flutter_quill.dart' show FlutterQuillLocalizations;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/notifications/notification_service.dart';
import 'core/config/supabase_config.dart';
import 'core/services/app_settings.dart';
import 'core/services/sync_repository.dart';
import 'core/services/sync_worker.dart';
import 'core/services/error_handler.dart';
import 'core/services/logger_service.dart';
import 'data/local/database.dart';
import 'features/finance/providers/finance_providers.dart';
import 'core/theme/app_theme.dart';
import 'shared/navigation/router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  FlutterError.onError = (details) {
    AppLogger.instance.error(details.exceptionAsString(), details.stack);
  };
  WidgetsBinding.instance.platformDispatcher.onError = (error, stack) {
    AppErrorHandler.handle(error, stack, showUi: false);
    return true;
  };

  await Supabase.initialize(
    url: SupabaseConfig.url,
    publishableKey: SupabaseConfig.publishableKey,
  );
  await initializeDateFormatting('it_IT');
  await AppSettings.init();
  await AppLogger.instance.init();
  AppLogger.instance.info('App avviata');
  await NotificationService.instance.init();

  final db = AppDatabase();
  final syncWorker = SyncWorker(
    db,
    SyncRepository(db),
    Supabase.instance.client,
  );

  runApp(AppRoot(db: db, syncWorker: syncWorker));
}

class AppRoot extends StatefulWidget {
  final AppDatabase db;
  final SyncWorker syncWorker;

  const AppRoot({
    super.key,
    required this.db,
    required this.syncWorker,
  });

  @override
  State<AppRoot> createState() => _AppRootState();
}

class _AppRootState extends State<AppRoot> {
  @override
  void initState() {
    super.initState();
    widget.syncWorker.start();
  }

  @override
  void dispose() {
    widget.syncWorker.dispose();
    widget.db.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      overrides: [
        databaseProvider.overrideWithValue(widget.db),
      ],
      child: const App(),
    );
  }
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Cubby',
      theme: appTheme,
      routerConfig: appRouter,
      scaffoldMessengerKey: AppErrorHandler.scaffoldKey,
      debugShowCheckedModeBanner: false,
      localizationsDelegates: const [
        FlutterQuillLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('it'),
        Locale('en'),
      ],
    );
  }
}
