# CLAUDE.md - CUBBY

Memoria rapida del progetto per lavorare in continuita'.

## Identita' progetto

- nome brand: `CUBBY`
- repo/package Flutter ancora: `productivity_app`
- cartella di lavoro principale usata per sviluppo e build: `C:\productivity-app-git\productivity-app`

## Stato prodotto

- sync Supabase attivo tra piattaforme supportate
- schermata `Impostazioni` presente
- tema scuro non implementato
- build beta funzionanti gia' generate per Windows e Android

## Feature set attuale

- `Finanze`
- `Note`
- `Calendario`
- `To-do`
- `Tracker`
- `Media`
- `Impostazioni`

## Comandi essenziali

```bash
flutter pub get
flutter analyze
flutter test
flutter build windows --release
flutter build apk --release
dart run build_runner build --delete-conflicting-outputs
```

## Build e output

- Windows: [build/windows/x64/runner/Release/CUBBY.exe](C:/productivity-app-git/productivity-app/build/windows/x64/runner/Release/CUBBY.exe)
- Android: [build/app/outputs/flutter-apk/app-release.apk](C:/productivity-app-git/productivity-app/build/app/outputs/flutter-apk/app-release.apk)

## File da ricordare

- [lib/main.dart](C:/productivity-app-git/productivity-app/lib/main.dart)
- [lib/core/services/sync_worker.dart](C:/productivity-app-git/productivity-app/lib/core/services/sync_worker.dart)
- [lib/core/services/app_settings.dart](C:/productivity-app-git/productivity-app/lib/core/services/app_settings.dart)
- [lib/features/settings/screens/settings_screen.dart](C:/productivity-app-git/productivity-app/lib/features/settings/screens/settings_screen.dart)
- [lib/shared/navigation/router.dart](C:/productivity-app-git/productivity-app/lib/shared/navigation/router.dart)
- [lib/shared/widgets/nav_sidebar.dart](C:/productivity-app-git/productivity-app/lib/shared/widgets/nav_sidebar.dart)

## Convenzioni importanti

- non toccare `database.g.dart` manualmente
- usare `AppColors` e `AppTextStyles` invece di stili hardcoded quando si rifinisce la UI
- usare `apply_patch` per le modifiche manuali
- il sync e' `offline-first`: prima SQLite locale, poi push/pull verso Supabase
- la chiave TMDb vive in `AppSettings` e viene sincronizzata via `user_settings` o metadata fallback

## Note release

- Android `release` usa ancora signing config di debug
- branding app aggiornato a `CUBBY` per label e finestra
- icona app derivata da [assets/branding/cubby-logo.png](C:/productivity-app-git/productivity-app/assets/branding/cubby-logo.png)

