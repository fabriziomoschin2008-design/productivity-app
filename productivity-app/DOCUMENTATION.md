# Documentazione - CUBBY

## Panoramica

`CUBBY` e' un'app Flutter di produttivita' personale con approccio `offline-first`:

- database locale SQLite tramite Drift
- sync cloud con Supabase quando l'utente effettua il login
- supporto reale a Windows, Android e Web

Lo stato attuale copre questi moduli:

| Modulo | Stato | Note |
|---|---|---|
| Finanze | pronto | conti, movimenti, grafici, obiettivi, import/export |
| Note | pronto | editor rich text, cartelle, pin, allegati, embed |
| Calendario | pronto | eventi e abitudini |
| To-do | pronto | task, liste, priorita', scadenze |
| Tracker | pronto | tracker personalizzati |
| Media | pronto | film, serie TV, giochi, supporto TMDb |
| Impostazioni | pronto | account, sync manuale, chiave TMDb |

## Architettura

### Dati locali

- `Drift` gestisce schema, query e stream reattivi
- `SQLite` e' la fonte primaria locale
- tutte le entita' sincronizzabili hanno anche il campo `user_id` lato cloud

### Sync

- `Supabase` gestisce autenticazione e database remoto
- `SyncWorker` invia le modifiche locali e scarica gli aggiornamenti remoti
- il sync parte solo con sessione autenticata
- al logout i dati sincronizzati locali possono essere puliti per evitare copie residue

File centrali:

- [lib/core/services/sync_worker.dart](C:/productivity-app-git/productivity-app/lib/core/services/sync_worker.dart)
- [lib/core/services/sync_repository.dart](C:/productivity-app-git/productivity-app/lib/core/services/sync_repository.dart)
- [lib/core/services/app_settings.dart](C:/productivity-app-git/productivity-app/lib/core/services/app_settings.dart)

### UI e navigazione

- `GoRouter` con `ShellRoute`
- desktop: sidebar laterale
- mobile: bottom navigation compatta
- schermata `Impostazioni` dedicata per account, sync e chiave API

File centrali:

- [lib/shared/navigation/router.dart](C:/productivity-app-git/productivity-app/lib/shared/navigation/router.dart)
- [lib/shared/widgets/nav_sidebar.dart](C:/productivity-app-git/productivity-app/lib/shared/widgets/nav_sidebar.dart)
- [lib/features/settings/screens/settings_screen.dart](C:/productivity-app-git/productivity-app/lib/features/settings/screens/settings_screen.dart)

## Branding

- nome visuale app: `CUBBY`
- titolo finestra Windows: `CUBBY`
- label Android: `CUBBY`
- icona sorgente progetto: [assets/branding/cubby-logo.png](C:/productivity-app-git/productivity-app/assets/branding/cubby-logo.png)
- sorgente cromakey derivata dal banner: [assets/branding/cubby-logo-source-chroma.png](C:/productivity-app-git/productivity-app/assets/branding/cubby-logo-source-chroma.png)

Packaging toccato qui:

- [android/app/src/main/AndroidManifest.xml](C:/productivity-app-git/productivity-app/android/app/src/main/AndroidManifest.xml)
- [windows/CMakeLists.txt](C:/productivity-app-git/productivity-app/windows/CMakeLists.txt)
- [windows/runner/Runner.rc](C:/productivity-app-git/productivity-app/windows/runner/Runner.rc)
- [windows/runner/main.cpp](C:/productivity-app-git/productivity-app/windows/runner/main.cpp)

## Build disponibili

### Windows

Comando:

```bash
flutter build windows --release
```

Output atteso:

- [build/windows/x64/runner/Release/CUBBY.exe](C:/productivity-app-git/productivity-app/build/windows/x64/runner/Release/CUBBY.exe)

### Android

Comando:

```bash
flutter build apk --release
```

Output atteso:

- [build/app/outputs/flutter-apk/app-release.apk](C:/productivity-app-git/productivity-app/build/app/outputs/flutter-apk/app-release.apk)

Nota:

- la build release Android usa ancora la signing config di debug; va sostituita prima della pubblicazione pubblica

## Stato tema

- tema chiaro attivo
- tema scuro non ancora implementato
- in `Impostazioni` la voce tema e' solo segnaposto UX e non abilita ancora una palette dark completa

## Comandi di sviluppo

```bash
flutter pub get
flutter analyze
flutter test
dart run build_runner build --delete-conflicting-outputs
```

## Rischi e cose ancora da tenere presenti

- restano warning/info nel pacchetto locale `third_party/file_picker`, ma non bloccano le build
- alcuni plugin Android segnalano compatibilita' futura con il nuovo Kotlin setup Flutter
- prima di una release pubblica Android serve una firma release vera

