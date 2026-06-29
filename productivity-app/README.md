# CUBBY

App Flutter di produttivita' personale con sync Supabase tra Windows, Android e Web.

## Stato attuale

- branding applicazione: `CUBBY`
- build Windows release pronta: `build/windows/x64/runner/Release/CUBBY.exe`
- build Android release pronta: `build/app/outputs/flutter-apk/app-release.apk`
- architettura `offline-first`: SQLite locale come base, sync cloud quando l'utente e' autenticato

## Moduli inclusi

- `Finanze`: conti, movimenti, grafici, obiettivi, import/export
- `Note`: cartelle, editor rich text, pin, allegati, tabelle, grafici, link tra note
- `Calendario`: eventi e habit tracker
- `To-do`: liste, task, priorita', scadenze
- `Tracker`: tracker personalizzati
- `Media`: film, serie TV, giochi, metadata TMDb
- `Impostazioni`: account, sync manuale, TMDb API key

## Stack

- Flutter 3.44+
- Dart 3.12+
- Riverpod
- Drift / SQLite
- GoRouter
- Supabase

## Comandi utili

```bash
flutter pub get
flutter analyze
flutter test
flutter build windows --release
flutter build apk --release
dart run build_runner build --delete-conflicting-outputs
```

## Note di rilascio beta

- Windows usa `CUBBY.exe` come nome eseguibile
- Android mostra `CUBBY` come nome app
- le icone Windows e Android derivano dal logo Cubby in `assets/branding/cubby-logo.png`
- il tema scuro non e' ancora attivo
- la build Android release al momento usa la signing config di debug: prima della pubblicazione sul Play Store va configurata una chiave release vera

## File importanti

- [lib/main.dart](C:/productivity-app-git/productivity-app/lib/main.dart)
- [lib/shared/navigation/router.dart](C:/productivity-app-git/productivity-app/lib/shared/navigation/router.dart)
- [lib/shared/widgets/nav_sidebar.dart](C:/productivity-app-git/productivity-app/lib/shared/widgets/nav_sidebar.dart)
- [lib/features/settings/screens/settings_screen.dart](C:/productivity-app-git/productivity-app/lib/features/settings/screens/settings_screen.dart)
- [SUPABASE_SYNC_SETUP.md](C:/productivity-app-git/productivity-app/SUPABASE_SYNC_SETUP.md)

