import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;
import 'screen/home_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");
  await dotenv.load(fileName: "assets/.env");

  FirebaseOptions firebaseOptions;

  if (kIsWeb) {
    firebaseOptions = FirebaseOptions(
      apiKey: dotenv.env['FIREBASE_API_KEY_WEB'] ?? '',
      appId: dotenv.env['FIREBASE_APP_ID_WEB'] ?? '',
      messagingSenderId: dotenv.env['FIREBASE_MESSAGING_SENDER_ID_WEB'] ?? '',
      projectId: dotenv.env['FIREBASE_PROJECT_ID_WEB'] ?? '',
      authDomain: dotenv.env['FIREBASE_AUTH_DOMAIN_WEB'],
      storageBucket: dotenv.env['FIREBASE_STORAGE_BUCKET_WEB'],
      measurementId: dotenv.env['FIREBASE_MEASUREMENT_ID_WEB'],
    );
  } else {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        firebaseOptions = FirebaseOptions(
          apiKey: dotenv.env['FIREBASE_API_KEY_ANDROID'] ?? '',
          appId: dotenv.env['FIREBASE_APP_ID_ANDROID'] ?? '',
          messagingSenderId: dotenv.env['FIREBASE_MESSAGING_SENDER_ID_ANDROID'] ?? '',
          projectId: dotenv.env['FIREBASE_PROJECT_ID_ANDROID'] ?? '',
          storageBucket: dotenv.env['FIREBASE_STORAGE_BUCKET_ANDROID'],
        );
        break;

      case TargetPlatform.iOS:
        firebaseOptions = FirebaseOptions(
          apiKey: dotenv.env['FIREBASE_API_KEY_IOS'] ?? '',
          appId: dotenv.env['FIREBASE_APP_ID_IOS'] ?? '',
          messagingSenderId: dotenv.env['FIREBASE_MESSAGING_SENDER_ID_IOS'] ?? '',
          projectId: dotenv.env['FIREBASE_PROJECT_ID_IOS'] ?? '',
          storageBucket: dotenv.env['FIREBASE_STORAGE_BUCKET_IOS'],
          iosBundleId: dotenv.env['FIREBASE_IOS_BUNDLE_ID_IOS'],
        );
        break;

      case TargetPlatform.macOS:
        firebaseOptions = FirebaseOptions(
          apiKey: dotenv.env['FIREBASE_API_KEY_MACOS'] ?? '',
          appId: dotenv.env['FIREBASE_APP_ID_MACOS'] ?? '',
          messagingSenderId: dotenv.env['FIREBASE_MESSAGING_SENDER_ID_MACOS'] ?? '',
          projectId: dotenv.env['FIREBASE_PROJECT_ID_MACOS'] ?? '',
          storageBucket: dotenv.env['FIREBASE_STORAGE_BUCKET_MACOS'],
          iosBundleId: dotenv.env['FIREBASE_IOS_BUNDLE_ID_MACOS'],
        );
        break;

      case TargetPlatform.windows:
      case TargetPlatform.linux:
        throw UnsupportedError(
          'This platform is not supported for Firebase initialization.',
        );

      default:
        throw UnsupportedError(
          'This platform is not supported for Firebase initialization.',
        );
    }
  }

  print('Firebase API Key: ${firebaseOptions.apiKey}');
  print('Firebase App ID: ${firebaseOptions.appId}');


  await Firebase.initializeApp(options: firebaseOptions);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '토큰 관리 시스템',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.indigo),
      home: const HomeScreen(),
    );
  }
}
