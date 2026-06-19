import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_quill/flutter_quill.dart' show FlutterQuillLocalizations;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'core/services/error_handler.dart';
import 'core/services/logger_service.dart';
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

  await initializeDateFormatting('it_IT');
  AppLogger.instance.init();
  AppLogger.instance.info('App avviata');
  runApp(const ProviderScope(child: App()));
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Produttività',
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
