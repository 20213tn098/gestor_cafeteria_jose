import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gestor_cafeteria/models/auth_failure.dart';
import 'package:gestor_cafeteria/repositories/firebase_auth_repository.dart';
import 'package:mock_exceptions/mock_exceptions.dart';

void main() {
  late MockFirebaseAuth auth;
  late FakeFirebaseFirestore db;
  late FirebaseAuthRepository repo;

  setUp(() {
    auth = MockFirebaseAuth();
    db = FakeFirebaseFirestore();
    repo = FirebaseAuthRepository(auth: auth, firestore: db);
  });

  test(
    'registrar guarda el perfil en usuarios/{uid} con solo correo y nombre',
    () async {
      final usuario = await repo.registrar(
        correo: 'ana@utez.edu.mx',
        contrasena: 'cafeteria2026',
        nombre: 'Ana',
      );

      final perfil = await db.collection('usuarios').doc(usuario!.id).get();
      expect(perfil.data(), {'correo': 'ana@utez.edu.mx', 'nombre': 'Ana'});
      expect(auth.currentUser?.displayName, 'Ana');
    },
  );

  test('una contraseña equivocada llega como CredencialesInvalidas', () async {
    whenCalling(Invocation.method(#signInWithEmailAndPassword, null))
        .on(auth)
        .thenThrow(FirebaseAuthException(code: 'invalid-credential'));

    expect(
      repo.iniciarSesion(correo: 'ana@utez.edu.mx', contrasena: 'mala'),
      throwsA(isA<CredencialesInvalidas>()),
    );
  });

  test('un correo repetido llega como CorreoYaRegistrado', () async {
    whenCalling(Invocation.method(#createUserWithEmailAndPassword, null))
        .on(auth)
        .thenThrow(FirebaseAuthException(code: 'email-already-in-use'));

    expect(
      repo.registrar(
        correo: 'ana@utez.edu.mx',
        contrasena: 'cafeteria2026',
        nombre: 'Ana',
      ),
      throwsA(isA<CorreoYaRegistrado>()),
    );
  });

  test('esPersonal es true solo si existe personal/{uid}', () async {
    await db.collection('personal').doc('uid-staff').set({'nombre': 'Luis'});

    expect(await repo.esPersonal('uid-staff'), isTrue);
    expect(await repo.esPersonal('uid-ana'), isFalse);
  });
}
