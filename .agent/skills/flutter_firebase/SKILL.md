---
name: flutter-firebase
description: Enforces production-grade Firebase architecture in Flutter (Auth, Firestore, FCM, Crashlytics, Remote Config). Covers strict SDK isolation from Domain/UI, typed Firestore DTO converters with Timestamp mapping, StreamSubscription lifecycle management, FCM push message routing, non-fatal Crashlytics repository logging with PII redaction, and typed FirebaseException mapping. Use when integrating Firebase services, writing remote data sources, or managing reactive streams.
---

# Flutter Firebase Architecture Expert Skill

## When to Apply

Use this skill whenever integrating Firebase SDKs (`cloud_firestore`, `firebase_auth`, `firebase_crashlytics`, `firebase_messaging`, `firebase_remote_config`), implementing Firestore remote data sources, writing real-time stream listeners, handling push notification payloads, or configuring global crash reporting and local emulators.

---

## Naming Conventions

| Artifact              | Standard                                                     | Example                                           |
| :-------------------- | :----------------------------------------------------------- | :------------------------------------------------ |
| **Data Source**       | `[Feature]RemoteDataSource` or `[Feature]FirebaseDataSource` | `AuthRemoteDataSource`, `UserFirestoreDataSource` |
| **Firestore DTO**     | `[Name]Dto`                                                  | `UserProfileDto`                         |
| **Collections Class** | `FirestoreCollections`                                       | Centralized `FirestoreCollections.users` |
| **Exception Mapper**  | `FirebaseExceptionMapper`                                    | Maps `FirebaseException` to Domain `Failure`      |

---

## Core Architectural Rules & Standards

1. **Strict Layer Boundary:**
   - **CRITICAL:** `package:firebase_*`, `DocumentSnapshot`, `Timestamp`, `User`, `QuerySnapshot`, and `FirebaseException` MUST stay strictly inside `data/datasources/` or `infrastructure/firebase/`.
   - The `domain` and `presentation` layers MUST NEVER import Firebase packages or reference Firebase native types directly.
   - Convert Firestore `Timestamp` objects into standard Dart `DateTime` instances inside DTOs before passing models to the Domain layer.

2. **Stream Lifecycle & Memory Leak Prevention:**
   - **CRITICAL:** Every `StreamSubscription` created for real-time Firestore sync MUST have an explicit owner.
   - Subscriptions MUST be canceled inside `dispose()`, `close()`, or repository teardown hooks to avoid memory and execution leaks.

3. **Strategic Query Selection (`get()` vs `snapshots()`):**
   - Use `get()` for explicit, one-shot data fetches (e.g. initial loads, pagination steps) to conserve query quotas and prevent unwanted rebuilds.
   - Use `snapshots()` strictly for dynamic UI elements requiring live multi-device synchronization. Debounce high-churn streams if required.

4. **FCM Push Notification Isolation:**
   - Handle all FCM message states (Foreground, Background, Terminated) explicitly in `data/infrastructure/`.
   - Payload navigation MUST NOT occur directly inside messaging handlers — signal route intents upward via a dedicated Application Navigation Coordinator.

5. **Crashlytics Non-Fatal Repository Logging:**
   - Record non-fatal technical stack traces in repository `catch` blocks before or during transformation into Domain `Failure` objects.
   - **PII Protection:** Redact tokens, passwords, emails, and sensitive personal identifiers from all Crashlytics logs and custom keys.

6. **Untrusted Transport & Security Rules:**
   - Treat Cloud Firestore as an untrusted client transport. Never rely solely on client-side input validation — enforce access policies using backend Firestore Security Rules.

---

## 1. Firebase DI Module & Local Emulator Configuration

Inject Firebase instances via a central `@module` and attach Local Emulators for debug environments.

```dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

@module
abstract class FirebaseModule {
  @lazySingleton
  FirebaseAuth get firebaseAuth {
    final auth = FirebaseAuth.instance;
    if (kDebugMode && const bool.fromEnvironment('USE_EMULATOR')) {
      auth.useAuthEmulator('localhost', 9099);
    }
    return auth;
  }

  @lazySingleton
  FirebaseFirestore get firestore {
    final firestore = FirebaseFirestore.instance;
    if (kDebugMode && const bool.fromEnvironment('USE_EMULATOR')) {
      firestore.useFirestoreEmulator('localhost', 8080);
    }
    firestore.settings = const Settings(
      persistenceEnabled: true,
      cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
    );
    return firestore;
  }

  @lazySingleton
  FirebaseMessaging get firebaseMessaging => FirebaseMessaging.instance;

  @lazySingleton
  FirebaseCrashlytics get crashlytics => FirebaseCrashlytics.instance;
}

```

---

## 2. Centralized Collections & DTO Timestamp Mapping

### A. Centralized Firestore Paths

```dart
abstract class FirestoreCollections {
  static const String users = 'users';
  static const String posts = 'posts';
  static String userComments(String userId) => 'users/$userId/comments';
}

```

### B. Firestore DTO with Safe DateTime Converters

```dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:my_app/domain/entities/user_profile.dart';

part 'user_profile_dto.freezed.dart';
part 'user_profile_dto.g.dart';

@freezed
abstract class UserProfileDto with _$UserProfileDto {
  const UserProfileDto._();

  const factory UserProfileDto({
    required String id,
    required String email,
    required String displayName,
    @JsonKey(fromJson: _dateTimeFromTimestamp, toJson: _dateTimeToTimestamp)
    required DateTime createdAt,
  }) = _UserProfileDto;

  factory UserProfileDto.fromJson(Map<String, dynamic> json) =>
      _$UserProfileDtoFromJson(json);

  factory UserProfileDto.fromFirestore(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final data = snapshot.data();
    if (data == null) throw const FormatException('Snapshot payload is null');
    return UserProfileDto.fromJson({'id': snapshot.id, ...data});
  }

  Map<String, dynamic> toFirestore() => toJson()..remove('id');

  UserProfile toDomain() {
    return UserProfile(
      id: id,
      email: email,
      displayName: displayName,
      createdAt: createdAt,
    );
  }

  static DateTime _dateTimeFromTimestamp(dynamic timestamp) {
    if (timestamp is Timestamp) return timestamp.toDate();
    if (timestamp is String) return DateTime.parse(timestamp);
    return DateTime.now();
  }

  static dynamic _dateTimeToTimestamp(DateTime dateTime) {
    return Timestamp.fromDate(dateTime);
  }
}

```

---

## 3. Typed Firestore Repository & Lifecycle-Safe Streams

Use `.withConverter<T>()` and handle query streams cleanly.

```dart
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:injectable/injectable.dart';
import 'package:my_app/data/dtos/user_profile_dto.dart';
import 'package:my_app/data/firebase/firestore_collections.dart';
import 'package:my_app/domain/entities/user_profile.dart';

@LazySingleton()
class UserFirestoreRepository {
  final FirebaseFirestore _firestore;

  UserFirestoreRepository(this._firestore);

  CollectionReference<UserProfileDto> get _usersRef => _firestore
      .collection(FirestoreCollections.users)
      .withConverter<UserProfileDto>(
        fromFirestore: (snapshot, _) => UserProfileDto.fromFirestore(snapshot),
        toFirestore: (dto, _) => dto.toFirestore(),
      );

  // One-shot fetch (get)
  Future<UserProfile> getUserOnce(String userId) async {
    final snapshot = await _usersRef.doc(userId).get();
    final dto = snapshot.data();
    if (dto == null) throw const FormatException('User not found');
    return dto.toDomain();
  }

  // Reactive Stream (snapshots)
  Stream<UserProfile> watchUser(String userId) {
    return _usersRef
        .doc(userId)
        .snapshots()
        .map((snapshot) {
          final dto = snapshot.data();
          if (dto == null) throw const FormatException('User document removed');
          return dto.toDomain();
        });
  }
}

```

---

## 4. FCM Push Notification Lifecycle Setup

Centralize push notification lifecycle management in `infrastructure/fcm/`.

```dart
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:injectable/injectable.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Handle background data sync (do not trigger UI here)
}

@singleton
class PushNotificationService {
  final FirebaseMessaging _fcm;

  PushNotificationService(this._fcm);

  Future<void> initialize() async {
    await _fcm.requestPermission(alert: true, badge: true, sound: true);

    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      // Pass to local notifications engine or in-app toast event bus
    });

    // Terminated state tap interaction
    final initialMessage = await _fcm.getInitialMessage();
    if (initialMessage != null) {
      _handlePayloadNavigation(initialMessage.data);
    }

    // Background state tap interaction
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      _handlePayloadNavigation(message.data);
    });
  }

  void _handlePayloadNavigation(Map<String, dynamic> data) {
    // Forward payload to App-level Navigation Coordinator (do NOT call Navigator directly)
  }
}

```

---

## 5. Non-Fatal Crashlytics Repository Logging & Exception Mapping

Log technical execution failures in Crashlytics while returning clean Domain `Failure` models.

```dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:my_app/domain/failures/failure.dart';

class FirebaseExceptionMapper {
  static Failure mapToFailure(Object exception, StackTrace stackTrace, FirebaseCrashlytics crashlytics) {
    // Record non-fatal exception details to Crashlytics (with PII redacted)
    crashlytics.recordError(
      exception,
      stackTrace,
      reason: 'Firebase Data Layer Execution Failure',
      fatal: false,
    );

    if (exception is FirebaseAuthException) {
      switch (exception.code) {
        case 'user-not-found':
        case 'wrong-password':
        case 'invalid-credential':
          return const AuthFailure(message: 'Invalid user credentials.');
        case 'email-already-in-use':
          return const AuthFailure(message: 'Account with this email already exists.');
        case 'too-many-requests':
          return const NetworkFailure(message: 'Too many attempts. Please try again later.');
        default:
          return AuthFailure(message: exception.message ?? 'Authentication error');
      }
    }

    if (exception is FirebaseException) {
      switch (exception.code) {
        case 'permission-denied':
          return const ForbiddenFailure(message: 'Access permission denied.');
        case 'not-found':
          return const NotFoundFailure(message: 'Requested document was not found.');
        case 'unavailable':
          return const NetworkFailure(message: 'Database service unavailable.');
        default:
          return ServerFailure(message: exception.message ?? 'Database transaction error', statusCode: 500);
      }
    }

    return UnknownFailure(message: exception.toString());
  }
}

```

---

## 6. Global Application Entry Point (`main.dart`)

```dart
import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // Catch framework errors
  FlutterError.onError = (errorDetails) {
    FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
  };

  // Catch asynchronous errors outside Flutter framework
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };

  if (kDebugMode) {
    await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(false);
  }

  runApp(const MyApp());
}

```

---

## Anti-Patterns (Strictly Prohibited)

| Anti-Pattern                                                                        | Severity     | Corrective Action                                                                      |
| ----------------------------------------------------------------------------------- | ------------ | -------------------------------------------------------------------------------------- |
| Importing `cloud_firestore` or `firebase_auth` inside Domain or Presentation layers | **CRITICAL** | Keep all Firebase SDK dependencies strictly contained in `data/` or `infrastructure/`. |

|
| Leaking unmonitored `StreamSubscription` instances without `cancel()` teardowns | **CRITICAL** | Bind subscriptions to lifecycle handlers (`dispose()`, BLoC `close()`).

|
| Triggering navigation or showing Dialogs directly inside FCM background handlers | **HIGH** | Emit payload events to an Application Navigation Coordinator.

|
| Passing raw Firestore `Timestamp` or `DocumentSnapshot` instances to BLoCs | **HIGH** | Convert `Timestamp` to standard Dart `DateTime` in DTOs.

|
| Storing sensitive PII, access tokens, or plain-text credentials in Firestore | **HIGH** | Use secure client storage or server-side field-level encryption.

|
| Logging full user PII (emails, full names, auth tokens) to Crashlytics | **HIGH** | Redact personal identifiers prior to recording non-fatals.

|

---

## Agent Verification Checklist

When reviewing Firebase code:

1. **Zero Domain Imports:** Neither `domain` nor `presentation` layers import `package:firebase_*`.

2. **Subscription Ownership:** All `snapshots()` subscriptions are tracked and explicitly canceled.

3. **FCM Boundaries:** FCM message handling does not trigger UI or direct router calls.

4. **DTO DateTime Mapping:** Firestore `Timestamp` conversion is contained within DTOs.

5. **Non-Fatal Error Pipeline:** Repository exceptions are logged to Crashlytics with PII redacted before mapping to `Failure`.

6. **Central Pathing:** Document and collection path strings are managed in `FirestoreCollections`.
