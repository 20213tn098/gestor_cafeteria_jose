import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gestor_cafeteria/app.dart';
import 'package:gestor_cafeteria/firebase_options.dart';
import 'package:gestor_cafeteria/repositories/firebase_auth_repository.dart';
import 'package:gestor_cafeteria/repositories/firestore_pedido_repository.dart';

/// `flutter run --dart-define=USAR_EMULADOR=true` usa el Emulator Suite local.
const _usarEmulador = bool.fromEnvironment('USAR_EMULADOR');

Future<void> main() async {
  // Firebase debe estar listo antes de crear cualquier repositorio.
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  if (_usarEmulador) {
    // El emulador de Android ve la computadora en 10.0.2.2, no en localhost.
    final host = !kIsWeb && defaultTargetPlatform == TargetPlatform.android
        ? '10.0.2.2'
        : 'localhost';
    await FirebaseAuth.instance.useAuthEmulator(host, 9099);
    FirebaseFirestore.instance.useFirestoreEmulator(host, 8080);
  }
  runApp(
    CafeteriaApp(
      authRepository: FirebaseAuthRepository(),
      pedidoRepository: FirestorePedidoRepository(),
    ),
  );
}
