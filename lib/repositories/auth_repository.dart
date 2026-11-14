import 'package:gestor_cafeteria/models/usuario.dart';

/// Contrato de la sesión. Las implementaciones lanzan solo `AuthFailure`.
abstract interface class AuthRepository {
  /// Emite el usuario con sesión, o null; al abrir la app emite el guardado.
  Stream<Usuario?> get sesion;

  Future<Usuario?> iniciarSesion({
    required String correo,
    required String contrasena,
  });

  Future<Usuario?> registrar({
    required String correo,
    required String contrasena,
    required String nombre,
  });

  Future<void> cerrarSesion();

  /// true si la persona tiene el rol de personal de la cafetería.
  Future<bool> esPersonal(String uid);
}
