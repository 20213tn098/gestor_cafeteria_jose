import 'package:flutter_test/flutter_test.dart';
import 'package:gestor_cafeteria/core/failure.dart';
import 'package:gestor_cafeteria/models/auth_failure.dart';
import 'package:gestor_cafeteria/repositories/firebase_auth_repository.dart';
import 'package:gestor_cafeteria/repositories/firestore_pedido_repository.dart';

void main() {
  group('authFailureDesde traduce los códigos de Firebase Auth', () {
    final casos = <String, Type>{
      'invalid-credential': CredencialesInvalidas,
      'wrong-password': CredencialesInvalidas,
      'user-not-found': CredencialesInvalidas,
      'invalid-email': CredencialesInvalidas,
      'email-already-in-use': CorreoYaRegistrado,
      'weak-password': ContrasenaDebil,
      'too-many-requests': DemasiadosIntentos,
      'user-disabled': CuentaDeshabilitada,
      'network-request-failed': SinConexion,
      'algo-nuevo': AuthDesconocida,
    };

    casos.forEach((codigo, tipo) {
      test('$codigo -> $tipo', () {
        expect(authFailureDesde(codigo).runtimeType, tipo);
      });
    });
  });

  group('failureDesdeFirestore traduce los códigos de Firestore', () {
    test('permission-denied -> UnexpectedFailure 403', () {
      expect(
        failureDesdeFirestore('permission-denied'),
        isA<UnexpectedFailure>().having((f) => f.statusCode, 'statusCode', 403),
      );
    });

    test('unavailable y deadline-exceeded -> NetworkFailure', () {
      expect(failureDesdeFirestore('unavailable'), isA<NetworkFailure>());
      expect(failureDesdeFirestore('deadline-exceeded'), isA<NetworkFailure>());
    });

    test('not-found -> NotFoundFailure', () {
      expect(failureDesdeFirestore('not-found'), isA<NotFoundFailure>());
    });

    test('código desconocido -> UnexpectedFailure con el código', () {
      expect(
        failureDesdeFirestore('internal'),
        isA<UnexpectedFailure>().having(
          (f) => f.message,
          'message',
          'Firestore: internal',
        ),
      );
    });
  });
}
