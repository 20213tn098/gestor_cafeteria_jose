import 'dart:async';

import 'package:gestor_cafeteria/models/auth_failure.dart';
import 'package:gestor_cafeteria/models/usuario.dart';
import 'package:gestor_cafeteria/repositories/auth_repository.dart';

/// Doble de [AuthRepository] en memoria: sin red ni Firebase.
class FakeAuthRepository implements AuthRepository {
  FakeAuthRepository({Usuario? inicial, this.personal = const {}})
    : _actual = inicial;

  final _controlador = StreamController<Usuario?>.broadcast();
  final Set<String> personal;
  Usuario? _actual;

  /// Si no es null, la próxima operación lanza esta falla.
  AuthFailure? fallaSiguiente;
  int llamadas = 0;

  @override
  Stream<Usuario?> get sesion async* {
    yield _actual;
    yield* _controlador.stream;
  }

  void _emitir(Usuario? u) {
    _actual = u;
    _controlador.add(u);
  }

  Future<void> _revisarFalla() async {
    llamadas++;
    final falla = fallaSiguiente;
    fallaSiguiente = null;
    if (falla != null) throw falla;
  }

  @override
  Future<Usuario?> iniciarSesion({
    required String correo,
    required String contrasena,
  }) async {
    await _revisarFalla();
    final u = Usuario(id: 'uid-$correo', correo: correo, nombre: 'Ana');
    _emitir(u);
    return u;
  }

  @override
  Future<Usuario?> registrar({
    required String correo,
    required String contrasena,
    required String nombre,
  }) async {
    await _revisarFalla();
    final u = Usuario(id: 'uid-$correo', correo: correo, nombre: nombre);
    _emitir(u);
    return u;
  }

  @override
  Future<void> cerrarSesion() async => _emitir(null);

  @override
  Future<bool> esPersonal(String uid) async => personal.contains(uid);
}
